//
//  SearchRun.swift
//  runaway
//
//  Created by Kay Lab on 2/13/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import Parse
import CoreLocation

class SearchRun : UIViewController {
    
    
    /*
     To test,
     - SignIn with a user that has a preferedDifficulty
     - Choose a TEST_LOCATION index for a CURRENT_LOCATION
     
     To add more test locations
     - Delete all Route rows in Parse Database
     - Add Name, Lat, and Lng in TEST_LOCATIONS
     - Uncomment generateTestRoutes() in viewDidLoad()
     - Comment generateTestRoutes() again after building
     */
    
    
    /*** UI Memvbers ***/
    @IBOutlet weak var suggestedCount: UILabel!
    @IBOutlet weak var startLocation: UILabel!
    @IBOutlet weak var endLocation: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var difficulty: UILabel!
    @IBAction func previousButton(_ sender: UIButton) {
        suggestedIndex -= 1
        updateUI()
    }
    @IBAction func nextButton(_ sender: UIButton) {
        suggestedIndex += 1
        updateUI()
    }
    
    /*** TestLocation Members ***/
    var testRoutesLoaded = true
    struct testLocation {
        var name : String
        var latitude : Double
        var longitude : Double
    }
    let TEST_LOCATIONS = [
        testLocation(name: "PaloVerdeHouse", latitude: 33.639881, longitude: -117.830861),
        testLocation(name: "MesaCourt", latitude: 33.65057, longitude: -117.84589),
        testLocation(name: "DiamondJamboree", latitude: 33.688465, longitude: -117.832039),
        testLocation(name: "CostCoTechDr", latitude: 33.66167, longitude: -117.743702),
        testLocation(name: "IrvineSpectrum", latitude: 33.6501049, longitude: -117.7430505),
        testLocation(name: "SouthCoastPlaza", latitude: 33.690939, longitude: -117.885602)
    ]
    
    /*** Algorithm Members ***/
    var suggestionsList : [Route] = []
    var suggestedIndex : Int = -1
    let CURRENT_LOCATION : Int = 5
    var currentPoint : CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ONLY UNCOMMENT AFTER DELETING ALL ROUTE ROWS IN DATABASE
        // COMMENT IT BACK RIGHT AFTER
        //generateTestRoutes()
        
        currentPoint = CLLocation(
            latitude: TEST_LOCATIONS[CURRENT_LOCATION].latitude,
            longitude: TEST_LOCATIONS[CURRENT_LOCATION].longitude
        )
        getSuggestion()
    }
    
    
    
    /**** Suggestion Algorithm ****/
    
    // Struct used to store useful user data fields
    // locally into an instance that can be accessed
    // multiple times
    struct UserPreferences {
        var difficultyLevel : Int
        //var incline : Double
    }
    
    // Function called to get updated preferences
    func getUserPreferences() -> UserPreferences {
        
        var difficulty = 0
        let currentUser = PFUser.current()
        if currentUser != nil {
            difficulty = currentUser?["difficultyLevel"] as! Int
        } else {
            print("Error: getUserPreferences()")
        }
        
        // For now, the only preference we're testing
        // with is users difficultyLevel
        return UserPreferences(
            difficultyLevel: difficulty
        )
    }
    
    // Function uses userPreferences object to
    // suggest a route
    func suggestRoute(userPref: UserPreferences) {
        let query = PFQuery(className: "Route")
        query.findObjectsInBackground{ (routes, error) in
            if routes?.count != 0 {
                for route in routes!{
                    // if currentPoint is at startLocation of a route
                    if (route["startLat"] as! Double == self.currentPoint!.coordinate.latitude) &&
                        (route["startLng"] as! Double == self.currentPoint!.coordinate.longitude) {
                        let r = Route(
                            objectId: route.objectId!,
                            startLocation: route["startLocation"] as! String,
                            endLocation: route["endLocation"] as! String,
                            startLat: route["startLat"] as! Double,
                            startLng: route["startLng"] as! Double,
                            endLat: route["endLat"] as! Double,
                            endLng: route["endLng"] as! Double,
                            distance: route["distance"] as! Double,
                            difficultyLevel: route["difficultyLevel"] as! Int
                        )
                        self.suggestionsList.append(r)
                    }
                    // if currentPoint is at endLocation of a route
                    else if (route["endLat"] as! Double == self.currentPoint!.coordinate.latitude) &&
                        (route["endLng"] as! Double == self.currentPoint!.coordinate.longitude) {
                        let r = Route(
                            objectId: route.objectId!,
                            startLocation: route["endLocation"] as! String,
                            endLocation: route["startLocation"] as! String,
                            startLat: route["endLat"] as! Double,
                            startLng: route["endLng"] as! Double,
                            endLat: route["startLat"] as! Double,
                            endLng: route["startLng"] as! Double,
                            distance: route["distance"] as! Double,
                            difficultyLevel: route["difficultyLevel"] as! Int
                        )
                        self.suggestionsList.append(r)
                    }
                }
            }
            self.updateUI()
        }
    }
    
    func getSuggestion(){
        while !testRoutesLoaded {}
        self.suggestRoute(userPref: getUserPreferences())
    }

    func updateUI(){
        if !suggestionsList.isEmpty{
            if suggestedIndex < 0 {
                suggestedIndex = 0
            }
            else if suggestedIndex > suggestionsList.count-1{
                suggestedIndex = suggestionsList.count-1
            }
            self.suggestedCount.text = "( \(suggestedIndex+1) / \(suggestionsList.count) )"
            self.startLocation.text = suggestionsList[suggestedIndex].startLocation
            self.endLocation.text = suggestionsList[suggestedIndex].endLocation
            self.distance.text = String(format: "%.1f miles", suggestionsList[suggestedIndex].distance)
            self.difficulty.text = String(format: "%d", suggestionsList[suggestedIndex].difficultyLevel)
        }
        else
        {
            self.suggestedCount.text = "( 0 / 0 )"
            self.startLocation.text = "n\\a"
            self.endLocation.text = "n\\a"
            self.distance.text = "n\\a"
            self.difficulty.text = "n\\a"
        }
    }
    
    
    /**** Testing Functions ****/
    
    func generateTestRoutes(){
        self.testRoutesLoaded = false
        
        for i in 0...TEST_LOCATIONS.count-1-1{
            for j in (i+1)...TEST_LOCATIONS.count-1{
                let newRoute = Route(
                    startLocation: TEST_LOCATIONS[i].name,
                    startLat: TEST_LOCATIONS[i].latitude,
                    startLng: TEST_LOCATIONS[i].longitude,
                    endLocation: TEST_LOCATIONS[j].name,
                    endLat: TEST_LOCATIONS[j].latitude,
                    endLng: TEST_LOCATIONS[j].longitude)
                newRoute.pushToDatabase()
            }
        }
        self.testRoutesLoaded = true
    }
}
