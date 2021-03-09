//
//  Rating.swift
//  runaway
//
//  Created by Kay Lab on 2/20/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import Parse


class Rating {
    private var routeId: String
    private var userId: String
    var score: Int
    var numRuns: Int
    
    init(routeId: String, userId: String, rating: Int, numRuns: Int){
        self.routeId = routeId
        self.userId = userId
        self.score = rating
        self.numRuns = numRuns
        
    }
    
    func getRoute() -> PFObject{
        var route = PFObject()
        let query1 = PFQuery(className: "Route")
        query1.whereKey("objectId", equalTo: self.routeId)
        do{
            route = try query1.findObjects()[0]
        } catch {
            print(error)
        }
        return route
    }
    
    func getUser() -> PFObject {
        var user = PFObject()
        let query2 = PFQuery(className: "_User")
        query2.whereKey("objectId", equalTo: self.userId)
        do{
            user = try query2.getFirstObject()
        } catch {
            print(error)
        }
        return user
    }
    
   
    
    func changeRating(newRating: Int) {
        score = newRating
    }
}
