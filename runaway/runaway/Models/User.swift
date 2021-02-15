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
class User {
    var objectId: String
    var gender: String
    var emailVerified: Bool
    var height: String
    var weight: String
    var firstName: String
    var email: String
    var password: String
    var birthday: Date
    var experienceLevel: String
    var difficultyLevel: Int
    
    init(objectId: String, gender: String, emailVerified: Bool, height: String, weight: String, firstName: String, email: String, password:String, birthday: Date, experienceLevel: String, difficultyLevel: Int) {
        
        self.objectId = objectId
        self.gender = gender
        self.emailVerified = emailVerified
        self.height = height
        self.weight = weight
        self.firstName = firstName
        self.email = email
        self.password = password
        self.birthday = birthday
        self.experienceLevel = experienceLevel
        self.difficultyLevel = difficultyLevel
    }
        
}
