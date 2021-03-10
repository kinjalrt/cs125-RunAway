//
//  PostRunSurvey.swift
//  runaway
//
//  Created by Vinita Santhosh on 3/6/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//


import Foundation
import UIKit
import Parse


class PostRunSurvey: UIViewController {
    //route info passed from start run page
    var route = PFObject(className: "Route")
    var routeName = ""
    var routeDist = 0.0
    
    
    var startTime = NSDate()
    var heartRate = 0
    var calories = 0.0
    var totaltime = 0.0
    var breaks = 0
    var liked = true
    var score = 0.0
    
    

    @IBOutlet weak var ratingUp: UIButton!
    @IBOutlet weak var ratingDown: UIButton!
    
    @IBOutlet weak var heartRateField: UITextField!
    @IBOutlet weak var caloriesField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //convert distance from meters to miles
        self.routeDist = routeDist / 1609.34
        print("breaks = \(self.breaks)")
        print("total time = \(self.totaltime)")
        print("dist = \(self.routeDist)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
  
    
    @IBAction func runLiked(_ sender: Any) {
        //if the user click the thumbs up button set liked to true
        // disable the like button to let user no this was selected
        //enable unlike button so they can chnage option of needed
        self.liked = true
        ratingUp.isEnabled = false
        ratingDown.isEnabled = true
    }
    
    @IBAction func runDisliked(_ sender: Any) {
        //if the user click the thumbs down button set liked to true
        // disable the unlike button to let user no this was selected
        //enable like button so they can chnage option of needed
        self.liked = false
        ratingUp.isEnabled = true
        ratingDown.isEnabled = false
    }
    
    
    @IBAction func completeSurvey(_ sender: Any) {
        //get heart rate and calories from user import
        self.heartRate = Int(heartRateField.text ??  "0") ?? 0
        calories = Double(caloriesField.text ?? "0") ?? 0.0
        
        createRun() // add run to users history
        calculateScore() //calculate score of the current run
        updateScore() // update score in the database
        
        print("Ave heartrate = \(self.heartRate)")
        print("Burnt calories = \(self.calories)")
        
        //exit page
        let vc = self.storyboard?.instantiateViewController(identifier: "Congrats" ) as! Congrats
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func calculateScore(){
        
        //calculate score based how long it took the user to run route based on the average time it takes
        let avgTime = self.routeDist * 10         // average time to run 1 mile is 10 minutes
        let timediff = avgTime/self.totaltime
        self.score += timediff
        print( " avg time is \(avgTime) and users time is \(totaltime) hence score is \(score)")
        
        //calculate heart rate score based on users age
        let currentUser = PFUser.current() as! User
        let birthDate = currentUser.birthday
        let calender = Calendar.current
        let dateComponent = calender.dateComponents([.year, .month, .day], from:birthDate, to: Date())
        let age = dateComponent.year!
        
        //values based on american heeart association recommendations for max target heart rate for age groups
        var targetHR = 0
        if age < 30 { targetHR = 170}
        if age >= 30 && age<35 { targetHR=162}
        if age >= 35 && age < 40 { targetHR=157}
        if age >= 40 && age < 45 { targetHR=153}
        if age >= 45 && age < 50 { targetHR=149}
        if age >= 50 && age<60 { targetHR=145}
        if age >= 60 { targetHR=136}
        
        //if heart rate is below max then move up else move score down
        if heartRate<=targetHR{score+=2}
        if heartRate>targetHR{score-=2}
        print( " avg hr ifor age \(age) and users time is \(self.heartRate) hence score is \(score)")
        
        // calculate score based on calories % burnt per mile
        //
        let calPerMile = (self.calories / self.routeDist) / 100
        score+=calPerMile
        print( " avg cal \(calPerMile) and users cak is \(self.calories) hence score is \(score)")
        
        // calculate score based on how often they run the route
        
        
    }
    
    func updateScore() {
       
        //check if user has already run this route
        let query = PFQuery(className: "Ranking")
        query.whereKey("route",equalTo:self.route)
        query.whereKey("user",equalTo:PFUser.current())
        query.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
            if let error = error {
                print("error: \(error)")
                
            } else if let objects = objects {
                // The find succeeded.
                
                // if object does not exist create new rank
                if objects.count == 0 {
                    print("rank not found, create new")
                    let rank = PFObject(className: "Ranking")
                    rank["route"] = self.route
                    rank["routeName"] = self.routeName
                    rank["user"] = PFUser.current()
                    rank["liked"] = self.liked
                    rank["score"] = self.score

                    rank.incrementKey("numRuns")
                    rank.saveInBackground{
                        (success: Bool, error: Error?) in
                        if (success){
                            print("Successfully pushed rank to database.")
                        }
                        else {
                          print("Error: Could not push RUN to database.")
                        }
                        
                    }
                        
                }
                else{
                    //object already exists, update scores with new average score
                    print("rank already exists ")
                    for object in objects{
                        object["liked"] = self.liked
                        let totalruns = Double(object["numRuns"] as! Int)
                        let oldScore = (object["score"] as! Double) * Double(totalruns)
                        object["score"] =  ((oldScore + self.score) / (totalruns+1))
                        object.incrementKey("numRuns")
                        object.saveInBackground()

                    }
                }
            }
        }
        
        
        
    }
    
    
    
    
    
    
    func createRun() {
        self.route.incrementKey("totalRuns")
        
        let run = PFObject(className: "Run")
        run["route"] = self.route
        run["user"] = PFUser.current()!
        run["startTimeStamp"] = self.startTime
        run["totalDistance"] = self.route["distance"] as! Double
        run["elapsedTime"] = self.totaltime
        run["runName"] = self.routeName
        //run["averageHeartRate"] = self.heartRate
        //run["caloriesBurnt"] = self.calories
        run.saveInBackground{
            (success: Bool, error: Error?) in
            if (success) {
              print("Successfully pushed RUN to database.")
                let user = PFUser.current() as! User
                user.add(run, forKey: "listOfRuns")
                user.incrementKey("totalRuns")
                user.incrementKey("totalTime", byAmount: self.totaltime as NSNumber)
                user.incrementKey("totalMiles", byAmount: (self.route["distance"] as! Double / 1000 * 0.621371) as NSNumber)
                user.saveInBackground {
                  (success: Bool, error: Error?) in
                  if (success) {
                    print("Successfully added RUN to USER.listOfRuns in database.")
                  } else {
                    print("Error: Could not add RUN to USER.listOfRuns in database.")
                  }
                }
            } else {
              print("Error: Could not push RUN to database.")
            }
          }
    }

    
}
