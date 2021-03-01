//
//  Segments.swift
//  runaway
//
//  Created by Vinita Santhosh on 2/28/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit

class Segments
{
    var distance:Double = 0.0
    var start_lat: Double = 0.0
    var start_long: Double = 0.0
    var end_lat: Double = 0.0
    var end_long: Double = 0.0
    
    init(d:Double,slat: Double,slong: Double,elat: Double, elong:Double) {
        distance = d
        start_lat = slat
        start_long = slong
        end_lat = elat
        end_long = elong
       }

}
