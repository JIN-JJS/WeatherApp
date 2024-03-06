//
//  WeatherKitManager.swift
//  Gilgaon
//
//  Created by 전준수 on 3/5/24.
//

import Foundation
import WeatherKit

@MainActor class WeatherKitManager: ObservableObject {
    
    @Published var weather: Weather?
    
    func getWeather(latitude: Double, longitude: Double) {
        Task {
            do {
                weather = try await Task.detached(priority: .userInitiated) {
                    return try await WeatherService.shared.weather(for: .init(latitude: latitude, longitude: longitude))
                }.value
            } catch {
                fatalError("\(error)")
            }
        }
    }
    
    var symbol: String {
        weather?.currentWeather.symbolName ?? "xmark"
    }
    
    var temp: String {
        let temp = weather?.currentWeather.temperature
        let convertedTemp = temp?.converted(to: .celsius).description
        return convertedTemp ?? "Loading Weather Data"
    }
    
}
