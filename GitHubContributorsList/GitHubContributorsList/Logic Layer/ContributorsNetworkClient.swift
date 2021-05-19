//
//  ContributorsNetworkClient.swift
//  GitHubContributorsList
//
//  Created by Viacheslav Embaturov on 18.05.2021.
//

import Foundation


enum ResponseError: Error {
    case network
    case parse
}

extension HTTPURLResponse {
    var isSuccess: Bool {
        return (200...299).contains(statusCode)
    }
}


class ContributorsNetworkClient {
    
    //MARK: - Class variables
    
    private let session = URLSession.shared
    private let destinationPath = "https://api.github.com/repos/videolan/vlc/contributors"
    
    
    
    //MARK: -
    
    func allContributors(completion: @escaping (Result<[Contributor], ResponseError>) -> Void) {
        
        let url = URL(string: destinationPath)!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.isSuccess,
                  let data = data
            else {
                completion(.failure(ResponseError.network))
                return
            }
            
            guard let parsedData = try? JSONDecoder().decode([Contributor].self, from: data) else {
              completion(.failure(ResponseError.parse))
              return
            }
            completion(.success(parsedData))
            
        }.resume()
    }
}
