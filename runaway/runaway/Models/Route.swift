//
//  Route.swift
//  runaway
//
//  Created by Kay Lab on 2/12/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import Parse

class Route {
    var objectId: String
    var distance: Double
    var startLocation: String
    var endLocation: String
    var startLat: Double
    var startLng: Double
    var endLat: Double
    var endLng: Double
    var difficultyLevel: Int
    
    // CONSTRUCTOR WITH OBJECTID (if pulled from PARSE)
    init(objectId: String, distance: Double, startLocation: String, endLocation: String, startLat: Double, startLng: Double, endLat: Double, endLng: Double){
        self.objectId = objectId
        self.distance = distance
        self.startLocation = startLocation
        self.endLocation = endLocation
        
        // Parse only allows 1 geopoint ):
        self.startLat = startLat
        self.startLng = startLng
        self.endLat = endLat
        self.endLng = endLng
        self.difficultyLevel = 0
        self.difficultyLevel = calculateDifficulty()
    }
    // CONSTRUCTOR WITHOUT OBJECTID (if pulled from STRAVA)
    init(distance: Double, startLocation: String, endLocation: String, startLat: Double, startLng: Double, endLat: Double, endLng: Double){
        self.objectId = ""
        self.distance = distance
        self.startLocation = startLocation
        self.endLocation = endLocation
        
        // Parse only allows 1 geopoint ):
        self.startLat = startLat
        self.startLng = startLng
        self.endLat = endLat
        self.endLng = endLng
        self.difficultyLevel = 0
        self.difficultyLevel = calculateDifficulty()
        
    }
    
    // Calculates difficulty of route based on distance
    func calculateDifficulty() -> Int {
        if self.distance <= 1.5{
            // 1.5 miles at 10min/miles = 15 miutes
            return 1
        }
        else if self.distance <= 3{
            // 3 miles at 10min/miles = 30 miutes
            return 2
        }
        else if self.distance <= 6{
            // 6 miles at 10min/miles = 60 miutes
            return 3
        }
        else if self.distance <= 9{
            // 9 miles at 10min/miles = 90 miutes
            return 4
        }
        else if self.distance <= 12{
            // 12 miles at 10min/miles = 120 miutes
            return 5
        }
        
        // TODO: Add more cases later
        return 6
    }
    

    func pushToDatabase(){
        if alreadyExists(){
            return
        }
        let parseObject = PFObject(className: "Route")

        parseObject["startLocation"] = self.startLocation
        parseObject["endLocation"] = self.endLocation
        parseObject["startLat"] = self.startLat
        parseObject["startLng"] = self.startLng
        parseObject["endLat"] = self.endLat
        parseObject["endLng"] = self.endLng
        parseObject["distance"] = self.distance
        parseObject["difficultyLevel"] = self.difficultyLevel

        // Saves the new object.
        parseObject.saveInBackground {
          (success: Bool, error: Error?) in
          if (success) {
            print("Successfully push to database.")
          } else {
            print("Error: Could not push to database.")
          }
        }
    }
    
    func getStartGeoPoint() -> PFGeoPoint{
        return PFGeoPoint(latitude: self.startLat, longitude: startLng)
    }
    func getEndGeoPoint() -> PFGeoPoint{
        return PFGeoPoint(latitude: self.endLat, longitude: endLng)
    }
    func alreadyExists() -> Bool{
        if self.objectId == "" {
            return false
        }
        return true
    }
}
