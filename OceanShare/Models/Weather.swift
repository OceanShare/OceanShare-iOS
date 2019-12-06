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
    
    // MARK: - Weather Struct Functions
    
    /**
     - Description - Get cardinal wind direction from degree wind direction.
     - Inputs - degrees `Double`
     - Output - `String` cardinal wind direction
     */
    static func analyseWindDirection(degrees: Double) -> String {
        var windDirection: String
        
        if (348.75 <= degrees && degrees <= 360) {
            windDirection = NSLocalizedString("N ", comment: "");
        } else if (0 <= degrees && degrees <= 11.25) {
            windDirection = NSLocalizedString("N ", comment: "");
        } else if (11.25 < degrees && degrees <= 33.75) {
            windDirection = NSLocalizedString("NNE ", comment: "");
        } else if (33.75 < degrees && degrees <= 56.25) {
            windDirection = NSLocalizedString("NE ", comment: "");
        } else if (56.25 < degrees && degrees <= 78.75) {
            windDirection = NSLocalizedString("ENE ", comment: "");
        } else if (78.75 < degrees && degrees <= 101.25) {
            windDirection = NSLocalizedString("E ", comment: "");
        } else if (101.25 < degrees && degrees <= 123.75) {
            windDirection = NSLocalizedString("ESE ", comment: "");
        } else if (123.75 < degrees && degrees <= 146.25) {
            windDirection = NSLocalizedString("SE ", comment: "");
        } else if (146.25 < degrees && degrees <= 168.75) {
            windDirection = NSLocalizedString("SSE ", comment: "");
        } else if (168.75 < degrees && degrees <= 191.25) {
            windDirection = NSLocalizedString("S ", comment: "");
        } else if (191.25 < degrees && degrees <= 213.75) {
            windDirection = NSLocalizedString("SSW ", comment: "");
        } else if (213.75 < degrees && degrees <= 236.25) {
            windDirection = NSLocalizedString("SW ", comment: "");
        } else if (236.25 < degrees && degrees <= 258.75) {
            windDirection = NSLocalizedString("WSW ", comment: "");
        } else if (258.75 < degrees && degrees <= 281.25) {
            windDirection = NSLocalizedString("W ", comment: "");
        } else if (281.25 < degrees && degrees <= 303.75) {
            windDirection = NSLocalizedString("WNW ", comment: "");
        } else if (303.75 < degrees && degrees <= 326.25) {
            windDirection = NSLocalizedString("NW ", comment: "");
        } else if (326.25 < degrees && degrees < 348.75) {
            windDirection = NSLocalizedString("NNW ", comment: "");
        } else {
            windDirection  = ""
        }
        return windDirection + "\(round(100 * (degrees * (60*60) / 1000)) / 100) km/h"
    }
    
    /**
     - Description - Calculate uv index from a weather chanel value.
     - Inputs - uvIndex `Double`
     - Output - `String` uv index
     */
    static func analyseUvIndex(uvIndex: Double) -> String {
        let uvRank: String
        
        if uvIndex < 2 {
            uvRank = "\(round(100 * uvIndex) / 100) \(NSLocalizedString("low", comment: ""))"
            
        } else if uvIndex > 6 {
            uvRank = "\(round(100 * uvIndex) / 100) \(NSLocalizedString("high", comment: ""))"
            
        } else {
            uvRank = "\(round(100 * uvIndex) / 100) \(NSLocalizedString("medium", comment: ""))"
            
        }
        return uvRank
    }
    
    /**
     - Description - Get a weather description depending of a weather chanel code.
     - Inputs - weather `Weather` & registry `Registry`
     - Output - `String` weather description
     */
    static func analyseWeatherDescription(weather: Weather, registry: Registry) -> String {
        if (weather.dateAndTime < weather.sunrise) || (weather.dateAndTime > weather.sunset) {
            switch weather.weatherID {
            case 0...232 :
                return NSLocalizedString("thunderstorm", comment: "")
            case 300...321, 500...504, 520...531 :
                return NSLocalizedString("rain", comment: "")
            case 511, 600...622 :
                return NSLocalizedString("snow", comment: "")
            case 801...804 :
                return NSLocalizedString("clouds", comment: "")
            default:
                return NSLocalizedString("clear", comment: "")
                
            }
        } else {
            switch weather.weatherID {
            case 0...232 :
                return NSLocalizedString("thunderstorm", comment: "")
            case 300...321, 520...531 :
                return NSLocalizedString("lightrain", comment: "")
            case 500...504 :
                return NSLocalizedString("heavyrain", comment: "")
            case 511, 600...601, 615...622 :
                return NSLocalizedString("snow", comment: "")
            case 611...613 :
                return NSLocalizedString("hail", comment: "")
            case 701...771 :
                return NSLocalizedString("mist", comment: "")
            case 781 :
                return NSLocalizedString("tornado", comment: "")
            case 800 :
                return NSLocalizedString("clear", comment: "")
            case 801, 802 :
                return NSLocalizedString("fewclouds", comment: "")
            case 803, 804 :
                return NSLocalizedString("overcastclouds", comment: "")
            default :
                return NSLocalizedString("clear", comment: "")
            }
        }
    }
    
    /**
     - Description - Get a weather icon depending of a weather chanel code.
     - Inputs - weather `Weather` & registry `Registry`
     - Output - `UIImage` weather icon
     */
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
    
    /**
     - Description - Get the current date and time with the dd-MM-yyyy HH:mm format.
     - Output - `String` date and hour
     */
    static func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateInFormat = dateFormatter.string(from: NSDate() as Date)
        return (dateInFormat)
        
    }
    
    /**
     - Description - Get current date and hour from a string.
     - Inputs - time `String`
     - Output - `Date` current date and hour
     */
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
                return NSLocalizedString("droppedNow", comment: "")
                
            } else {
                return NSLocalizedString("droppedB", comment: "") + "\(secondsAgo)" + NSLocalizedString("droppedSecondsA", comment: "")
                
            }
        } else if secondsAgo < hour {
            let min = secondsAgo/minute
            if min == 1{
                return NSLocalizedString("droppedB", comment: "") + "\(min)" + NSLocalizedString("droppedMinuteA", comment: "")
                
            } else {
                return NSLocalizedString("droppedB", comment: "") + "\(min)" + NSLocalizedString("droppedMinutesA", comment: "")
                
            }
        } else if secondsAgo < day {
            let hr = secondsAgo/hour
            if hr == 1{
                return NSLocalizedString("droppedB", comment: "") + "\(hr)" + NSLocalizedString("droppedHourA", comment: "")
                
            } else {
                return NSLocalizedString("droppedB", comment: "") + "\(hr)" + NSLocalizedString("droppedHoursA", comment: "")
                
            }
        } else if secondsAgo < week {
            let day = secondsAgo/day
            if day == 1{
                return NSLocalizedString("droppedB", comment: "") + "\(day)" + NSLocalizedString("droppedDayA", comment: "")
                
            } else {
                return NSLocalizedString("droppedB", comment: "") + "\(day)" + NSLocalizedString("droppedDaysA", comment: "")
                
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = NSLocalizedString("fullDateFormat", comment: "")
            formatter.locale = Locale(identifier: NSLocalizedString("localeIdentifier", comment: ""))
            let strDate: String = formatter.string(from: date)
            return strDate
            
        }
    }
    
}
