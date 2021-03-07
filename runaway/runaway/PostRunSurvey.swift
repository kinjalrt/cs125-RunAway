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
    var route = PFObject(className: "Route")
    var routeName = ""
    var startTime = NSDate()
   var heartRate = "0"
    var calories = "0"
    var totaltime = 0.0
    var breaks=0


    
    @IBOutlet weak var ratingUp: UIButton!
    @IBOutlet weak var ratingDown: UIButton!
    
    @IBOutlet weak var heartRateField: UITextField!
    @IBOutlet weak var caloriesField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heartRateField.text = " "
        caloriesField.text = " "
        print("breaks = \(self.breaks)")
        print("total time = \(self.totaltime)")
    }
    
    
    @IBAction func goHome(_ sender: Any) {
        heartRate = heartRateField.text ?? "0"
        calories = caloriesField.text ?? "0"
        
        print("hr = \(self.heartRate)")
        print("total time = \(self.calories)")
        
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
