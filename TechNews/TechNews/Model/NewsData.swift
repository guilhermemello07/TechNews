//
//  NewsData.swift
//  TechNews
//
//  Created by Guilherme Mello on 18/02/24.
//

import Foundation

//To translate data from JSON object
struct Results: Codable {
    let hits: [Post]
}

struct Post: Codable {
    let objectID: String
    let title: String?
    let points: Int?
    let url: String?
}
