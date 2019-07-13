//
//  WeatherViewController.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 31/12/2018.
//  Copyright © 2018 Joseph Pereniguez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit
import CoreLocation


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
    
    let locationManager = CLLocationManager()
    var currentLatitude: Double = 0.0
    var currentLongitude: Double = 0.0
    
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
    
        getWeatherFromLocation()
        
    }
    
    // MARL: - Data Handlers
    
    func transformData(rawData: JSON) {
        print("rawData :\(rawData)")
        if let data = rawData["weather"].string {
            let dataAsData = data.data(using: .utf8)!
            let dataAsJson = JSON(dataAsData)
            print(dataAsJson)

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
    
    func getWeatherFromLocation() {
        let param: Parameters = [
            "lat": String(self.currentLatitude),
            "lng": String(self.currentLongitude)]

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjF9.Vcp2grZ53t_OG3jwSXsRwfc_UUjboNgZarkAGiX0jgM" ]
        
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
    }
    
    // MARK - Setters
    
    func didGetWeather(weather: Weather) {
        DispatchQueue.main.async {
            // TODO image
            self.airTemperatureLabel.text = "\(Int(round(weather.tempCelsius))) °C"
            self.weatherDescriptionLabel.text = weather.weatherDescription
            self.longitudeLabel.text = String(format:"%f", weather.longitude)
            self.latitudeLabel.text = String(format:"%f", weather.latitude)
            // TODO sunrise
            self.sunriseLabel.text = "--:--"
            // TODO sunset
            self.sunsetLabel.text = "--:--"
            self.rainRiskLabel.text = "\(weather.cloudCover) %"
            // TODO Watertemp
            self.waterTemperatureLabel.text = "-- °C"
            self.windLabel.text = "\((weather.windSpeed * (60*60) / 1000)) km/h"
            self.humidityLabel.text = "\(weather.humidity) %"
            
            if weather.visibility != nil {
                self.visibilityLabel.text = "\(Double(weather.visibility! / 1000)) km"
            } else {
                self.visibilityLabel.text = "-- km"
            }
            // TODO UV
            self.uvIndiceLabel.text = "--"
            
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

