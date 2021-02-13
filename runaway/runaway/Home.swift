//
//  Home.swift
//  runaway
//
//  Created by Maya Schwarz on 2/6/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreLocation
import MapKit



class Home: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let LocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var suggestedRoutes: [CLLocationCoordinate2D] = []
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherSummary: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var routeDistance: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        //setUpLocation()
        getSuggestion()
    }
    
    
    // Location
    func setUpLocation() {
        LocationManager.delegate = self
        LocationManager.requestWhenInUseAuthorization()
        LocationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation==nil{
            currentLocation = locations.first
            LocationManager.stopUpdatingLocation()
            displayCityForLocation()
            requestWeatherForLocation()
            displayRoutes()
        }
    }
    
    func displayCityForLocation() {
            // Use the last reported location.
            guard let currentLocation = currentLocation else{
                return
            }
            let long = currentLocation.coordinate.longitude
            let lat = currentLocation.coordinate.latitude
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: lat, longitude: long)
            var currentCity = ""
            var currentState = ""
            
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
                    
                    self.city.text = currentCity+", "+currentState
                    
            })
            
        
    }
    
    func requestWeatherForLocation(){
        guard let currentLocation = currentLocation else{
            return
        }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        print("\(long) | \(lat)")
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&units=imperial&appid=64611f4ad8a75ee7950a4befef783919")!
       
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print(data)
            let main = dataDictionary["main"] as! [String:Any]
            let temp = main["temp"] as! NSNumber
            print(temp)
            let sumObj = dataDictionary["weather"] as! NSArray
            let summary = sumObj[0] as! NSDictionary
            let description = summary["description"] as! String
            print(description)

            self.temperature.text = temp.stringValue+"°F"
            self.weatherSummary.text = description

           }
        }
        task.resume()
        
    }
    
    
    func displayRoutes(){
        findRoutes()
        
        //manually adding destination
        let sourceCoordinates = CLLocationCoordinate2D(latitude: (currentLocation?.coordinate.latitude)!,longitude: (currentLocation?.coordinate.longitude)!)
        let destCoordinates = self.suggestedRoutes.first as! CLLocationCoordinate2D
        
        let sourcePlacemark = MKPlacemark(coordinate:sourceCoordinates)
        let destPlacemark = MKPlacemark(coordinate:destCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem =  MKMapItem(placemark: destPlacemark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .walking
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate{(response, error) in
            guard let response = response else{
                if let error = error{
                    print("something is wrong ): \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.map.addOverlay(route.polyline)
            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated:true)

        }
        
        //get distance from Strava API
        self.routeDistance.text = "2 miles"
        
    
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.lineWidth = 10
        render.strokeColor = .blue
        return render
    }
    
    
    func findRoutes(){
        //get routes from Strava API
        //create CLLocationCoordinate2D object for each route and append to self.suggestedRoutes
        let destCoordinates = CLLocationCoordinate2D(latitude: 37.331193,longitude: -122.031401)
        self.suggestedRoutes.append(destCoordinates)

    }
    
    
    
    
    
    
    
    /**** Suggestion Algorithm ****/
        
    @IBOutlet weak var suggestedText: UILabel!
    var suggestions = Array<String>()
    
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
//        guard let currentLocation = currentLocation else{
//            return
//        }
//
//        let currentPoint = PFGeoPoint(
//            latitude: currentLocation.coordinate.latitude,
//            longitude: currentLocation.coordinate.longitude
//        )

        let query = PFQuery(className: "Route")
        query.whereKey("difficultyLevel", lessThanOrEqualTo: userPref.difficultyLevel)
        query.findObjectsInBackground{ (routes, error) in
            if routes?.count != 0 {
                for route in routes!{
                    var s = route["startLocation"] as! String
                    s += " to "
                    s += route["endLocation"] as! String
                    self.suggestions.append(s)
//                    let startPoint = PFGeoPoint(
//                        latitude: route["startLat"] as! Double,
//                        longitude: route["startLng"] as! Double
//                    )
//                    if currentPoint.distanceInMiles(to: startPoint) < 0.01 {
//                        self.suggestions.append(route["endLocation"] as! String)
//                    }
                }
                self.suggestedText.text = "\(self.suggestions[0]) (\(self.suggestions.count-1) others)"
            }
        }
        
    }
    
    func getSuggestion(){
        
        self.suggestRoute(userPref: getUserPreferences())
        
        // Not sure if this is necessary?
        DispatchQueue.main.async { [weak self] in
            self?.updateSuggestion()
        }
    }

    func updateSuggestion(){
        if suggestions.isEmpty{
            suggestedText.text = "No routes"
        }
        else{
            self.suggestedText.text = "\(self.suggestions[0]) (\(self.suggestions.count-1) others)"
        }
    }
    
}



