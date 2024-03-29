//
//  LoginViewController.swift
//  HackTheValleyiOS
//
//  Created by Brandon Mowat on 2017-01-07.
//  Copyright © 2017 Brandon Mowat. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var submit: UIButton!

    @IBAction func loginSubmit(_ sender: Any) {
        if let username = usernameField.text,
            let password = passwordField.text {
            User(username: username).login(password: password, completion: { () -> Void in
                self.present((self.storyboard?.instantiateViewController(withIdentifier: "MainViewController"))!, animated: true, completion: nil)
            })
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
