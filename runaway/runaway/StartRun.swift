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
    
    // UI Components
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
    
    
    // Logic Components
    var routesSegments: [Segments] = [] //array of routes
    var routesSegmentIds: [Int] = []
    var filteredRouteSegments: [Segments] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRoutes()
        //print(self.routesSegments)
    }

    
    @IBAction func distanceSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        distanceLabel.text = "\(currentValue)"
    }
    
    @IBAction func distanceSliderValueChosen(_ sender: UISlider) {
        filterRoutesByDistance(distance: Double(sender.value) )
        print("\nFiltered Routes (Id, TotalDistance, DistanceAway):")
        for r in filteredRouteSegments{
            let distanceInMiles = r.distance / 1000 * 0.621371
            let distanceAway = r.distanceAway / 1000 * 0.621371
            print(String(format: "%10.d \t %8.2f miles \t %8.2f", r.stravaDataId, distanceInMiles, distanceAway))
        }
    }
    
    @IBAction func inclineSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
            
        inclineLabel.text = "\(currentValue)"
    }
    
    
    func getRoutes() {
        let long = Home.currentLocation!.coordinate.longitude
        let lat = Home.currentLocation!.coordinate.latitude
        
        // Not sure how the bounds are supposed to be (fix this if needed)
        let northeastBounds = "[\(lat),\(long),\(lat+3),\(long+3)]"
        let northwestBounds = "[\(lat),\(long-3),\(lat+3),\(long)]"
        let southwestBounds = "[\(lat-3),\(long-3),\(lat),\(long)]"
        let southeastBounds = "[\(lat-3),\(long),\(lat),\(long+3)]"
        
        print("\n")
        getRoutesFromBounds(bounds: northeastBounds, directionString: "NORTH_EAST")
        getRoutesFromBounds(bounds: northwestBounds, directionString: "NORTH_WEST" )
        getRoutesFromBounds(bounds: southwestBounds, directionString: "SOUTH_WEST")
        getRoutesFromBounds(bounds: southeastBounds, directionString: "SOUTH_EAST")
    }
    
    
    func getRoutesFromBounds(bounds: String, directionString: String){
        let accessToken = LogIn.accessToken
        let parameters: [String: Any] = ["access_token": accessToken, "bounds": bounds, "activity_type": "running"]
        AF.request("https://www.strava.com/api/v3/segments/explore", method: .get, parameters: parameters).response { response in
            guard let data = response.data else { return }
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print("ALL NEW SEGMENTS IN \(directionString) AREA: ")
            var count=0
            let seg = dataDictionary["segments"] as! [AnyObject]
                for key in seg{
                    
                    // Prevent duplicates
                    let id = key["id"] as! Int
                    if self.routesSegmentIds.contains(id){
                        continue
                    }
                    
                    //print(dataDictionary)
                    let dist = key["distance"] as! Double
                    let s = key["start_latlng"] as! NSArray
                    let e = key["end_latlng"] as! NSArray
                    
                    //making coords for starting and ending point
                    let start_loc = CLLocation(latitude: s[0] as! CLLocationDegrees, longitude: s[1] as! CLLocationDegrees)
                    let end_loc = CLLocation(latitude: e[0] as! CLLocationDegrees, longitude: e[1] as! CLLocationDegrees)
                    let distanceAway = self.getDistanceAway(location: start_loc)
                    
                    // make segement object
                    let curr_seg = Segments(stravaDataId: id, distance: dist, distanceAway: distanceAway, start: start_loc, end: end_loc)
                
                    //let curr_seg = Segments(d:dist, slat: s[0] as! Double, slong: s[1] as! Double, elat: e[0] as! Double, elong: e[1] as! Double)
                    self.routesSegments.append(curr_seg)
                    self.routesSegmentIds.append(id)
                    count+=1
                    
                }
            self.sortSegments()
            //print(self.routesSegments)
        }
    }
    
    func getDistanceAway(location: CLLocation) -> Double{
        let userLoc = CLLocation(
            latitude:Home.currentLocation!.coordinate.latitude,
            longitude:Home.currentLocation!.coordinate.longitude
        )
        return location.distance(from: userLoc)
    }
    
    func sortSegments(){
//        let userLoc: CLLocation = CLLocation(latitude:Home.currentLocation!.coordinate.latitude,longitude:Home.currentLocation!.coordinate.longitude)
//
//        let sortedSegs = self.routesSegments.sorted(by: {$0.startLoc.distance(from: userLoc) < $1.startLoc.distance(from: userLoc)})
//        self.routesSegments = sortedSegs
        let sortedSegs = self.routesSegments.sorted(by: {$0.distanceAway < $1.distanceAway})
        self.routesSegments = sortedSegs
        print("\tsorted count = \(sortedSegs.count) normal count = \(self.routesSegments.count)")
    }
    
    func filterRoutesByDistance(distance: Double){
        // reset filtered segments
        filteredRouteSegments = []
        
        for r in routesSegments{
            
            //convert meters to miles
            let distanceInMiles = r.distance / 1000 * 0.621371
            if distanceInMiles <= distance{
                filteredRouteSegments.append(r)
            }
        }
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
    
    

}
