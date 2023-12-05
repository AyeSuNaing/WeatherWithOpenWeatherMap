//
//  Extender.swift
//  WeatherwithOpenWeatherMap
//
//  Created by Brycen on 12/4/23.
//

import Foundation
import UIKit


extension UICollectionViewCell {
    static var identifier : String {
        return String(describing: self)
    }
}

extension UIColor {
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
}

extension UIView {
    func setGradientBackground(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
}


extension UIViewController {
    
    static var identifier : String {
        return String(describing: self)
    }
    
    func setGradientBackground(for weatherCondition: WeatherCondition, in view: UIView) {
        var colors: [UIColor]
        
        switch weatherCondition {
        case .thunderstorm:
            colors = [UIColor(0, 0, 128), UIColor(25, 25, 112)] // Navy Blue to Midnight Blue
        case .drizzle:
            colors = [UIColor(135, 206, 250), UIColor(70, 130, 180)] // Sky Blue to Steel Blue
        case .rain:
            colors = [UIColor(70, 130, 180), UIColor(0, 0, 139)] // Steel Blue to Dark Blue
        case .snow:
            colors = [UIColor(255, 250, 250), UIColor(192, 192, 192)] // Snow to Silver
        case .atmosphere:
            colors = [UIColor(128, 128, 128), UIColor(0, 0, 0)] // Gray to Black
        case .clear:
            colors = [UIColor(135, 206, 250), UIColor(0, 191, 255)] // Sky Blue to Deep Sky Blue
        case .clouds:
            colors = [UIColor(192, 192, 192), UIColor(128, 128, 128)] // Silver to Gray
        case .unknown:
            colors = [UIColor.white, UIColor.white] // Default to white
        }
        
        // Set gradient background with the selected colors
        view.setGradientBackground(colors: colors, locations: [0.0, 1.0])
    }
    
    
    func formatUnixTimestampToTime(timestamp: TimeInterval,_ isForeCast : Bool,_ timezone : TimeZone) -> String {
        // Convert timestamp to Date
        let date = Date(timeIntervalSince1970: timestamp)
        
        // Create a date formatter with the user's local timezone
        let dateFormatter = DateFormatter()
        if isForeCast {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
        } else {
            dateFormatter.dateFormat = "hh:mm a" // "a" represents AM/PM
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
        }
        dateFormatter.timeZone = timezone // Use the local timezone
        
        return dateFormatter.string(from: date)
    }
    
    func displayLoading() -> UIActivityIndicatorView {
        
        let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = UIColor.darkGray
        loadingIndicator.center = self.view.center
        loadingIndicator.startAnimating();
        view.addSubview(loadingIndicator)
        view.alpha = 1
        view.isUserInteractionEnabled = false
        return loadingIndicator
    }
    
    func dismissLoading(_ indicator : UIActivityIndicatorView) {
        indicator.stopAnimating()
        view.alpha = 1
        
        view.isUserInteractionEnabled = true
    }
    
    func displayAlertMessage(title:String?,message:String?){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
