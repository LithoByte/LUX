//
//  FillGridTests.swift
//  LUX_Tests
//
//  Created by Elliot Schrock on 4/11/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import LUX

class FillGridTests: XCTestCase {
    func testFillOne() throws {
        let grid = [[true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true]]
        
        let newGrid = fill(grid, (0, 0, 4), 1, 1)
        
        XCTAssertEqual(newGrid[0][0], false)
        XCTAssertEqual(newGrid[1][0], true)
        XCTAssertEqual(newGrid[0][1], true)
        XCTAssertEqual(newGrid[1][1], true)
    }
    
    func testFillTwoH() throws {
        let grid = [[true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true]]
        
        let newGrid = fill(grid, (0, 0, 4), 1, 2)
        
        XCTAssertEqual(newGrid[0][0], false)
        XCTAssertEqual(newGrid[1][0], false)
        XCTAssertEqual(newGrid[0][1], true)
        XCTAssertEqual(newGrid[1][1], true)
    }
    
    func testFillTwoV() throws {
        let grid = [[true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true]]
        
        let newGrid = fill(grid, (0, 0, 4), 2, 1)
        
        XCTAssertEqual(newGrid[0][0], false)
        XCTAssertEqual(newGrid[1][0], true)
        XCTAssertEqual(newGrid[0][1], false)
        XCTAssertEqual(newGrid[1][1], true)
    }
    
    func testFillTwoSquare() throws {
        let grid = [[true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true]]
        
        let newGrid = fill(grid, (0, 0, 4), 2, 2)
        
        XCTAssertEqual(newGrid[0][0], false)
        XCTAssertEqual(newGrid[1][0], false)
        XCTAssertEqual(newGrid[0][1], false)
        XCTAssertEqual(newGrid[1][1], false)
    }
    
    func testFillTwoSquareOffset() throws {
        let grid = [[true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true],
                    [true, true, true, true]]
        
        let newGrid = fill(grid, (1, 1, 4), 2, 2)
        
        XCTAssertEqual(newGrid[1][1], false)
        XCTAssertEqual(newGrid[2][1], false)
        XCTAssertEqual(newGrid[1][2], false)
        XCTAssertEqual(newGrid[2][2], false)
    }
}
