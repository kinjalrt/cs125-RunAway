//
//  Segments.swift
//  runaway
//
//  Created by Vinita Santhosh on 2/28/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class Segments
{
    var routeName: String
    var distanceAway:Double
    var stravaDataId: Int
    var distance:Double = 0.0
    //var start_lat: Double = 0.0
    //var start_long: Double = 0.0
    var startLoc: CLLocation
    var endLoc: CLLocation
    //var end_lat: Double = 0.0
    //var end_long: Double = 0.0
    var climbPriority: Int
    
    init(stravaDataId: Int, routeName: String, distance: Double, distanceAway: Double, start: CLLocation, end:CLLocation, climb: Int) {
        self.stravaDataId = stravaDataId
        self.routeName = routeName
        self.distance = distance
        self.distanceAway = distanceAway
        self.startLoc = start
        self.endLoc = end
        self.climbPriority = climb
        //end_long = elong
        //startLoc = startLatLong
       }

}
