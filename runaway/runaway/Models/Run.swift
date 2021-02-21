//
//  Run.swift
//  runaway
//
//  Created by Kay Lab on 2/20/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import Parse


class Run {
    var routeId: String
    var userId: String
    var startTimeStamp: NSDate
    var endTimeStamp: NSDate
    var runName = String()

    
    // Run object should created only AFTER run is complete
    init(routeId: String, userId: String, startTimeStamp: NSDate, endTimeStamp: NSDate, runName: String){
        self.routeId = routeId
        self.userId = userId
        self.startTimeStamp = startTimeStamp
        self.endTimeStamp = endTimeStamp
        self.runName = runName
        
        self.pushToDatabase()
    }
    
    
    private func pushToDatabase(){
        let parseObject = PFObject(className: "Run")

        parseObject["routeId"] = self.routeId
        parseObject["userId"] = self.userId
        parseObject["startTimeStamp"] = self.startTimeStamp
        parseObject["endTimeStamp"] = self.endTimeStamp
        parseObject["runName"] = self.runName
        
        // Saves the new object.
        parseObject.saveInBackground {
          (success: Bool, error: Error?) in
          if (success) {
            print("Successfully pushed RUN to database.")
          } else {
            print("Error: Could not push RUN to database.")
          }
        }
    }
    
    
    func getRoute() -> PFObject? {
        var route = PFObject()
        let query = PFQuery(className: "Route")
        query.whereKey("objectId", equalTo: self.routeId)
        do{
            route = try query.findObjects()[0]
        } catch {
            print(error)
        }
        return route
    }
    
    
}
