//
//  NetworkManager.swift
//  TechNews
//
//  Created by Guilherme Mello on 18/02/24.
//

import Foundation

class NetworkManager {
    
    var newsList = [NewModel]()
    
    enum SearchTerm {
        case normal
        case param(String)
        
        func urlString() -> String {
            switch self {
            case .normal:
                return "https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=50"
            case .param(let customParam):
                return "https://hn.algolia.com/api/v1/search?query=\(customParam)&tags=story"
            }
        }
    }
    
    //MARK: - FetchData with completion handler @escaping
    func fetchData(withSearchParam searchTerm: SearchTerm, completion: @escaping ([NewModel]?) -> Void) {
        let urlString = searchTerm.urlString()
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let e = error {
                    print("Error getting url with: \(e.localizedDescription)")
                    completion(nil)
                } else {
                    if let safeData = data {
                        let news = self.parseJSON(with: safeData)
                        DispatchQueue.main.async {
                            completion(news)
                        }
                    } else {
                        completion(nil)
                    }
                }
            }
            task.resume()
        }
    }

    //MARK: - Parse JSON
    func parseJSON(with data: Data) -> [NewModel]? {
        self.newsList = []
        let decoder = JSONDecoder()
        do {
            let results = try decoder.decode(Results.self, from: data)
            for hit in results.hits {
                if let safeUrl = hit.url, let safeTitle = hit.title, let safePoints = hit.points {
                    let newObject = NewModel(title: safeTitle, url: safeUrl, points: safePoints, isRead: false)
                    self.newsList.append(newObject)
                }
            }
        } catch {
            print("Error decoding data with \(error)")
            return nil
        }
        return newsList
    }
}
