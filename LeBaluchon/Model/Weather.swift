//
//  Weather.swift
//  LeBaluchon
//
//  Created by co5ta on 29/01/2019.
//  Copyright © 2019 Co5ta. All rights reserved.
//

import Foundation

/// Weather data sent by the API
struct Weather: Decodable {
    /// Weather for each city requested
    let weatherConditions: [WeatherCondition]
    
    /// Relations between properties and json
    enum CodingKeys: String, CodingKey {
        case weatherConditions = "list"
    }
}

// MARK: -

/// Current weather conditions for a location
struct WeatherCondition: Codable {
    /// List of current weather conditions
    private let conditions: [Condition]
    
    /// Temperature in the city
    private let temperatures: Temperature
    
    /// Name of the location
    let location: String
    
    /// Temperature in text
    var celciusTemperatures: String {
        return "\(Int(temperatures.current))° C"
    }
    
    /// Primary weather condition
    var condition: Condition {
        return conditions[0]
    }
    
    /// Relations between properties and json
    enum CodingKeys: String, CodingKey {
        case location = "name"
        case conditions = "weather"
        case temperatures = "main"
    }
}

// MARK: -

/// Detailed weather conditions
struct Condition: Codable {
    /// Name of the icon which illustrate the weather condition
    let icon: String
    
    /// Description of the weather condition
    let description: String
    
    /// Relations between properties and json
    enum CodingKeys: String, CodingKey {
        case icon
        case description
    }
}

// MARK: -

/// Detailed temperatures
struct Temperature: Codable {
    /// Current temperature
    let current: Float
    
    /// Relations between properties and json
    enum CodingKeys: String, CodingKey {
        case current = "temp"
    }
}
