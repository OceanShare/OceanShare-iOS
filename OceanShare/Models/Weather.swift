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
    
    // MARK: - Weather Functions
    
    static func analyseUvIndex(uvIndex: Double) -> String {
        let uvRank: String
        
        if uvIndex < 2 {
            uvRank = "\(round(100 * uvIndex) / 100) (Low)"
            
        } else if uvIndex > 6 {
            uvRank = "\(round(100 * uvIndex) / 100) (High)"
            
        } else {
            uvRank = "\(round(100 * uvIndex) / 100) (Medium)"
            
        }
        return uvRank
    }
    
    static func analyseDescription(weather: Weather, registry: Registry) -> UIImage {
        var choosenOne: UIImage
        
        if (weather.dateAndTime < weather.sunrise) || (weather.dateAndTime > weather.sunset) {
            switch weather.weatherID {
            case 0...232 :
                choosenOne = registry.iconStorm!
            case 300...321, 500...504, 520...531 :
                choosenOne = registry.iconNightRain!
            case 511, 600...622 :
                choosenOne = registry.iconSnow!
            case 801...804 :
                choosenOne = registry.iconNightCloud!
            default:
                choosenOne = registry.iconMoon!
                
            }
        } else {
            switch weather.weatherID {
            case 0...232 :
                choosenOne = registry.iconStorm!
            case 300...321, 520...531 :
                choosenOne = registry.iconLightRain!
            case 500...504 :
                choosenOne = registry.iconRain!
            case 511, 600...601, 615...622 :
                choosenOne = registry.iconSnow!
            case 611...613 :
                choosenOne = registry.iconHail!
            case 701...771 :
                choosenOne = registry.iconCloud!
            case 781 :
                choosenOne = registry.iconTornado!
            case 800 :
                choosenOne = registry.iconSun!
            case 801, 802 :
                choosenOne = registry.iconOvercastCloud!
            case 803, 804 :
                choosenOne = registry.iconClouds!
            default :
                choosenOne = registry.iconThermometer!
            }
        }
        return choosenOne
        
    }
    
    // MARK: - Time Related Functions
    
    static func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        return (dateInFormat)
        
    }
    
    static func getDateFromString(time: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "fr_GP")
        let date = dateFormatter.date(from:time)!
        return date
        
    }
    
    static func getPastTime(for date : Date) -> String {
        var secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
            
        }
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute  {
            if secondsAgo < 2 {
                return "Just now."
                
            } else {
                return "\(secondsAgo) seconds ago."
                
            }
        } else if secondsAgo < hour {
            let min = secondsAgo/minute
            if min == 1{
                return "\(min) minutes ago."
                
            } else {
                return "\(min) minutes ago."
                
            }
        } else if secondsAgo < day {
            let hr = secondsAgo/hour
            if hr == 1{
                return "\(hr) hour ago."
                
            } else {
                return "\(hr) hours ago."
                
            }
        } else if secondsAgo < week {
            let day = secondsAgo/day
            if day == 1{
                return "\(day) day ago."
                
            } else {
                return "\(day) days ago."
                
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd, hh:mm a"
            formatter.locale = Locale(identifier: "fr_GP")
            let strDate: String = formatter.string(from: date)
            return strDate
            
        }
    }
    
}
