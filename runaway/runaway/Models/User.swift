//
//  User.swift
//  runaway
//
//  Created by Kay Lab on 2/12/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import Parse


// Not sure if this is needed? made it just in case
class User : PFUser {
    //var gender: String = ""
    //var emailVerified: Bool = false
    //var height: String = ""
    //var weight: String = ""
    //var birthday: NSDate = NSDate()
    var experienceLevel: String = ""
    var difficultyTier: Int = 0
    var listOfRuns: [Run] = []
    var listOfRatings: [Rating] = []
    
    init(user: PFUser) {
        super.init()
        
        self.experienceLevel = user["experienceLevel"] as! String
        self.difficultyTier = user["difficultyLevel"] as! Int
        self.listOfRuns = user["listOfRuns"] as! [Run]
        self.listOfRatings = user["listOfRatings"] as! [Rating]
    }
    
    func addRun(run: Run){
        listOfRuns.append(run)
    }
    func giveRating(rating: Rating){
        listOfRatings.append(rating)
    }
        
}
