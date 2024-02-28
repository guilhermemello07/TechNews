//
//  Constants.swift
//  TechNews
//
//  Created by Guilherme Mello on 18/02/24.
//

import Foundation

struct K {
    static let newsCellIdentifier = "newsCellIdentifier"
    static let savedNewsCellIdentifier = "newsCellIdentifier"
    static let newsCellNibName = "NewsCell"

    struct Segues {
        static let fromNewsToDetails = "segueFromNewsToDetails"
        static let fromSavedToDetails = "segueFromSavedToDetails"
    }
    
    struct CoreDataModel {
        static let dataModelIdentifier = "Model"
        
        struct NewsItem {
            static let newsEntityIdentifier = "NewsItem"
            static let title = "title"
            static let url = "url"
            static let isRead = "isRead"
        }
    }
}
