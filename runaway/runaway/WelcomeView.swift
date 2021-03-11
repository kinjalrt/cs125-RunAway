//
//  ViewController.swift
//  runaway
//
//  Created by Kay Lab on 1/30/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import UIKit
import Parse


class WelcomeView: UIViewController {
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    @IBAction func newRunnerButtonPressed(_ sender: UIButton) {
        let signup = self.storyboard?.instantiateViewController(identifier: "SignUp") as! SignUp
        self.navigationController?.pushViewController(signup, animated: true)
    }
    
    @IBAction func oldRunnerButtonPressed(_ sender: UIButton) {
        let login = self.storyboard?.instantiateViewController(identifier: "LogIn") as! LogIn
        
        self.navigationController?.pushViewController(login, animated: true)
        
    }
}
