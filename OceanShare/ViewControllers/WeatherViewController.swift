//
//  WeatherViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 31/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import MapKit
import CoreLocation
import FirebasePerformance

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var airTemperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var rainRiskLabel: UILabel!
    @IBOutlet weak var waterTemperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var uvIndiceLabel: UILabel!
    
    // MARK: - Variables
    
    // globals
    let locationManager = CLLocationManager()
    var currentLatitude: Double = 0.0
    var currentLongitude: Double = 0.0
    var uvGlobal: String!
    
    // classes
    let weather = Weather.self
    let registry = Registry()
    
    // MARK: - View's Managers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        getWeatherFromCurrentLocation()
        
    }
    
    // MARL: - Data Handlers
    
    func transformData(rawData: JSON) {
        // get uv index
        if let uvData = rawData["uv"].string {
            let uvAsData = uvData.data(using: .utf8)!
            let uvAsJson = JSON(uvAsData)
            
            if let uvIndex = uvAsJson["value"].double {
                self.uvGlobal = self.weather.analyseUvIndex(uvIndex: uvIndex)
                
            } else {
                print(uvAsJson["value"].error!)
                
            }
        }
        // get weather
        if let data = rawData["weather"].string {
            let dataAsData = data.data(using: .utf8)!
            let dataAsJson = JSON(dataAsData)

            do {
                _ = try JSONSerialization.jsonObject(
                    with: dataAsData,
                    options: .mutableContainers) as! [String: AnyObject]
                
                let weather = Weather(weatherData: dataAsJson)
                self.didGetWeather(weather: weather)
            } catch let jsonError as NSError {
                self.didNotGetWeather(error: jsonError)
                
            }
        } else {
            print(rawData["weather"].error!)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.currentLatitude = locValue.latitude
        self.currentLongitude = locValue.longitude
        
    }
    
    func getWeatherFromCurrentLocation() {
        let param: Parameters = [
            "lat": String(self.currentLatitude),
            "lng": String(self.currentLongitude)]

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjF9.Vcp2grZ53t_OG3jwSXsRwfc_UUjboNgZarkAGiX0jgM" ]
        
        let trace = Performance.startTrace(name: self.registry.trace4)
        _ = AF.request("http://35.198.134.25:5000/api/weather",
                           method: .get,
                           parameters: param,
                           encoding: URLEncoding.default,
                           headers: headers).validate(statusCode: 200..<500).responseJSON(completionHandler: {response in
            switch response.result {
            case .success(let value):
                let jsonObject = JSON(value)
                self.transformData(rawData: jsonObject)
            case .failure(let error):
                print(error)
            }})
        trace?.stop()
    }
    
    // MARK - Updaters
    
    func didGetWeather(weather: Weather) {
        DispatchQueue.main.async {
            print("Value to check (weatherID -> weatherImage): ", weather.weatherID)
            self.weatherImage.image = self.weather.analyseDescription(weather: weather, registry: self.registry)
            
            self.airTemperatureLabel.text = "\(Int(round(weather.tempCelsius))) °C"
            self.weatherDescriptionLabel.text = weather.weatherDescription
            
            self.longitudeLabel.text = String(format:"%f", weather.longitude)
            self.latitudeLabel.text = String(format:"%f", weather.latitude)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.locale = Locale(identifier: "fr_GP")
            let sunriseDate: String = formatter.string(from: weather.sunrise)
            self.sunriseLabel.text = sunriseDate
            let sunsetDate: String = formatter.string(from: weather.sunset)
            self.sunsetLabel.text = sunsetDate
            
            self.rainRiskLabel.text = "\(weather.cloudCover) %"
            self.waterTemperatureLabel.text = "-- °C"
            
            // TODO: test
            //self.windLabel.text = "\(round(100 * (weather.windSpeed * ( 60 * 60 ) / 1000)) / 100) km/h"
            self.windLabel.text = self.weather.analyseWindDirection(degrees: weather.windSpeed)
            self.humidityLabel.text = "\(weather.humidity) %"
            
            if weather.visibility != nil {
                self.visibilityLabel.text = "\(round(100 * (Double(weather.visibility! / 1000))) / 100) km"
            } else {
                self.visibilityLabel.text = "-- km"
            }
            if self.uvGlobal != nil {
                self.uvIndiceLabel.text = self.uvGlobal
                
            } else {
                self.uvIndiceLabel.text = "--"
                
            }
        }
    }
    
    func didNotGetWeather(error: NSError) {
        DispatchQueue.main.async {
            self.airTemperatureLabel.text = "Unknown"
            self.weatherDescriptionLabel.text = "Unknown"
            self.longitudeLabel.text = "Unknown"
            self.latitudeLabel.text = "Unknown"
            self.sunriseLabel.text = "Unknown"
            self.sunsetLabel.text = "Unknown"
            self.rainRiskLabel.text = "Unknown"
            self.waterTemperatureLabel.text = "Unknown"
            self.windLabel.text = "Unknown"
            self.humidityLabel.text = "Unknown"
            self.visibilityLabel.text = "Unknown"
            self.uvIndiceLabel.text = "Unknown"
            
        }
        print("Error: \(error) in function didNotGetWeather (WeatherViewController.Swift).")
        
    }
    
}
