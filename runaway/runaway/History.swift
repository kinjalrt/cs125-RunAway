//
//  History.swift
//  runaway
//
//  Created by Kay Lab on 2/15/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import Parse

class History : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var runTable: UITableView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var runsCompleted: UILabel!
    @IBOutlet weak var timeCompleted: UILabel!
    @IBOutlet weak var distCompleted: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var sample = ["this", "is", "a", "sample", "list"]
    var userRunHistory : [PFObject] = []
    let currentUser = PFUser.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getRunHistory()
        tableView.delegate = self
        tableView.dataSource = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return sample.count
        print(userRunHistory.count)
        return userRunHistory.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
//        cell.textLabel?.text = sample[indexPath.row]
        cell.textLabel?.text = userRunHistory[indexPath.row]["runName"] as! String
        return cell
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        updateUIComponents()
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        getRunHistory()
    }
    
    func getRunHistory(){
        userRunHistory = []
        for run in self.currentUser?["listOfRuns"] as! [PFObject]{
            //print(run.objectId!)
            let q = PFQuery(className: "Run")
            q.getObjectInBackground(withId: run.objectId!, block: { (run, error) in
                if error != nil {
                    print("Error: Could not find run in database.")
                }
                else {
//                    print(run!)
                    self.userRunHistory.append(run!)
                    self.updateUIComponents()
                }
            })
            
        }
    }
    func updateUIComponents(){
        self.tableView.reloadData()
        print(userRunHistory)
        
        //set up greeting
        var greeting="Hello "
        greeting+=self.currentUser?["firstname"] as! String
        username.text=greeting
        
        //runs
        runsCompleted.text = String(format: "%d  completed", self.currentUser?["totalRuns"] as! Int)
        
        //time
        let seconds = self.currentUser?["totalTime"] as! TimeInterval
        timeCompleted.text = String(format: "%.1f  seconds", seconds)
        
        //distance
        distCompleted.text = String(format: "%.2f  miles", self.currentUser?["totalMiles"] as! Double)
    }

    @IBAction func logout(_ sender: Any) {
        PFUser.logOutInBackground(block: { (error) in
        if error == nil {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                      //let Home = storyBoard.instantiateViewController(withIdentifier: "Home") as! Home
            let login=self.storyboard?.instantiateViewController(identifier:"LogIn" ) as! LogIn
            
        
            self.present(login, animated: true, completion:nil)
               
            }})
    }
    
}
