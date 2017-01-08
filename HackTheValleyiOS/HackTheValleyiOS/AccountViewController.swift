//
//  AccountViewController.swift
//  HackTheValleyiOS
//
//  Created by Brandon Mowat on 2017-01-08.
//  Copyright © 2017 Brandon Mowat. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    @IBAction func Logout(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "token")
        self.present((self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController"))!, animated: true, completion: nil)
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
