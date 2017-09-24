//
//  HTTPSessionManager.swift
//  COSC2471
//
//  Created by Chaithat Sukra on 30/07/2017.
//  Copyright © 2017 Chaithat Sukra. All rights reserved.
//

import Foundation
import UIKit

class HTTPSessionManager {
    
    public let urlString: String!
    
    init() {
        self.urlString = "https://apiemprevo.appspot.com/"
//        self.urlString = "http://localhost:50612/"
    }
    
    func requestGET(_ aEndPoint: String, aCompletion: @escaping(ObjectEvent) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        var request: URLRequest = URLRequest(url: URL (string: self.urlString + aEndPoint)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.sync {
                let event: ObjectEvent = ObjectEvent()
                event.isSuccessful = false
                
                guard let data = data, error == nil else {
                    print("error = \(error)")
                    event.resultMessage = error?.localizedDescription
                    
                    aCompletion(event)
                    return
                }
                
                print(String(data: data, encoding:.utf8)!)
                
                if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    print("status code error = \(response.statusCode)")
                    print("response = \(response)")
                    
                    event.status = response.statusCode
                    event.resultMessage = "status code error"
                    
                    aCompletion(event)
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let message = json as? [Any] {
                        event.isSuccessful = true
                        event.result = message
                    }
                    else {
                        print("json parsing error")
                        
                        event.resultMessage = "json parsing error"
                    }
                    
                    aCompletion(event)
                    
                } catch  {
                    print("json parsing error")
                    
                    event.resultMessage = "json parsing error"
                    
                    aCompletion(event)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        task.resume()
    }
    
    func requestPOST(_ aEndPoint: String, _ aParams: [String: Any], aCompletion: @escaping(ObjectEvent) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        var request: URLRequest = URLRequest(url: URL (string: self.urlString + aEndPoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: aParams)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.sync {
                let event: ObjectEvent = ObjectEvent()
                event.isSuccessful = false
                
                guard let data = data, error == nil else {
                    print("error = \(error)")
                    event.resultMessage = error?.localizedDescription
                    
                    aCompletion(event)
                    return
                }
                
                print(String(data: data, encoding:.utf8)!)
                
                if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    print("status code error = \(response.statusCode)")
                    print("response = \(response)")
                    
                    event.status = response.statusCode
                    event.resultMessage = "status code error"
                    
                    aCompletion(event)
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let message = json as? [Any] {
                        event.isSuccessful = true
                        event.result = message
                    }
                    else {
                        print("json parsing error")
                        
                        event.resultMessage = "json parsing error"
                    }
                    
                    aCompletion(event)
                    
                } catch  {
                    print("json parsing error")
                    
                    event.resultMessage = "json parsing error"
                    
                    aCompletion(event)
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        task.resume()
    }
}
