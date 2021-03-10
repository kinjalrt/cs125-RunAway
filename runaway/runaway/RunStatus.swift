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
    

    
    @IBOutlet weak var fracLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stopButton.isEnabled = true
        self.resumeButton.isHidden = true
        //update time every 0.01 seconds using the update timer function
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(RunStatus.UpdateTimer), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
        
    @IBAction func stopTimer(_ sender: AnyObject) {
        //stop the timer and switch to post survey page
        timer.invalidate()
        print(self.breaks)
        let endTime = NSDate()
        self.elapsedTime = endTime.timeIntervalSince(self.startTime as Date)
        
        performSegue(withIdentifier: "runComplete", sender: self)
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //send data from this page to post survey page to calculate score
        var vc = segue.destination as! PostRunSurvey
        vc.breaks = self.breaks
        vc.totaltime = self.elapsedTime
        vc.routeName = self.routeName
        vc.route = self.route
        vc.routeDist = self.routeDist
        
    }
    
    @objc func UpdateTimer() {
        //update time and format for user display
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

        timeLabel.text="\(minstr) : \(secstr) : "
        fracLabel.text="\(frac)"
     
    }
    
    @IBAction func PauseTimer(_ sender: Any) {
        //each time user pauses the timer, it counts as a break
        timer.invalidate()
        breaks+=1
        //enable resume button so user can continue when ready
        self.resumeButton.isHidden = false
        self.pauseButton.isHidden = true
        
        
    }
    
    @IBAction func ResumeTimer(_ sender: Any) {
        //restart timer from where it was stopped
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(RunStatus.UpdateTimer), userInfo: nil, repeats: true)
        self.pauseButton.isHidden = false
        self.resumeButton.isHidden = true


    }
    
}

