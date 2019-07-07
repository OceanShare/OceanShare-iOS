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

class WeatherViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var airTemperatureLabel: UILabel!
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
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        marequete()
    }
    
    func marequete() {
        let param: Parameters = [
            "lat": 2,
            "lng": 48]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjF9.Vcp2grZ53t_OG3jwSXsRwfc_UUjboNgZarkAGiX0jgM" ]
        
        let a = AF.request("http://35.198.134.25:5000/api/weather",
                           method: .get,
                           parameters: param,
                           encoding: URLEncoding.default,
                           //encoding: JSONEncoding.default,
                           headers: headers).validate(statusCode: 200..<500).responseJSON(completionHandler: {response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
            case .failure(let error):
                print(error)
            }})
        print(a)
        
        /*****/
        
        /*let body: NSMutableDictionary? = [
            "lat": "2",
            "lng": "48"]
        
        let url = NSURL(string: "http://35.198.134.25:5000/api/weather" as String)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjF9.Vcp2grZ53t_OG3jwSXsRwfc_UUjboNgZarkAGiX0jgM", forHTTPHeaderField: "Authorization")
        let data = try! JSONSerialization.data(withJSONObject: body!, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        if let json = json {
            print(json)
        }
        request.httpBody = json!.data(using: String.Encoding.utf8.rawValue)
        let alamoRequest = AF.request(request as URLRequestConvertible)
        alamoRequest.validate(statusCode: 200..<300)
        alamoRequest.responseString { response in
            
            switch response.result {
            case .success(let value):
                let test = JSON(value)
                print("JSON: \(test)")
            case .failure(let error):
                print(error)
            }
        }*/
    }
    
}

