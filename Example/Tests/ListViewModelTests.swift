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
@testable import LUX_Example

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
        var wasFiltered = true
       let humanArray = [Human.init(id: 0, name: "Calvin"), Human.init(id: 1, name: "Remy"), Human.init(id: 3, name: "Calvin"), Human.init(id: 4, name: "Remy")]
        let subject = PassthroughSubject<[Human], Never>()
        let vm = LUXFilteredModelListViewModel(modelsPublisher: subject.eraseToAnyPublisher(), filter: {
            let filterName = $0.name
            if filterName == "Calvin" {
                return true
            }
            wasFiltered = true
            return false
        }, modelToItem: humanConfigurer >>> configurerToItem)
        let cancel = vm.$models.sinkThrough {
            _ in wasCalled = true
        }
        
        subject.send(humanArray)
        XCTAssert(wasCalled)
        XCTAssert(wasFiltered)
        cancel.cancel()
    }

}
