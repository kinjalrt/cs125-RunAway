//
//  StartRun.swift
//
//
//  Created by Maya Schwarz on 2/10/21.
//
import Foundation
import UIKit
import Parse
import MapKit
import Alamofire


class StartRun: UIViewController {
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var inclineSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var inclineLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    var suggestedRoutes: [CLLocationCoordinate2D] = []
    var currIndex = 0
    let LocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var routeDistance: UILabel!

    
    @IBAction func distanceSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
            
        distanceLabel.text = "\(currentValue)"
    }
    
    @IBAction func inclineSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
            
        inclineLabel.text = "\(currentValue)"
    }
    
    func displayRoutes(){
        print(currIndex)
        //manually adding destination
        let sourceCoordinates = CLLocationCoordinate2D(latitude: (currentLocation?.coordinate.latitude)!,longitude: (currentLocation?.coordinate.longitude)!)
        let destCoordinates = self.suggestedRoutes[currIndex] as! CLLocationCoordinate2D
        
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
        
        //get distance + name of route from Strava API
        self.routeDistance.text = "2 miles"
        
    
    }
    
    func findRoutes(){
        //get routes from Strava API:
        
        //create CLLocationCoordinate2D object for each route and append to self.suggestedRoutes
        
        
        
        
        //sample routes:
        var destCoordinates = CLLocationCoordinate2D(latitude: 37.331193,longitude: -122.031401)
        self.suggestedRoutes.append(destCoordinates)
        destCoordinates = CLLocationCoordinate2D(latitude: 37.330247,longitude: -122.027774)
        self.suggestedRoutes.append(destCoordinates)
        destCoordinates = CLLocationCoordinate2D(latitude: 37.326644,longitude: -122.030186)
        self.suggestedRoutes.append(destCoordinates)
        
        //init navig buttons
        prevButton.isHidden = true
        if(self.suggestedRoutes.count==1){
            prevButton.isHidden = true
        }

    }
    
    
    @IBAction func displayNextRun(_ sender: Any) {
        if(currIndex<=(self.suggestedRoutes.count-1)){
            currIndex = currIndex+1
            prevButton.isHidden = false
        }
        if(currIndex==(self.suggestedRoutes.count-1)){
            nextButton.isHidden = true
        }
        map.removeOverlays(map.overlays)
        displayRoutes()
        
    }
    
    @IBAction func displayPrevRun(_ sender: Any) {
        if(currIndex>0){
            currIndex = currIndex-1
            nextButton.isHidden = false
        }
        if(currIndex==0){
            prevButton.isHidden = true
        }
        map.removeOverlays(map.overlays)
        displayRoutes()
        
    }
    
    @IBAction func logout(_ sender: Any) {
        PFUser.logOutInBackground(block: { (error) in
        if error == nil {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                      //let Home = storyBoard.instantiateViewController(withIdentifier: "Home") as! Home
            let login=self.storyboard?.instantiateViewController(identifier:"LogIn" ) as! LogIn
            
        
            self.present(login, animated: true, completion:nil)
               
            }})
    }
    
    
    @IBAction func startRun(_ sender: Any) {
        let long = Home.currentLocation!.coordinate.longitude
        let lat = Home.currentLocation!.coordinate.latitude
        let accessToken = LogIn.accessToken
        
        //retrieve all routes in North-East area relative to current location
        let NElat = lat+3
        let NElong = long+3
        let northeastBounds = "[\(lat),\(long),\(NElat),\(NElong)]"
        var parameters: [String: Any] = ["access_token": accessToken, "bounds": northeastBounds, "activity_type": "running"]
        
        AF.request("https://www.strava.com/api/v3/segments/explore", method: .get, parameters: parameters).response { response in
            guard let data = response.data else { return }
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print("ALL SEGMENTS IN NORTH-EAST AREA: ")
            print(dataDictionary)
        }
        
        //retrieve all routes in North-West area relative to current location
        let NWlat = lat-3
        let NWlong = long+3
        let NWcurrLat = lat-3
        let northwestBounds = "[\(NWcurrLat),\(long),\(NWlat),\(NWlong)]"
        parameters = ["access_token": accessToken, "bounds": northwestBounds, "activity_type": "running"]
        
        AF.request("https://www.strava.com/api/v3/segments/explore", method: .get, parameters: parameters).response { response in
            guard let data = response.data else { return }
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print("ALL SEGMENTS IN NORTH-WEST AREA: ")
            print(dataDictionary)
        }
        
        
        //retrieve all routes in South-West area relative to current location
        let SWlat = lat-3
        let SWlong = long-3
        let southwestBounds = "[\(SWlat),\(SWlong),\(lat),\(long)]"
        parameters = ["access_token": accessToken, "bounds": southwestBounds, "activity_type": "running"]
        
        AF.request("https://www.strava.com/api/v3/segments/explore", method: .get, parameters: parameters).response { response in
            guard let data = response.data else { return }
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print("ALL SEGMENTS IN SOUTH-WEST AREA: ")
            print(dataDictionary)
        }
        
        //retrieve all routes in South-East area relative to current location
        let SElat = lat+3
        let SElong = long-3
        let southeastBounds = "[\(lat),\(SElong),\(SElat),\(long)]"
        parameters = ["access_token": accessToken, "bounds": southeastBounds, "activity_type": "running"]
        
        AF.request("https://www.strava.com/api/v3/segments/explore", method: .get, parameters: parameters).response { response in
            guard let data = response.data else { return }
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print("ALL SEGMENTS IN SOUTH-EAST AREA: ")
            print(dataDictionary)
        }
        
        
        
        
        
        
        
    }
    
    
    
    
}
