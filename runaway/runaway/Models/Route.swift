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
    var ratingByLevel: [Double]
    var listOfRatings: [[Rating]]
    
    // CONSTRUCTOR WITH OBJECTID (pull from PARSE database)
    init(objectId: String, startLocation: String, endLocation: String, startLat: Double, startLng: Double, endLat: Double, endLng: Double, distance: Double, difficultyLevel: Int){
        self.objectId = objectId
        self.distance = distance
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startLat = startLat
        self.startLng = startLng
        self.endLat = endLat
        self.endLng = endLng
        self.difficultyLevel = difficultyLevel
        self.ratingByLevel = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        self.listOfRatings = [[], [], [], [], [], []]
        
    }
    
    // CONSTRUCTOR WITHOUT OBJECTID (manual construction)
    init(startLocation: String, startLat: Double, startLng: Double, endLocation: String, endLat: Double, endLng: Double){
        self.startLocation = startLocation
        self.startLat = startLat
        self.startLng = startLng
        self.endLocation = endLocation
        self.endLat = endLat
        self.endLng = endLng

        self.objectId = ""
        self.distance = 0
        self.difficultyLevel = 0
        
        self.ratingByLevel = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        self.listOfRatings = [[], [], [], [], [], []]
        // generates location Strings, distance, and difficulty
        generateFieldsForNewInput()
    }
    
    
    private func generateFieldsForNewInput(){
        let startPoint = getStartPoint()
        let endPoint = getEndPoint()
        let meters = startPoint.distance(from: endPoint) // Not sure if route distance or direct distance
        self.distance = meters * 0.000621371 // in miles
        self.difficultyLevel = calculateDifficulty(distance: self.distance)
        //self.startLocation = getLocationString(latitude: self.startLat, longitude: self.startLng)
        //self.endLocation = getLocationString(latitude: self.endLat, longitude: self.endLng)
    }
    
    
    // Calculates difficulty of route based on distance
    private func calculateDifficulty(distance: Double) -> Int {
        if distance <= 1.5{
            // 1.5 miles at 10min/miles = 15 miutes
            return 1
        }
        else if distance <= 3{
            // 3 miles at 10min/miles = 30 miutes
            return 2
        }
        else if distance <= 6{
            // 6 miles at 10min/miles = 60 miutes
            return 3
        }
        else if distance <= 9{
            // 9 miles at 10min/miles = 90 miutes
            return 4
        }
        else if distance <= 12{
            // 12 miles at 10min/miles = 120 miutes
            return 5
        }
        
        // TODO: Add more cases later
        return 6
    }
    
    
    private func alreadyExists() -> Bool{
        if self.objectId == "" {
            return false
        }
        return true
    }

    
    func pushToDatabase(){
        if alreadyExists(){
            // If manually input start&end LAT/LNG, need to update distance/difficulty
            let query = PFQuery(className: "Route")
            query.whereKey("objectId", equalTo: self.objectId)
            query.findObjectsInBackground{ (routes, error) in
                if error != nil {
                    print("Error: Could not update database.")
                }
                else if routes?.count != 0 {
                    routes![0]["startLocation"] = self.startLocation
                    routes![0]["endLocation"] = self.endLocation
                    routes![0]["distance"] = self.distance
                    routes![0]["difficultyLevel"] = self.difficultyLevel
                    routes![0].saveInBackground()
                }
            }
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
    
    
    // Generates location in City, State format
    func getLocationString(latitude: Double, longitude: Double) -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation()
        var currentCity = ""
        var currentState = ""
        var finalString = ""
        geocoder.reverseGeocodeLocation(location, completionHandler:
            {
                placemarks, error -> Void in

                // Place details
                guard let placeMark = placemarks?.first else { return }

                // city
                if (placeMark.locality != nil) {
                    print(currentCity)
                    currentCity = placeMark.locality ?? ""
                }
                // state
                if (placeMark.administrativeArea != nil){
                    currentState = placeMark.administrativeArea ?? ""
                }
                
                finalString = "\(currentCity), \(currentState)"
                
        })
        return finalString
        
    }
    func getStartPoint() -> CLLocation{
        return CLLocation(latitude: self.startLat, longitude: startLng)
    }
    func getEndPoint() -> CLLocation{
        return CLLocation(latitude: self.endLat, longitude: endLng)
    }
    func getRating(userLevel: Int) -> Double{
        return ratingByLevel[userLevel-1]
    }
    func newRating(rating: Rating){
        let list = rating.getUser()["difficultyLevel"] as! Int - 1
        
        var oldRating = ratingByLevel[list] // average
        oldRating *= Double(listOfRatings[list].count) // sum
        
        listOfRatings[list].append(rating) // new count
        
        var newRating = oldRating + Double(rating.rating) // new sum
        newRating /= Double(listOfRatings.count) // new average
        
        ratingByLevel[list] = newRating
    }
    
}
