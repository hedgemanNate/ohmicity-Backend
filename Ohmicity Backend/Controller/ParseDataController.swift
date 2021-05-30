//
//  PaseDataController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/21/21.
//

import Foundation


class ParseDataController {
    
    var data: Venue?
    var path: URL?
    var dataArray: [DoData] = []
    
    
    
    func loadPath() {
        guard let path = path else {return NSLog("No file loaded")}
        loadJson(fromURLString: path.absoluteString) { (result) in
            print(path)
            switch result {
            case .success(let data):
                print("loadJson worked")
                self.parse(jsonData: data)
                
            case .failure(let error):
                print(error)
                print("loadJson failed")
            }
        }
    }
    
    func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
    
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode(Venue.self, from: jsonData)
            data = decodedData
            print(data!.venue.count)
            
            guard let data = data else {return}
            for show in data.venue {
                dataArray.append(show)
            }
            
        } catch {
            print("decode error")
        }
    }
    
}
