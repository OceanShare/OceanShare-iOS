//
//  Registry.swift
//  OceanShare
//
//  Created by Joseph Pereniguez on 24/07/2019.
//  Copyright © 2019 Joseph Pereniguez. All rights reserved.
//

import Foundation
import UIKit

struct Registry {
    // colors
    let customClearBlue = UIColor(rgb: 0x57A1FF)
    let customWhiteBlue = UIColor(rgb: 0x6dd5ed)
    let customDarkBlue = UIColor(rgb: 0x033542)
    let customRed = UIColor(rgb: 0xFB6060)
    let customFlashGreen = UIColor(rgb: 0x41E08D)
    let customGreen = UIColor(rgb: 0x5BD999)
    let customClearGrey = UIColor(rgb: 0xF4F8FB)
    let customGrey = UIColor(rgb: 0xC5C7D2)
    let customDarkGrey = UIColor(rgb: 0x606060)
    let customMilkyWhite = UIColor(rgb: 0xD3F2FF)
    let customWhite = UIColor(rgb: 0xFFFFFF)
    let customBlack = UIColor(rgb: 0x000000)
    
    // weather images
    let iconStorm = UIImage(named: "storm")
    let iconSnow = UIImage(named: "snow")
    let iconMoon = UIImage(named: "moon")
    let iconRain = UIImage(named: "rain")
    let iconNightRain = UIImage(named: "night_rain")
    let iconLightRain = UIImage(named: "light_rain")
    let iconHail = UIImage(named: "hail")
    let iconCloud = UIImage(named: "cloud")
    let iconNightCloud = UIImage(named: "night_cloud")
    let iconClouds = UIImage(named: "clouds")
    let iconOvercastCloud = UIImage(named: "overcast_cloud")
    let iconTornado = UIImage(named: "tornado")
    let iconSun = UIImage(named: "sunny")
    let iconThermometer = UIImage(named: "thermometer")
    
    // default urls
    let defaultPictureUrl = "https://scontent-lax3-2.xx.fbcdn.net/v/t1.0-1/p480x480/29187034_1467064540082381_56763327166021632_n.jpg?_nc_cat=107&_nc_ht=scontent-lax3-2.xx&oh=7c2e6e423e8bd35727d754d1c47059d6&oe=5D33AACC"
    let websiteUrl = "https://sagotg.github.io/OceanShare/"
    
    // performance traces
    let trace1 = "getUserNameById" // HomeViewController
    let trace2 = "getWeatherFromSelectedLocation" // HomeViewController
    let trace3 = "fetchUserPictureFromProfileView" // ProfileViewController
    let trace4 = "getWeatherFromCurrentLocation" // WeatherViewController
    let trace5 = "acceptChangeName" // InformationViewController
    let trace6 = "acceptChangeEmail" // InformationViewController
    let trace7 = "acceptChangePassword" // InformationViewController
    let trace8 = "acceptChangeShipName" // InformationViewController
    let trace9 = "acceptDeletion" // InformationViewController
    let trace10 = "fetchUserInfoFromInformationView" // InformationViewController
}
