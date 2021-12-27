//
//  ListViewModelTests.swift
//  LUX_Tests
//
//  Created by Elliot Schrock on 12/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import LUX
import Combine
import FlexDataSource
import Prelude

class ListViewModelTests: XCTestCase {
    func testModels() {
        var wasCalled = false
        let subject = PassthroughSubject<[Human], Never>()
        let vm = LUXModelListViewModel(modelsPublisher: subject.eraseToAnyPublisher(), modelToItem: humanConfigurer >>> configurerToItem)
        let cancel = vm.$models.sinkThrough { _ in
            wasCalled = true
        }
        subject.send([Human]())
        XCTAssert(wasCalled)
        cancel.cancel()
    }
    
    func testSections() {
        var wasCalled = false
        let subject = PassthroughSubject<[Human], Never>()
        let vm = LUXModelListViewModel(modelsPublisher: subject.eraseToAnyPublisher(), modelToItem: humanConfigurer >>> configurerToItem)
        let cancel = vm.sectionsPublisher.sinkThrough { _ in
            wasCalled = true
        }
        subject.send([neo])
        XCTAssert(wasCalled)
        cancel.cancel()
    }
    
    func testFilterModels() {
        var wasCalled = false
        let subject = PassthroughSubject<[Human], Never>()
        let vm = LUXFilteredModelListViewModel(modelsPublisher: subject.eraseToAnyPublisher(), filter: { _ in return true}, modelToItem: humanConfigurer >>> configurerToItem)
        let cancel = vm.$models.sinkThrough {
            _ in wasCalled = true
        }
        subject.send([Human]())
        XCTAssert(wasCalled)
        cancel.cancel()
    }
}
