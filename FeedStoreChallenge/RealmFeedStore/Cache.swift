//
//  Cache.swift
//  FeedStoreChallenge
//
//  Created by Jair Moreno Gaspar on 29/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import RealmSwift

class Cache: Object {
    var feed = List<RealmFeedImage>()
    @objc dynamic var timestamp = Date()
    @objc dynamic var id = ""
    override static func primaryKey() -> String? {
      "id"
    }
    
    
    var localFeed: [LocalFeedImage] {
        feed.compactMap { $0.local }
    }
    
}
