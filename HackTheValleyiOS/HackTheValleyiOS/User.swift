//
//  User.swift
//  HackTheValleyiOS
//
//  Created by Brandon Mowat on 2017-01-07.
//  Copyright © 2017 Brandon Mowat. All rights reserved.
//

import Foundation
import Alamofire

class User {
    
    var username: String
    
    init(username: String) {
        self.username = username
    }
    
    func login(passord: String) {
        let defaults = UserDefaults.standard
        
        Alamofire.request("http://127.0.0.1:5000/api/token")
            .authenticate(user: self.username, password: password)
            .responseJSON { response in
                print(response)
                //to get status code
                if let status = response.response?.statusCode {
                    switch(status){
                    case 201:
                        print("example success")
                    default:
                        print("error with response status: \(status)")
                    }
                }
                //to get JSON return value
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    if let token = JSON["token"] {
                        defaults.set(token, forKey: "token")
                        defaults.set("test123", forKey: "username")
                    }
                }
                
        }

    }
    
}
