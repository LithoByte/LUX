//
//  CombineModelFunctionsTests.swift
//  LUX_Tests
//
//  Created by Calvin Collins on 10/27/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import Combine
import Slippers
import LithoOperators
@testable import LUX

struct HumanWrapper: Codable {
    var humans: [Human]?
}

let human = Human(id: 0, name: "Human")
let humanData = JsonProvider.encode(human)
let humanWrapper = HumanWrapper(humans: [human])
let humanWrapperData = JsonProvider.encode(humanWrapper)

class CombineModelFunctionsTests: XCTestCase {
    var cancelBag: Set<AnyCancellable> = []
    
    func testModelPublisher() {
        let dataSub = PassthroughSubject<Data?, Never>()
        let modelPub: AnyPublisher<Human, Never> = modelPublisher(from: dataSub.eraseToAnyPublisher())
        modelPub.sink(receiveValue: {
            XCTAssertEqual($0.id, human.id)
        }).store(in: &cancelBag)
        dataSub.send(humanData)
    }
    
    func testOptModelPublisher() {
        let dataSub: PassthroughSubject<Data?, Never>? = PassthroughSubject<Data?, Never>()
        let optModelPub: AnyPublisher<Human, Never>? = optModelPublisher(from: dataSub?.eraseToAnyPublisher())
        XCTAssertNotNil(optModelPub)
        optModelPub?.sink(receiveValue: {
            XCTAssertEqual($0.id, human.id)
        }).store(in: &cancelBag)
        dataSub?.send(humanData)
    }
    
    func testOptModelPublisherNil() {
        let dataSub: PassthroughSubject<Data?, Never>? = nil
        let optModelPub: AnyPublisher<Human, Never>? = optModelPublisher(from: dataSub?.eraseToAnyPublisher())
        XCTAssertNil(optModelPub)
    }
    
    func testUnwrappedModelPublisher() {
        let dataSub: PassthroughSubject<Data?, Never> = PassthroughSubject<Data?, Never>()
        let unwrappedModelPub: AnyPublisher<[Human], Never> = unwrappedModelPublisher(from: dataSub.eraseToAnyPublisher(), ^\HumanWrapper.humans)
        unwrappedModelPub.sink(receiveValue: { humans in
            XCTAssertEqual(humans.count, 1)
            XCTAssertEqual(humans.first?.id, human.id)
        }).store(in: &cancelBag)
        dataSub.send(humanWrapperData)
    }
    
    func testOptUnwrappedModelPublisher() {
        let dataSub: PassthroughSubject<Data?, Never>? = nil
        let unwrappedModelPub: AnyPublisher<[Human], Never>? = unwrappedModelPublisher(from: dataSub?.eraseToAnyPublisher(), ^\HumanWrapper.humans)
        XCTAssertNil(unwrappedModelPub)
    }
}
