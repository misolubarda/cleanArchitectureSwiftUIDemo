//
//  NetworkSession.swift
//  
//
//  Created by Miso Lubarda on 24.09.20.
//

import Foundation

protocol NetworkSession {
    func perform(with request: URLRequest, completionHandler: @escaping (_ data: Data?, _ httpResponse: URLResponse?, _ error: Error?) -> Void)
}

class DataNetworkSession: NetworkSession {
    func perform(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completionHandler(data, response, error)
            }
        }

        task.resume()
    }
}
