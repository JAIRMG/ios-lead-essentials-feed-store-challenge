//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import RealmSwift

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
        let sut = try! RealmFeedStore(configuration: inMemoryConfigurationRealm())
        trackForMemoryLeaks(instance: sut)
        return sut
	}
	
	private func inMemoryConfigurationRealm() -> Realm.Configuration {
		var config = Realm.Configuration()
		config.inMemoryIdentifier = self.name
		return config
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
    
    private func invalidURL() -> URL {
        let invalidURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        invalidURL.stopAccessingSecurityScopedResource()
        return invalidURL
    }
}
