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
    
    // default profile picture urls
    let defaultPictureUrl = "https://scontent-lax3-2.xx.fbcdn.net/v/t1.0-1/p480x480/29187034_1467064540082381_56763327166021632_n.jpg?_nc_cat=107&_nc_ht=scontent-lax3-2.xx&oh=7c2e6e423e8bd35727d754d1c47059d6&oe=5D33AACC"
    
    // oceanshare website url
    let websiteUrl = "https://sagotg.github.io/OceanShare/"
    
    // oceanshare api url
    let apiUrl = "http://35.198.134.25:5000/api/weather"
    
    // default event descriptions
    let descJellyfishs = "Jellyfish have been spotted at this location."
    let descDivers = "There are probably divers working here."
    let descWaste = "The water looks polluted here."
    let descWarning = "Someone needs help or there is a danger."
    let descDolphins = "Dolphins have been spotted in the vicinity."
    let descDestination = "Someone is going there."
    
    // header messages
    let msgJellyfishs = "Jellyfishs event selected."
    let msgDivers = "Divers event selected."
    let msgWaste = "Waste event selected."
    let msgWarning = "Warning event selected."
    let msgDolphins = "Dolphins event selected."
    let msgDestination = "Destination event selected."
    let msgWeather = "Weather information selected."
    let msgEventLimit = "Already dropped 5 events"
    let msgDistanceLimit = "Can't drop an event so far."
    let msgEarthLimit = "Can't drop markers on earth."
    let msgDropSuccess = "Your event has been dropped."
    let msgDeleteSuccess = "Event correctly deleted."
    
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
