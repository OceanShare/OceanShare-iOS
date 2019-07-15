//
//  Weather.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 12/07/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct Weather {
    let dateAndTime: Date
    let city: String
    let longitude: Double
    let latitude: Double
    let weatherID: Int
    let mainWeather: String
    let weatherDescription: String
    let weatherIconID: String
    let humidity: Int
    let pressure: Int
    let cloudCover: Int
    let windSpeed: Double
    let visibility: Int?
    let windDirection: Double?
    let rainfallInLast3Hours: Double?
    let sunrise: Date
    let sunset: Date
    
    private let temp: Double
    
    var tempCelsius: Double {
        get {
            return temp - 273.15
            
        }
    }
    var tempFahrenheit: Double {
        get {
            return (temp - 273.15) * 1.8 + 32
            
        }
    }
    
    init(weatherData: JSON) {
        dateAndTime = Date(timeIntervalSince1970: weatherData["dt"].double!)
        city = weatherData["name"].string!
        longitude = weatherData["coord"]["lon"].double!
        latitude = weatherData["coord"]["lat"].double!
        weatherID = weatherData["weather"][0]["id"].int!
        mainWeather = weatherData["weather"][0]["main"].string!
        weatherDescription = weatherData["weather"][0]["description"].string!
        weatherIconID = weatherData["weather"][0]["icon"].string!
        temp = weatherData["main"]["temp"].double!
        humidity = weatherData["main"]["humidity"].int!
        pressure = weatherData["main"]["pressure"].int!
        cloudCover = weatherData["clouds"]["all"].int!
        windSpeed = weatherData["wind"]["speed"].double!
        windDirection = weatherData["wind"]["deg"].double
        sunrise = Date(timeIntervalSince1970: weatherData["sys"]["sunrise"].double!)
        sunset = Date(timeIntervalSince1970: weatherData["sys"]["sunset"].double!)
        
        if let rainDict = weatherData["rain"]["3h"].double {
            rainfallInLast3Hours = rainDict
            
        } else {
            rainfallInLast3Hours = nil
            
        }
        if let temporaryVisibility = weatherData["visibility"].int {
            visibility = temporaryVisibility
            
        } else {
            visibility = nil
            
        }
    }
    
}
