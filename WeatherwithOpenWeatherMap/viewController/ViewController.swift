//
//  ViewController.swift
//  WeatherwithOpenWeatherMap
//
//  Created by Brycen on 12/4/23.
//

import UIKit
import CoreLocation
import Combine
import SDWebImage
import SwiftUI

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var latLongLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var weatherStatusLbl: UILabel!
    @IBOutlet weak var lowTempLbl: UILabel!
    @IBOutlet weak var heightTempLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var sunriseLbl: UILabel!
    @IBOutlet weak var sunsetLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    var locationManager = CLLocationManager()
    var forecastList: [ForeCast] = []
    var timeZone: TimeZone = .current
    
    private var activityIndicator: UIActivityIndicatorView!
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel = WeatherViewModel()
    var indicator : UIActivityIndicatorView?
    
    @Published var selectedLatitude: Double?
    @Published var selectedLongitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchView()
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.bindViewModel()
        }
    }
    
    func setupSearchView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchViewTapped))
        searchView.addGestureRecognizer(tapGesture)
        searchView.isUserInteractionEnabled = true
    }
    
    @objc func searchViewTapped() {
        showSwiftUIView()
    }
    @IBAction func clickedSaveButton(_ sender: Any) {
        let hostingController = UIHostingController(rootView: SaveWeatherSwiftUIView())
        hostingController.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 1
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft

        hostingController.view.layer.add(transition, forKey: kCATransition)
        present(hostingController, animated: false, completion: nil)
        
    }
    
    private func showSwiftUIView() {
        var searchSwiftUIView = SearchSwiftUIView()
        searchSwiftUIView.onItemSelected = { [weak self] latitude, longitude in
            self?.handleItemSelected(latitude: latitude, longitude: longitude)
        }
        let hostingController = UIHostingController(rootView: searchSwiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        
        let transition = CATransition()
        transition.duration = 1
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft

        hostingController.view.layer.add(transition, forKey: kCATransition)
        present(hostingController, animated: false, completion: nil)
    }
    
    func handleItemSelected(latitude: Double, longitude: Double) {
        selectedLatitude = latitude
        selectedLongitude = longitude
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            UINib(nibName: ForecaseCollectionViewCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: ForecaseCollectionViewCell.identifier
        )
    }
    
    private func bindViewModel() {
        viewModel.$currentWeather
            .sink { [weak self] weatherData in
                guard let weatherData = weatherData else { return }
                self?.updateUI(with: weatherData)
            }
            .store(in: &cancellables)
        
        viewModel.$forecastList
            .sink { [weak self] forecastList in
                
                self?.forecastList = forecastList?.daily ?? []
                self?.timeZone = TimeZone(identifier: forecastList?.timezone ?? "") ?? TimeZone.current
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        // Observe changes in selectedLatitude and selectedLongitude
        $selectedLatitude.combineLatest($selectedLongitude)
            .sink { [weak self] (latitude, longitude) in
                guard let latitude = latitude, let longitude = longitude else { return }
                self?.viewModel.fetchForecastWeather(latitude: latitude, longitude: longitude)
                
                self?.viewModel.fetchWeather(latitude: latitude, longitude: longitude)                    }
            .store(in: &cancellables)
    }
    
    
    func updateUI(with weatherData: CurrentWeatherResponse) {
        cityLbl.text = weatherData.name ?? ""
        latLongLbl.text = "Lat : \(weatherData.coord?.lat ?? 0.0 )   Long : \(weatherData.coord?.lon ?? 0.0)"
        weatherImg.sd_setImage(with: URL(string: "\(AppConstants.imgURl)\(weatherData.weather?.first?.icon ?? "").png"), placeholderImage: UIImage(named: "cloud.fill.png"))
        tempLbl.text = "\(String(format: "%.1f", (weatherData.main?.temp ?? 0.0) - AppConstants.tempOffset))º"
        
        heightTempLbl.text = "\(String(format: "%.1f", (weatherData.main?.tempMax ?? 0.0) - AppConstants.tempOffset))º"
        lowTempLbl.text = "\(String(format: "%.1f", (weatherData.main?.tempMin ?? 0.0) - AppConstants.tempOffset))º"
        weatherStatusLbl.text = weatherData.weather?.first?.main ?? ""
        humidityLbl.text = "\(weatherData.main?.humidity ?? 0)%"
        sunriseLbl.text = "\(formatUnixTimestampToTime(timestamp: TimeInterval(weatherData.sys?.sunrise ?? 0), false , timeZone))"
        sunsetLbl.text = "\(formatUnixTimestampToTime(timestamp: TimeInterval(weatherData.sys?.sunset ?? 0), false , timeZone))"
        
        setGradientBackground(for: WeatherCondition(conditionCode: weatherData.weather?.first?.id ?? 0), in: bgView)
        
        
        
    }
    
    private func handleStateChange(_ state: WeatherState) {
        
        switch state {
        case .idle:
            // Handle idle state if needed
            break
        case .loading:
            indicator = self.displayLoading()
        case .success:
            if indicator != nil {
                self.dismissLoading(indicator ?? UIActivityIndicatorView())
            }
        case .failure(let error):
            if indicator != nil {
                self.dismissLoading(indicator ?? UIActivityIndicatorView())
            }
            displayAlertMessage(title: "Something was wrong!", message: "\(error) \n please try again later..")
        }
    }
    
    
}

extension ViewController : UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return forecastList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecaseCollectionViewCell.identifier, for: indexPath) as! ForecaseCollectionViewCell
        
        cell.dateLbl.text = "\(formatUnixTimestampToTime(timestamp: TimeInterval(forecastList[indexPath.row].dt ?? 0), true , timeZone))"
        cell.tempLbl.text = "\(String(format: "%.1f", (forecastList[indexPath.row].temp?.day ?? 0.0) - AppConstants.tempOffset))º"
        cell.lowHighTempLbl.text = "H:\(String(format: "%.1f", (forecastList[indexPath.row].temp?.max ?? 0.0) - AppConstants.tempOffset))º L:\(String(format: "%.1f", (forecastList[indexPath.row].temp?.min ?? 0.0) - AppConstants.tempOffset))º"
        cell.weatherMainLbl.text = forecastList[indexPath.row].weather?.first?.main ?? ""
        cell.weatherImg.sd_setImage(with: URL(string: "\(AppConstants.imgURl)\(forecastList[indexPath.row].weather?.first?.icon ?? "").png"), placeholderImage: UIImage(named: "cloud.fill.png"))
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth : CGFloat = ( UIScreen.main.bounds.width - 70 )  * 0.30
        return CGSize(width: itemWidth, height: itemWidth)
        
    }
}
