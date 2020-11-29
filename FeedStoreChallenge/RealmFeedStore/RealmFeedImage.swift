//
//  RealmFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Jair Moreno Gaspar on 29/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import RealmSwift

class RealmFeedImage: Object {
    @objc dynamic var id = ""
    @objc dynamic var cacheDescription = ""
    @objc dynamic var location = ""
    @objc dynamic var url = ""

    override static func primaryKey() -> String? {
      "id"
    }
    
    convenience init(_ image: LocalFeedImage) {
        self.init()
        self.id = "\(image.id)"
        self.cacheDescription = image.description ?? ""
        self.location = image.location ?? ""
        self.url = "\(url)"
    }
    
    var local: LocalFeedImage {
        .init(id: UUID(uuidString: id) ?? UUID.init(),
              description: cacheDescription,
              location: location,
              url: URL(string: url) ?? URL(string: "http://any-url.com")!)
    }
    
}
