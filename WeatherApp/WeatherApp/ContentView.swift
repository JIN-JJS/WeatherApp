//
//  ContentView.swift
//  WeatherApp
//
//  Created by 전준수 on 3/5/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var weatherKitManager = WeatherKitManager()
    
    var body: some View {
        HStack {
            Label(weatherKitManager.temp, systemImage: weatherKitManager.symbol)
        }
        .task {
            await weatherKitManager.getWeather()
        }
    }
}

#Preview {
    ContentView()
}
