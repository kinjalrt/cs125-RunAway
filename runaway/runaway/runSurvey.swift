//
//  runSurvey.swift
//  runaway
//
//  Created by Kay Lab on 3/6/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import Parse

class RunSurvey: UIViewController {
    var route = PFObject(className: "Route")
    var routeName = ""
    var startTime = NSDate()


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
