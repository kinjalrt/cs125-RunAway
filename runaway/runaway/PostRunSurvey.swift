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
    //route info
    var route = PFObject(className: "Route")
    var routeName = ""
    var routeDist = 0.0
    
    var startTime = NSDate()
    var heartRate = 0
    var calories = 0.0
    var totaltime = 0.0
    var breaks = 0
    var liked = true
    var unlike = false
    var score = 0.0


    
    @IBOutlet weak var ratingUp: UIButton!
    @IBOutlet weak var ratingDown: UIButton!
    
    @IBOutlet weak var heartRateField: UITextField!
    @IBOutlet weak var caloriesField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.routeDist = routeDist / 1609.34
        print("breaks = \(self.breaks)")
        print("total time = \(self.totaltime)")
        print("dist = \(self.routeDist)")
    }
    
    
    
  
    
    @IBAction func runLiked(_ sender: Any) {
        self.liked = true
        self.unlike = false
        ratingUp.isEnabled = false
        ratingDown.isEnabled = true
    }
    
    @IBAction func runDisliked(_ sender: Any) {
        self.liked = false
        self.unlike = true
        ratingUp.isEnabled = true
        ratingDown.isEnabled = false
    }
    
    
    
    
    
    
    
    
    
    @IBAction func goHome(_ sender: Any) {
        self.heartRate = Int(heartRateField.text ??  "0") ?? 0
        calories = Double(caloriesField.text ?? "0") ?? 0.0
        calculateScore()
        
        print("hr = \(self.heartRate)")
        print("total time = \(self.calories)")
        
    }
    
    
    func calculateScore(){
        
        //calculate time score
        let avgTime = self.routeDist * 10
        let timediff = avgTime/self.totaltime
        self.score += timediff
        print( " avg time is \(avgTime) and users time is \(totaltime) hence score is \(score)")
        
        //calculate heart rate score
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
        
        if heartRate<=targetHR{score+=2}
        if heartRate>targetHR{score-=2}
        print( " avg hr ifor age \(age) and users time is \(self.heartRate) hence score is \(score)")
        
        // calculate score based on calories burnt per mile
        let calPerMile = self.calories / self.routeDist
        score+=calPerMile
        
        print( " avg cal \(calPerMile) and users cak is \(self.calories) hence score is \(score)")
        
        // calculate score based on how often they run the route
        //calculate score based on if they user liked the run

        
        
        

        
    }
    
    
    
    
    func createRun() {
        self.route.incrementKey("totalRuns")
        let endTime = NSDate()
        let elapsedTime = endTime.timeIntervalSince(self.startTime as Date)
        
        let run = PFObject(className: "Run")
        run["route"] = self.route
        run["user"] = PFUser.current()!
        run["startTimeStamp"] = self.startTime
        run["totalDistance"] = self.route["distance"] as! Double
        run["elapsedTime"] = elapsedTime
        run["runName"] = self.routeName
        run.saveInBackground{
            (success: Bool, error: Error?) in
            if (success) {
              print("Successfully pushed RUN to database.")
                let user = PFUser.current() as! User
                user.add(run, forKey: "listOfRuns")
                user.incrementKey("totalRuns")
                user.incrementKey("totalTime", byAmount: elapsedTime as NSNumber)
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
