//
//  NetworkDelegate.swift
//  Iqra
//
//  Created by Hussain Al-Homedawy on 2016-12-09.
//  Copyright © 2016 Hussain Al-Homedawy. All rights reserved.
//

import Foundation

class NetworkDelegate {
    
    private final var SEARCH_URL = "https://api.iqraapp.com/api/v3.0/search"
    private final var API_URL = "https://api.iqraapp.com/api/v1.0/email"
    private final var API_KEY = Confidential.API_KEY
    
    func postData(_ endpoint: String, _ data:Data, _ callback:@escaping (Data, URLResponse) -> Void) {
        let URL = NSURL(string: endpoint)
        let request = NSMutableURLRequest(url: URL as! URL)
        
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            if (error == nil) {
                callback(data!, response!)
            } else {
                print("Error \(error)")
            }
        }
        
        task.resume()
    }
    
    func performSearchQuery(_ query : String, _ translation: String, _ callback:@escaping (Data, URLResponse) -> Void) {
        let bodyDic = ["arabicText": query, "translation": translation, "apikey": API_KEY]
        let jsonBody = try? JSONSerialization.data(withJSONObject: bodyDic, options: .prettyPrinted)
        
        postData(SEARCH_URL, jsonBody!, callback)
    }
    
    private func messageCallback (_ data: Data, _ urlResponse: URLResponse) {
        print(data)
        print(urlResponse)
    }
    
    func sendMessage(_ name: String, _ message: String, _ email: String) {
        let messageDic = ["name": name, "email": email, "message": message]
        let jsonBody = try? JSONSerialization.data(withJSONObject: messageDic, options: .prettyPrinted)
        
        print (String(data: jsonBody!, encoding: .utf8)!)
        
        postData(API_URL, jsonBody!, messageCallback)
    }
}
