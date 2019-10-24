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
    // walkthrough images
    let slide1 = UIImage(named: NSLocalizedString("slide1", comment: ""))
    let slide2 = UIImage(named: NSLocalizedString("slide2", comment: ""))
    let slide3 = UIImage(named: NSLocalizedString("slide3", comment: ""))
    
    // custom colors
    let customClearBlue = UIColor(rgb: 0x57A1FF)
    let customWhiteBlue = UIColor(rgb: 0x6dd5ed)
    let customDarkBlue = UIColor(rgb: 0x033542)
    let customRed = UIColor(rgb: 0xFB6060)
    let customFlashGreen = UIColor(rgb: 0x41E08D)
    let customGreen = UIColor(rgb: 0x5BD999)
    let customClearGrey = UIColor(rgb: 0xF4F8FB)
    let customLightGrey = UIColor(rgb: 0xEFEFF4)
    let customGrey = UIColor(rgb: 0xC5C7D2)
    let customDarkGrey = UIColor(rgb: 0x606060)
    let customMilkyWhite = UIColor(rgb: 0xECF2FF)
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
    
    // event images
    let eventJellyfishs = UIImage(named: "jellyfishs")
    let eventDivers = UIImage(named: "divers")
    let eventWaste = UIImage(named: "waste")
    let eventWarning = UIImage(named: "warning_black")
    let eventDolphins = UIImage(named: "dolphins")
    let eventDestination = UIImage(named: "destination")
    
    // default profile picture urls
    let defaultPictureUrl = "https://firebasestorage.googleapis.com/v0/b/oceanshare-1519985626980.appspot.com/o/profile_pictures%2FA4JzILjrHFfDQJyR5YrREBDmRzy2.png?alt=media&token=c27ea0fc-dcf2-4acf-a78a-1e49404f9f93"
    
    // oceanshare website url
    let websiteUrl = "https://sagotg.github.io/OceanShare/"
    
    // oceanshare api url
    let apiUrl = "https://oceanshare.cleverapps.io/api/weather"
    
    // default event descriptions
    let descJellyfishs = NSLocalizedString("descJellyfishs", comment: "")
    let descDivers = NSLocalizedString("descDivers", comment: "")
    let descWaste = NSLocalizedString("descWaste", comment: "")
    let descWarning = NSLocalizedString("descWarning", comment: "")
    let descDolphins = NSLocalizedString("descDolphins", comment: "")
    let descDestination = NSLocalizedString("descDestination", comment: "")
    
    // header messages
    let msgJellyfishs = NSLocalizedString("msgJellyfishs", comment: "")
    let msgDivers = NSLocalizedString("msgDivers", comment: "")
    let msgWaste = NSLocalizedString("msgWaste", comment: "")
    let msgWarning = NSLocalizedString("msgWarning", comment: "")
    let msgDolphins = NSLocalizedString("msgDolphins", comment: "")
    let msgDestination = NSLocalizedString("msgDestination", comment: "")
    let msgWeather = NSLocalizedString("msgWeather", comment: "")
    let msgEventLimit = NSLocalizedString("msgEventLimit", comment: "")
    let msgDistanceLimit = NSLocalizedString("msgDistanceLimit", comment: "")
    let msgEarthLimit = NSLocalizedString("msgEarthLimit", comment: "")
    let msgDropSuccess = NSLocalizedString("msgDropSuccess", comment: "")
    let msgDeleteSuccess = NSLocalizedString("msgDeleteSuccess", comment: "")
    
    // tokens
    let apiBearer = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjF9.Vcp2grZ53t_OG3jwSXsRwfc_UUjboNgZarkAGiX0jgM"
    
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
    let trace11 = "getDroppedIconByUser" // HomeViewController
    let trace12 = "getTagsFromServer" // HomeViewController
}
