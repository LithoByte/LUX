//
//  CVCSizeOptionsTests.swift
//  LUX_Tests
//
//  Created by Elliot Schrock on 4/11/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import LUX

class CVCSizeOptionsTests: XCTestCase {
    func testEmptySizeOption() throws {
        let grid = [[true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true]]
        
        let sizeOptions = sizeOptionsInUnits(grid)
        
        XCTAssertEqual(sizeOptions.0, 0)
        XCTAssertEqual(sizeOptions.1, 0)
        XCTAssertEqual(sizeOptions.2, 4)
    }
    
    func testFirstSizeOption() throws {
        let grid = [[false, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true]]
        
        let sizeOptions = sizeOptionsInUnits(grid)
        
        XCTAssertEqual(sizeOptions.0, 1)
        XCTAssertEqual(sizeOptions.1, 0)
        XCTAssertEqual(sizeOptions.2, 3)
    }
    
    func testSecondSizeOption() throws {
        let grid = [[false, false, false, false],
                    [false, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true]]
        
        let sizeOptions = sizeOptionsInUnits(grid)
        
        XCTAssertEqual(sizeOptions.0, 1)
        XCTAssertEqual(sizeOptions.1, 1)
        XCTAssertEqual(sizeOptions.2, 3)
    }
    
    func testSquareSizeOption() throws {
        let grid = [[false, false, false, false],
                    [true, false, false, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true]]
        
        let sizeOptions = sizeOptionsInUnits(grid)
        
        XCTAssertEqual(sizeOptions.0, 0)
        XCTAssertEqual(sizeOptions.1, 1)
        XCTAssertEqual(sizeOptions.2, 1)
    }
}
