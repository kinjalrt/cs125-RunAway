//
//  Congrats.swift
//  runaway
//
//  Created by Maya Schwarz on 2/24/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import SAConfettiView


class Congrats: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let confettiView = SAConfettiView(frame: self.view.bounds)
        self.view.addSubview(confettiView)
        confettiView.intensity = 0.8
        confettiView.startConfetti()
        confettiView.isUserInteractionEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func leaveButton(_ sender: Any) {
        print("leaving")
        //let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tab_control=storyboard?.instantiateViewController(identifier: "myTabBar") as! myTabBar
        self.present(tab_control, animated: true, completion:nil)
    }
    
    @IBAction func returnHome(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        let resetStartRun = self.navigationController?.topViewController as! StartRun
        resetStartRun.distanceSlider.setValue(0.0, animated: false)
        resetStartRun.distanceSliderValueChanged(resetStartRun.distanceSlider)
        resetStartRun.distanceSliderValueChosen(resetStartRun.distanceSlider)
    }
    
    
}
