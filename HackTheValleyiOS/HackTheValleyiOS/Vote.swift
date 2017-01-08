//
//  Vote.swift
//  HackTheValleyiOS
//
//  Created by Brandon Mowat on 2017-01-08.
//  Copyright © 2017 Brandon Mowat. All rights reserved.
//

import Foundation
import Alamofire

class Vote {
    
    init() {}
    
    func vote(username: String, eventid: String, option: Int, completion: @escaping (_ success:Bool) -> Void) {
        let parameters: Parameters = ["eventid": eventid, "username": username, "optionid": option]
        Alamofire.request("http://server.sanic.ca:8989/api/vote/", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                //to get status code
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200, 201:
                        print("example success")
                    default:
                        print("error with response status: \(status)")
                    }
                }
                //to get JSON return value
                if let result = response.result.value {
                    //let JSON = result as! NSDictionary
                    completion(response.response?.statusCode == 200)
                }
                
        }
    }
    
    func getVoteOptions(eventid: String, completion: @escaping (Array<Any>) -> Void) {
        let parameters: Parameters = ["id": eventid]
        Alamofire.request("http://server.sanic.ca:8989/api/event", parameters: parameters)
            .responseJSON { response in
                print(response)
                //to get status code
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200, 201:
                        print("example success")
                    default:
                        print("error with response status: \(status)")
                    }
                }
                //to get JSON return value
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    print((JSON["event"] as! NSDictionary)["options"]!)
                    completion([(JSON["event"] as! NSDictionary)["options"]!])
                }
                
        }
        
        
    }
    
}
