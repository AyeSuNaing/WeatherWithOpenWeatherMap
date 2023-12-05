//
//  SaveWeatherSwiftUIView.swift
//  WeatherwithOpenWeatherMap
//
//  Created by AyeSuNaing on 05/12/2023.
//

import SwiftUI
import Combine

struct WeatherListItemView: View {
    var weatherResult: CurrentWeatherResponse
    
    var body: some View {
        HStack {
            // Image
            Image(systemName: "photo")
                .resizable()
                .frame(width: 70, height: 70)
                .cornerRadius(10)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(weatherResult.name ?? "")
                    .font(.headline)
                
                Text("\(weatherResult.coord?.lat ?? 0.0) , \(weatherResult.coord?.lat ?? 0.0)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}


struct SaveWeatherSwiftUIView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel = SaveViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.saveResults, id: \.id) { result in
                    NavigationLink(destination: DetailWeatherView(weatherResult: result)) {
                        WeatherListItemView(weatherResult: result)
                    }
                    
                }
            }
            .navigationBarTitle("Saved Weather", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    // Handle back button action
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black) // Set the color of the Image
                    Text("Back")
                        .foregroundColor(.black)
                }
            )
            .background(Color(.systemGray6))
        }
    }
}
