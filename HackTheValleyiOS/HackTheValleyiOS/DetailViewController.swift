//
//  DetailViewController.swift
//  HackTheValleyiOS
//
//  Created by Brandon Mowat on 2017-01-07.
//  Copyright © 2017 Brandon Mowat. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    //
    // Data dict goes here
    //

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var voteA: UIButton!
    @IBOutlet weak var voteB: UIButton!
    @IBOutlet weak var labelA: UILabel!
    @IBOutlet weak var labelB: UILabel!
    
    var eventID: Int?
    var superTitle: String?
    var superDescription: String?

    @IBAction func voteAButtonPress(_ sender: Any) {
        
        self.castVote(option: 0)
        
    }
    @IBAction func boteBButtonPress(_ sender: Any) {
        
        self.castVote(option: 1)
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        self.eventTitle.text = superTitle
        self.eventDescription.text = superDescription
    }

    func castVote(option: Int) {
        print(option)
        
        let vote = Vote()
    
        let defaults = UserDefaults.standard
        let username = defaults.object(forKey: "username")
        vote.getVoteOptions(eventid: String(describing: self.eventID!), completion: {(options: Array<Any>) -> Void in
            print((((options[0] as! NSArray)[option]) as! NSDictionary)["optionid"] ?? "")
            vote.vote(username: username as! String, eventid: String(describing: self.eventID!), option: ((((options[0] as! NSArray)[option]) as! NSDictionary)["optionid"])! as! Int, completion: {(success: Bool) in
                if success {
                    let vc = (
                        self.storyboard?.instantiateViewController(
                            withIdentifier: "ModalViewController")
                        )!
                    self.present(vc, animated: true, completion: nil)
                } else {
                    let vc = (
                        self.storyboard?.instantiateViewController(
                            withIdentifier: "ErrorModalViewController")
                        )!
                    self.present(vc, animated: true, completion: nil)
                }
            })
        })
        
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vote = Vote()
        
        self.voteA.layer.cornerRadius = 5
        self.voteB.layer.cornerRadius = 5
        
        vote.getVoteOptions(eventid: String(describing: self.eventID!), completion: {(options: Array<Any>) -> Void in
            self.labelA.text = ((((options[0] as! NSArray)[0]) as! NSDictionary)["value"]) as? String
            self.labelB.text = ((((options[0] as! NSArray)[1]) as! NSDictionary)["value"]) as? String
            
        })

        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
