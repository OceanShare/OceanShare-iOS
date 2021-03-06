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
    let locationManager = CLLocationManager()
    var currentLatitude: Double = 0.0
    var currentLongitude: Double = 0.0
    var uvGlobal: String!
    var isLocationActivated: Bool!
    let weather = Weather.self
    let registry = Registry()
    
    // MARK: - Outlets
    
    @IBOutlet weak var weatherTitle: UILabel!
    @IBOutlet weak var weatherItem: UITabBarItem!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var airTemperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var longitudeTitle: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeTitle: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var sunriseTitle: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetTitle: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var rainRiskTitle: UILabel!
    @IBOutlet weak var rainRiskLabel: UILabel!
    @IBOutlet weak var waterTemperatureTitle: UILabel!
    @IBOutlet weak var waterTemperatureLabel: UILabel!
    @IBOutlet weak var windTitle: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityTitle: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var visibilityTitle: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var uvIndiceTitle: UILabel!
    @IBOutlet weak var uvIndiceLabel: UILabel!

    // MARK: - View's Managers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(checkLocalisationService), name: UIApplication.willEnterForegroundNotification, object: nil)
        overrideUserInterfaceStyle = .light
        setupView()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        checkLocalisationService()
        getWeatherFromCurrentLocation()
        
    }
    
    /**
    - Description - Setup the design of the view.
    */
    func setupView() {
        setupLocalizedStrings()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        } else {
            checkLocalisationService()
            
        }
    }
    
    /**
    - Description - Setup the translated labels.
    */
    func setupLocalizedStrings() {
        weatherTitle.text = NSLocalizedString("weatherTitle", comment: "")
        longitudeTitle.text = NSLocalizedString("longitudeTitle", comment: "")
        latitudeTitle.text = NSLocalizedString("latitudeTitle", comment: "")
        sunriseTitle.text = NSLocalizedString("sunriseTitle", comment: "")
        sunsetTitle.text = NSLocalizedString("sunsetTitle", comment: "")
        rainRiskTitle.text = NSLocalizedString("rainRiskTitle", comment: "")
        waterTemperatureTitle.text = NSLocalizedString("waterTemperatureTitle", comment: "")
        windTitle.text = NSLocalizedString("windTitle", comment: "")
        humidityTitle.text = NSLocalizedString("humidityTitle", comment: "")
        visibilityTitle.text = NSLocalizedString("visibilityTitle", comment: "")
        uvIndiceTitle.text = NSLocalizedString("uvIndiceTitle", comment: "")
        
    }
    
    // MARK: - Location manager
    
    /**
     - Description - Diaplays an alert if the geolocation is disable or not working.
     */
    func geolocationAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("geolocAlert", comment: ""), message: NSLocalizedString("geolocAlertDesc", comment: ""), preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("geolocAlertOne", comment: ""), style: .default) { value in
            let path = UIApplication.openSettingsURLString
            guard let settingsURL = URL(string: path), !settingsURL.absoluteString.isEmpty else {
              return
                
            }
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
           
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("geolocAlertTwo", comment: ""), style: .cancel) { value in
            self.checkLocalisationService()
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     - Description - Check if geolocation is enable or not.
     */
    @objc func checkLocalisationService() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    isLocationActivated = false
                    geolocationAlert()
                    print("-x Localisation disabled.")
                case .authorizedAlways, .authorizedWhenInUse:
                    if isLocationActivated == false {
                        isLocationActivated = true
                        dismiss(animated: false, completion: nil)
                        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
                        mainTabBarController.selectedViewController = mainTabBarController.viewControllers?[1]
                        self.present(mainTabBarController, animated: true,completion: nil)
                        print("~> Location is now activated.")
                    }
                    print("-> Localisation enabled.")
                @unknown default:
                break
            }
            } else {
                isLocationActivated = false
                geolocationAlert()
                print("-x Localisation disabled.")
        }
    }
    
    // MARK: - Data handlers
    
    /**
     - Description - Change the raw data into an understandable content.
     - Inputs - rawData `JSON`
     */
    func transformData(rawData: JSON) {
        // get uv index
        let uvData = rawData["uv"]
        let uvAsJson = JSON(uvData)
        if let uvIndex = uvAsJson["value"].double {
            self.uvGlobal = self.weather.analyseUvIndex(uvIndex: uvIndex)
            
        } else {
            print(uvAsJson["value"].error!)
            
        }
        // get weather
        let data = rawData["weather"]
        let dataAsJson = JSON(data)
        let weather = Weather(weatherData: dataAsJson)
        self.didGetWeather(weather: weather)
        
    }
    
    /**
     - Description - Update longitude and latitude in real time.
     - Inputs - manager `CLLocationManager` & locations `[CLLocation]`
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.currentLatitude = locValue.latitude
        self.currentLongitude = locValue.longitude
        
    }
    
    /**
     - Description - Get the weather from the current location.
     */
    func getWeatherFromCurrentLocation() {
        let param: Parameters = [
            "lat": String(self.currentLatitude),
            "lng": String(self.currentLongitude)]

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": self.registry.apiBearer ]
        
        let trace = Performance.startTrace(name: self.registry.trace4)
        _ = AF.request(self.registry.apiUrl,
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
    
    // MARK: - Updaters
    
    /**
     - Description - Check if  weather datas have been updated.
     - Inputs - weather `Weather`
     */
    func didGetWeather(weather: Weather) {
        DispatchQueue.main.async {
            self.weatherImage.image = self.weather.analyseDescription(weather: weather, registry: self.registry)
            
            if Defaults.getUserDetails().isCelsius == true {
                self.airTemperatureLabel.text = "\(Int(round(weather.tempCelsius))) °C"
            } else {
                self.airTemperatureLabel.text = "\(Int(round(weather.tempCelsius) * 1.8 + 32)) °F"
            }
            
            self.weatherDescriptionLabel.text = self.weather.analyseWeatherDescription(weather: weather, registry: self.registry)
            
            self.longitudeLabel.text = String(format:"%f", weather.longitude)
            self.latitudeLabel.text = String(format:"%f", weather.latitude)
            
            let formatter = DateFormatter()
            formatter.dateFormat = NSLocalizedString("dateFormat", comment: "")
            formatter.locale = Locale(identifier: NSLocalizedString("localeIdentifier", comment: ""))
            let sunriseDate: String = formatter.string(from: weather.sunrise)
            self.sunriseLabel.text = sunriseDate
            let sunsetDate: String = formatter.string(from: weather.sunset)
            self.sunsetLabel.text = sunsetDate
            
            self.rainRiskLabel.text = "\(weather.cloudCover) %"
            self.waterTemperatureLabel.text = "--"
            
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
}
