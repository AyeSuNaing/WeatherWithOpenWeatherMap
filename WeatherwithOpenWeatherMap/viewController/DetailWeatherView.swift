//
//  DetailWeatherView.swift
//  WeatherwithOpenWeatherMap
//
//  Created by AyeSuNaing on 05/12/2023.
//

import SwiftUI

struct DetailWeatherView: View {
    var weatherResult: CurrentWeatherResponse
    
    var body: some View {
        NavigationView {
            VStack {
                
            }
            .navigationBarTitle("Detail", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button(action: {
                    // Handle custom back button action
                    // You can use the presentationMode.wrappedValue.dismiss() here if needed
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                        Text("Back")
                            .foregroundColor(.black)
                    }
                }
            )
        }
    }
}
