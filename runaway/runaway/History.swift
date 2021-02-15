//
//  History.swift
//  runaway
//
//  Created by Kay Lab on 2/14/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import Parse

class History: UIViewController {
    
 override func viewDidLoad() {
       super.viewDidLoad()
   }
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var runsCompleted: UILabel!
    @IBOutlet weak var timeCompleted: UILabel!
    @IBOutlet weak var milesCompleted: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let currUser=PFUser.current()
        username.text=currUser?["firstname"] as! String
        var run=String(currUser?["totalRuns"] as! Int)
        run+=" runs completed"
        runsCompleted.text=run
        var miles=String(currUser?["totalMiles"] as! Int)
        miles+=" miles completed"
        milesCompleted.text=miles
        var times=String(currUser?["totalTime"] as! Int)
        times+=" minutes"
        timeCompleted.text=times


        
        //runsCompleted.text=currUser?["totalRuns"] as? String
        
        
    }
    
    
}
