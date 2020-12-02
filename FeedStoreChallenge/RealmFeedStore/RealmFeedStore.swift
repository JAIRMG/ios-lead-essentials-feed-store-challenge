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
	
	private let queue = DispatchQueue(label: "\(RealmFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    public init(configuration: Realm.Configuration) {
		self.configuration = configuration
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		queue.async(flags: .barrier) {
			
			do {
				let realm = try Realm()
				
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
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
		queue.async(flags: .barrier) {
			let feedList = feed.map(RealmFeedImage.init)
			
			do {
				let realm = try Realm()
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

    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
		queue.async {
			
			do {
				let realm = try Realm()
				guard let cache = realm.objects(Cache.self).first else {
					return completion(.empty)
				}
				
				completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
			} catch {
				completion(.failure(error))
			}
			
		}
    }
    
    
}
