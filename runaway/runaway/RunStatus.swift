//
//  RunStatus.swift
//  runaway
//
//  Created by Maya Schwarz on 2/9/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import Parse

class RunStatus: UIViewController {
    var route = PFObject(className: "Route")
    var routeName = ""
    var routeDist = 0.0
    var counter = 0.0
    var timer = Timer()
    var startTime = NSDate()
    var elapsedTime = 0.0
    var breaks = 0
    var (minutes,seconds,frac)=(0,0,0)
    

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stopButton.isEnabled = true
        self.resumeButton.isHidden = true
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(RunStatus.UpdateTimer), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
        
    @IBAction func stopTimer(_ sender: AnyObject) {
        timer.invalidate()
        print(self.breaks)
        let endTime = NSDate()

        self.elapsedTime = endTime.timeIntervalSince(self.startTime as Date)

        
        /*let vc = self.storyboard?.instantiateViewController(identifier: "PostRunSurvey" ) as! PostRunSurvey

        vc.breaks = self.breaks
        vc.totaltime = self.elapsedTime
        vc.routeName = self.routeName
        vc.route = self.route
        vc.routeDist = self.routeDist*/

        //self.navigationController?.pushViewController(vc, animated: true)
        
        performSegue(withIdentifier: "runComplete", sender: self)
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! PostRunSurvey
        vc.breaks = self.breaks
        vc.totaltime = self.elapsedTime
        vc.routeName = self.routeName
        vc.route = self.route
        vc.routeDist = self.routeDist
        
    }
    
    @objc func UpdateTimer() {
        frac+=1
        if frac > 99 {
            seconds+=1
            frac=0
        }
        
        if seconds==60{
            minutes+=1
            seconds=0
        }
        
        let secstr = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minstr = minutes > 9 ? "\(minutes)" : "0\(minutes)"

        timeLabel.text="\(minstr) : \(secstr) : \(frac)"
     
    }
    
    @IBAction func PauseTimer(_ sender: Any) {
        timer.invalidate()
        breaks+=1
        self.resumeButton.isHidden = false
        self.pauseButton.isHidden = true
        
        
    }
    
    @IBAction func ResumeTimer(_ sender: Any) {
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(RunStatus.UpdateTimer), userInfo: nil, repeats: true)
        self.pauseButton.isHidden = false
        self.resumeButton.isHidden = true


    }
    /*func createRun() {
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
    }*/
}

