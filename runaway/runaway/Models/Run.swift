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
    var objectId: String
    var routeId: String
    var userId: String
    var startTimeStamp: NSDate
    var endTimeStamp: NSDate
    var runName = String()

    
    // Run object should created only AFTER run is complete
    init(routeId: String, userId: String, startTimeStamp: NSDate, endTimeStamp: NSDate, runName: String){
        self.objectId = ""
        self.routeId = routeId
        self.userId = userId
        self.startTimeStamp = startTimeStamp
        self.endTimeStamp = endTimeStamp
        self.runName = runName
        
        self.objectId = self.pushToDatabase()
    }
    
    
    init(objectId: String){
        self.objectId = ""
        self.routeId = ""
        self.userId = ""
        self.startTimeStamp = NSDate()
        self.endTimeStamp = NSDate()
        self.runName = ""
        
        let query = PFQuery(className: "Run")
        query.whereKey("objectId", equalTo: objectId)
        query.findObjectsInBackground{ (runs, error) in
            if error != nil {
                print("Error: Could not find route in database.")
            }
            else if runs?.count != 0 {
                self.objectId = runs![0]["objectId"] as! String
                self.routeId = runs![0]["routeId"] as! String
                self.userId = runs![0]["userId"] as! String
                self.startTimeStamp = runs![0]["startTimeStamp"] as! NSDate
                self.endTimeStamp = runs![0]["endTimeStamp"] as! NSDate
                self.runName = runs![0]["runName"] as! String
            }
        }
    }
    
    
    private func pushToDatabase() -> String{
        let parseObject = PFObject(className: "Run")

        parseObject["routeId"] = self.routeId
        parseObject["userId"] = self.userId
        parseObject["startTimeStamp"] = self.startTimeStamp
        parseObject["endTimeStamp"] = self.endTimeStamp
        parseObject["runName"] = self.runName
        
        // Saves the new object.
        var id = self.objectId
        parseObject.saveInBackground {
          (success: Bool, error: Error?) in
          if (success) {
            print("Successfully pushed RUN to database.")
            id = parseObject.objectId!
          } else {
            print("Error: Could not push RUN to database.")
          }
        }
        return id
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
