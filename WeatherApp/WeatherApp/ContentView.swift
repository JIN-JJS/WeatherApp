//
//  ContentView.swift
//  WeatherApp
//
//  Created by 전준수 on 3/5/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var weatherKitManager = WeatherKitManager()
    
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        
        if locationManager.authorisationStatus == .authorizedWhenInUse {
        
            // Create your view
            VStack {
                Label(weatherKitManager.temp, systemImage: weatherKitManager.symbol)
            }
            .task {
                await weatherKitManager.getWeather(latitude: locationManager.latitude, longitude: locationManager.longitude)
            }
            
        } else {
            
            // Create your alternate view
            Text("Error loading location")
        }
        

    }
}

#Preview {
    ContentView()
}
