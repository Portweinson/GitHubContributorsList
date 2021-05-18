//
//  ContributorInfo.swift
//  GitHubContributorsList
//
//  Created by Viacheslav Embaturov on 18.05.2021.
//

import Foundation


struct Contributor {
    let login: String
    let id: Int
    let avatarUrl: URL?
}


//MARK: - Codable Implementation

extension Contributor: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
    }
}
