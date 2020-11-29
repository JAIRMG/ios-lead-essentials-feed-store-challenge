//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import RealmSwift

class Cache: Object {
    var feed = List<RealmFeedImage>()
    @objc dynamic var timestamp = Date()
    @objc dynamic var id = ""
    override static func primaryKey() -> String? {
      "id"
    }
    
    
    var localFeed: [LocalFeedImage] {
        feed.map { $0.local }
    }
    
}

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

class RealmFeedStore: FeedStore {
    
    private static let cacheId = "cache"
    private let queue = DispatchQueue(label: "\(RealmFeedStore.self) queue", qos: .userInitiated)
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        queue.async {
            let realm = try! Realm()
            
            guard let cache = realm.objects(Cache.self).first else {
                return completion(nil)
            }
            do {
                try realm.write {
                  realm.delete(cache)
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let cacheId = RealmFeedStore.cacheId
        queue.async { [weak self] in
            guard let self = self else { return }
            let realm = try! Realm()
            let feedList = feed.map(RealmFeedImage.init)
            let cacheExists = RealmFeedStore.objectExist(realm: realm, id: cacheId)

            do {
                if cacheExists {
                  
                    try self.updateCache(feedList, timestamp, cacheId, realm)

                } else {
                  
                    try self.firstTimeInsertion(feedList, timestamp, cacheId, realm)
                  
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func firstTimeInsertion(_ feedList: [RealmFeedImage], _ timestamp: Date, _ id: String, _ realm: Realm) throws {
        
        let localRealm: Realm = realm
        
        let cache = Cache()
        cache.feed.append(objectsIn: feedList)
        cache.timestamp = timestamp
        cache.id = RealmFeedStore.cacheId
        
        try localRealm.write {
            realm.add(cache)
        }
    }
    
    func updateCache(_ feedList: [RealmFeedImage], _ timestamp: Date, _ id: String, _ realm: Realm) throws {
        
        let localRealm: Realm = realm
        
        try localRealm.write {
          realm.create(
            Cache.self,
            value: [
              "feed": feedList,
              "timestamp": timestamp,
                "id": "\(RealmFeedStore.cacheId)"
            ],
            update: .modified)
        
        }
    }
    
    static func objectExist (realm: Realm, id: String) -> Bool {
        return realm.object(ofType: Cache.self, forPrimaryKey: id) != nil
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        queue.async {
            let realm = try! Realm()
            guard let cache = realm.objects(Cache.self).first else {
                return completion(.empty)
            }
            
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        }
    }
    
    
}

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
    
    override func setUp() {
        super.setUp()
        setupEmptyState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreFeedSideEffects()
    }

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}

	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() -> FeedStore {
		let sut = RealmFeedStore()
        trackForMemoryLeaks(instance: sut)
        return sut
	}
	
    private func undoStoreFeedSideEffects() {
        deleteArtifacts()
    }
    
    private func setupEmptyState() {
        deleteArtifacts()
    }
    
    private func deleteArtifacts() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func trackForMemoryLeaks(instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
}

//  ***********************
//
//  Uncomment the following tests if your implementation has failable operations.
//
//  Otherwise, delete the commented out code!
//
//  ***********************

//extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
//
//	func test_retrieve_deliversFailureOnRetrievalError() {
////		let sut = makeSUT()
////
////		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//	}
//
//	func test_retrieve_hasNoSideEffectsOnFailure() {
////		let sut = makeSUT()
////
////		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}
