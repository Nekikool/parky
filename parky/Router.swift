//
//  Router.swift
//  parky
//
//  Created by Alexis Suard on 06/03/2016.
//  Copyright © 2016 Alexis Suard. All rights reserved.
//

import Alamofire
import Foundation


public enum Router: URLRequestConvertible {
    

    case Horodateur
    case BePark(Double, Double)
    
    static let baseURLPath = "https://platform.ecim-cities.eu/ecimServices/platform/mediator"

    
    public var URLRequest: NSMutableURLRequest {
        let result:  (url: String, method: Alamofire.Method, parameters: [String: AnyObject]?) = {
            switch self{
            case .Horodateur:
                return ("/configuration/stores/active",.POST, nil)
            case .BePark(let latitude, let longitude):
                
                let params = [
                    "serviceID": "2",
                    "developerKey": "4121136c-9476-40a6-b772-cbe0f13a90d7",
                    "methodName": "parking",
                    "serviceMediaType": "json",
                    "serviceParameters":[
                        [
                            "name": "longitude",
                            "value": longitude
                        ],
                        [
                            "name": "latitude",
                            "value": latitude
                        ]
                    ],
                    "bodyParameter": [],
                ]
                return ("/callService", .POST, params)

            }
        }()
        let URL = NSURL(string: Router.baseURLPath)!
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.url))
        URLRequest.HTTPMethod = result.method.rawValue
        URLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoding = Alamofire.ParameterEncoding.JSON
        
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
    
}