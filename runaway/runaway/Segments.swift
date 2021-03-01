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
    var distance:Double = 0.0
    //var start_lat: Double = 0.0
    //var start_long: Double = 0.0
    var startLoc: CLLocation
    var endLoc: CLLocation
    //var end_lat: Double = 0.0
    //var end_long: Double = 0.0
    
    init(d:Double,start:CLLocation, end:CLLocation) {
        distance = d
        startLoc = start
        endLoc = end
        //end_long = elong
        //startLoc = startLatLong
        
        
       }

}
