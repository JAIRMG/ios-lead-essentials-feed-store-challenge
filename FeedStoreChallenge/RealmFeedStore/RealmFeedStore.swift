//
//  RealmFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Jair Moreno Gaspar on 29/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import RealmSwift

public class RealmFeedStore: FeedStore {
    
    private static let cacheId = "cache"
	private let configuration: Realm.Configuration
	
    public init(configuration: Realm.Configuration) {
		self.configuration = configuration
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let configuration = self.configuration
			
		do {
			let realm = try Realm(configuration: configuration)
			
			guard let cache = realm.objects(Cache.self).first else {
				return completion(nil)
			}
			
			try realm.write {
				realm.delete(cache)
			}
			completion(nil)
		} catch {
			completion(error)
		}

    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
		let configuration = self.configuration
		let feedList = feed.map(RealmFeedImage.init)
		
		do {
			let realm = try Realm(configuration: configuration)
			try realm.write {
				realm.deleteAll()
				let cache = Cache()
				cache.feed.append(objectsIn: feedList)
				cache.timestamp = timestamp
				cache.id = RealmFeedStore.cacheId
				realm.add(cache)
			}
			completion(nil)
		} catch {
			completion(error)
		}
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
		let configuration = self.configuration
		do {
			let realm = try Realm(configuration: configuration)
			guard let cache = realm.objects(Cache.self).first else {
				return completion(.empty)
			}
			
			completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
		} catch {
			completion(.failure(error))
		}
    }
    
    
}
