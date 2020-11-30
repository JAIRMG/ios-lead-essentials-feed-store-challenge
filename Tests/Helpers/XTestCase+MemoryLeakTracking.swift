//
//  XTestCase+MemoryLeakTracking.swift
//  Tests
//
//  Created by Jair Moreno Gaspar on 30/11/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
}
