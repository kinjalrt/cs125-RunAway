//
//  SignUp.swift
//  runaway
//
//  Created by Maya Schwarz on 2/5/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SignUp: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var signUpFirstNameField: UITextField!
    // we will use emails for usernames because they are unique
    @IBOutlet weak var signUpUsernameField: UITextField!
    @IBOutlet weak var signUpPasswordField: UITextField!
    @IBOutlet weak var signUpBirthdayField: UIDatePicker!
    @IBOutlet weak var signUpGenderField: UIPickerView!
    @IBOutlet weak var signUpExperienceField: UIPickerView!
    var GenderData: [String] = [String]()
    var ExperienceData: [String] = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        signUpFirstNameField.text = ""
        signUpUsernameField.text = ""
        signUpPasswordField.text = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let date = dateFormatter.date(from: "17:00")
        signUpBirthdayField.date = date!
        signUpGenderField.delegate = self
        signUpGenderField.dataSource = self
        GenderData = ["Male", "Female", "Non-Binary"]
        signUpGenderField.selectRow(0, inComponent: 0, animated: true)
        signUpExperienceField.delegate = self
        signUpExperienceField.dataSource = self
        ExperienceData = ["Newbie (1-3 miles/week)", "Beginner (4-8 miles/week)", "Intermediate (8-12 miles/week)", "Advanced (13+ miles/week)"]
        signUpExperienceField.selectRow(0, inComponent: 0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return GenderData.count
        } else {
            print("1111asdlkfjlkasdfj")
            return ExperienceData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return GenderData[row]
        } else {
            print("asdlkfjlkasdfj")
            return ExperienceData[row]
        }
    }
    
    
    @IBAction func closePage(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainPage = storyBoard.instantiateViewController(withIdentifier: "initialPage") as! ViewController
        self.present(mainPage, animated: true, completion:nil)

            //self.present(myTabBar, animated: true, completion: nil)
    }
    
  
    @IBAction func signUp(_ sender: UIButton) {
        let user = PFUser()
        user["firstname"] = signUpFirstNameField.text
        user.username = signUpUsernameField.text
        user.password = signUpPasswordField.text
        user["birthday"] = signUpBirthdayField.date
        user["gender"] = GenderData[signUpGenderField.selectedRow(inComponent: 0)]
        user["experienceLevel"] = ExperienceData[signUpExperienceField.selectedRow(inComponent: 0)]
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        user.signUpInBackground { (success, error) in
            UIViewController.removeSpinner(spinner: sv)
        }
    }
    @IBOutlet weak var signUp: UIButton!

    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }

}
