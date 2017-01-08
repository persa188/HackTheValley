//
//  FirstViewController.swift
//  HackTheValleyiOS
//
//  Created by Brandon Mowat on 2017-01-07.
//  Copyright © 2017 Brandon Mowat. All rights reserved.
//

import UIKit

let event = Event()

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let segueIdentifier = "EventSegue"
    var numRows: Int?
    var data: NSDictionary?
    var selected: IndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "token") == nil,
            defaults.object(forKey: "username") == nil {
            self.navigationController?.present((self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController"))!, animated: true, completion: nil)
        }
        
        event.getEvents(completion: { (json) -> Void in
            self.data = json
            DispatchQueue.main.async() {
                self.tableView.reloadData()
                DispatchQueue.main.suspend()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // remove extra cells
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tableView.reloadData()
            DispatchQueue.main.suspend()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == segueIdentifier,
            let destination = segue.destination as? DetailViewController
        {
            // set things here
            
            destination.superTitle = ((((((self.data?["events"] as! Array<Any>)[(self.selected?.row)!]) as! NSDictionary)["eventname"] as? String))!)
            
            destination.superDescription = ((((((self.data?["events"] as! Array<Any>)[(self.selected?.row)!]) as! NSDictionary)["description"] as? String))!)
            
            destination.eventID = ((((((self.data?["events"] as! Array<Any>)[(self.selected?.row)!]) as! NSDictionary)["eventid"] as? Int))!)
            
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.selected = indexPath
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200 // modify cell height for first event in table
        }
        return 85
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        event.getNumOfEvents(completion: {(num) -> Void in
            self.numRows = num

            DispatchQueue.main.suspend()

            // TODO: Kill async
        })
        return self.numRows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row > 0 {
            let cell:EventCell = self.tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
            cell.eventTitle.text = (((self.data?["events"] as! Array<Any>)[indexPath.row]) as! NSDictionary)["eventname"] as? String
            cell.eventDescription.text = (((self.data?["events"] as! Array<Any>)[indexPath.row]) as! NSDictionary)["description"] as? String
            return cell

        } else {
            let cell:TrendingEventCell = self.tableView.dequeueReusableCell(withIdentifier: "TrendingEventCell", for: indexPath) as! TrendingEventCell
            cell.eventTitle.text = (((self.data?["events"] as! Array<Any>)[indexPath.row]) as! NSDictionary)["eventname"] as? String
            cell.eventDescription.text = (((self.data?["events"] as! Array<Any>)[indexPath.row]) as! NSDictionary)["description"] as? String
            return cell

        }

    }

    //    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //        return 1
    //    }

}

