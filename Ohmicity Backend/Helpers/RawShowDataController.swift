//
//  PaseDataController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 5/21/21.
//

import Foundation


class RawShowDataController {
    
    var data: ShowsData?
    var path: URL?
    var rawShowsArray = [ShowData]()
    var rawShowsResultsArray = [ShowData]()
    
    
    
    func loadShowsPath(completion: @escaping () -> Void) {
        guard let path = path else {return NSLog("No file loaded")}
        loadJson(fromURLString: path.absoluteString) { (result) in
            print(path)
            switch result {
            case .success(let data):
                print("loadJson worked")
                self.parse(jsonData: data)
                completion()
                
            case .failure(let error):
                print(error)
                print("loadJson failed")
                return
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
                } else {
                    return
                }
            }
            
            urlSession.resume()
        }
    }
    
    private func parse(jsonData: Data) {
        do {
            let serialQueue = DispatchQueue(label: "JsonArrayQueue")
            let decodedData = try JSONDecoder().decode(ShowsData.self, from: jsonData)
            data = decodedData
            
            
            guard let data = data else {return}
            for show in data.shows {
                serialQueue.sync { [self] in
                    rawShowsArray.append(show)
                }
            }
            print(rawShowsArray)
            //Search Functionality
            
//            rawShowsResultsArray = []
//            rawShowsResultsArray = rawShowsArray
            
        } catch {
            print("decode error")
        }
    }
    
    
    
}

let rawShowDataController = RawShowDataController()
