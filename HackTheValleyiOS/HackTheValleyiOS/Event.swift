//
//  Event.swift
//  HackTheValleyiOS
//
//  Created by Brandon Mowat on 2017-01-08.
//  Copyright © 2017 Brandon Mowat. All rights reserved.
//

import Foundation
import Alamofire

class Event {

    init() {}
    
    func getEvents(completion: @escaping (_ json: NSDictionary) -> Void) {
        Alamofire.request("http://server.sanic.ca:8989/api/events")
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
                    completion(JSON)
                }
                
        }
    }
    
    func getNumOfEvents(completion: @escaping (_ num: Int) -> Void) {
        Alamofire.request("http://server.sanic.ca:8989/api/events")
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
                    completion((JSON["events"] as! Array<Any>).count)
                }
                
        }
    }

}
