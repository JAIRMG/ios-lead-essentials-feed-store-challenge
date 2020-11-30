//
//  RealmFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Jair Moreno Gaspar on 29/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import RealmSwift

class RealmFeedImage: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var cacheDescription: String? = ""
    @objc dynamic var location: String? = ""
    @objc dynamic var url: String = ""

    override static func primaryKey() -> String? {
      "id"
    }
    
    convenience init(_ image: LocalFeedImage) {
        self.init()
        self.id = image.id.uuidString
        self.cacheDescription = image.description
        self.location = image.location
        self.url = image.url.absoluteString
    }
    
    var local: LocalFeedImage {
        .init(id: UUID(uuidString: id)!,
              description: cacheDescription,
              location: location,
              url: URL(string: url)!)
    }
    
}
