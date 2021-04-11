//
//  MultiSizeCVTests.swift
//  LUX_Tests
//
//  Created by Elliot Schrock on 4/11/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
@testable import LUX

class MultiSizeCVTests: XCTestCase {
    func testDefaultColumnCount() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 800), collectionViewLayout: layout)
        
        let count = layout.calculateDefaultColumnCount()
        
        XCTAssertEqual(count, 2)
    }
    
    func testHeightRatioColumnCount() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 800), collectionViewLayout: layout)
        cv.contentSize = CGSize(width: 200, height: 800)
        layout.setBaseCellHeight(300)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateDefaultColumnCount()
        
        XCTAssertEqual(count, 1)
    }
    
    func testWidthColumnCount() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 800), collectionViewLayout: layout)
        cv.contentSize = CGSize(width: 200, height: 800)
        layout.setBaseCellWidth(200)
        layout.setBaseCellHeight(300)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateDefaultColumnCount()
        
        XCTAssertEqual(count, 2)
    }
    
    func testColumnCount() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 800), collectionViewLayout: layout)
        layout.setColumnCount(3)
        layout.setBaseCellWidth(200)
        layout.setBaseCellHeight(300)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateDefaultColumnCount()
        
        XCTAssertEqual(count, 3)
    }
    
    func testColumnCountClosure() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 800), collectionViewLayout: layout)
        layout.calculateColumns = { 4 }
        layout.setColumnCount(3)
        layout.setBaseCellWidth(200)
        layout.setBaseCellHeight(300)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateDefaultColumnCount()
        
        XCTAssertEqual(count, 4)
    }
    
    func testDefaultHeight() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 800), collectionViewLayout: layout)
        
        let count = layout.calculateBaseItemHeight()
        
        XCTAssertEqual(count, 200)
    }
    
    func testWidthHeight() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 800), collectionViewLayout: layout)
        layout.setBaseCellWidth(100)
        
        let count = layout.calculateBaseItemHeight()
        
        XCTAssertEqual(count, 100)
    }
    
    func testWidthRatioHeight() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 800), collectionViewLayout: layout)
        layout.setBaseCellWidth(200)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateBaseItemHeight()
        
        XCTAssertEqual(count, 300)
    }
    
    func testColumnCountHeight() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 800), collectionViewLayout: layout)
        cv.contentSize = CGSize(width: 300, height: 800)
        layout.setColumnCount(3)
        layout.setBaseCellWidth(200)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateBaseItemHeight()
        
        XCTAssertEqual(count, 150)
    }
    
    func testColumnClosureHeight() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 800), collectionViewLayout: layout)
        cv.contentSize = CGSize(width: 400, height: 800)
        layout.calculateColumns = { 4 }
        layout.setColumnCount(3)
        layout.setBaseCellWidth(200)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateBaseItemHeight()
        
        XCTAssertEqual(count, 150)
    }
    
    func testHeight() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 800), collectionViewLayout: layout)
        layout.setBaseCellHeight(500)
        layout.calculateColumns = { 4 }
        layout.setColumnCount(3)
        layout.setBaseCellWidth(200)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateBaseItemHeight()
        
        XCTAssertEqual(count, 500)
    }
    
    func testDefaultWidth() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 800), collectionViewLayout: layout)
        
        let count = layout.calculateBaseItemWidth()
        
        XCTAssertEqual(count, 200)
    }
    
    func testHeightWidth() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 800), collectionViewLayout: layout)
        layout.setBaseCellHeight(100)
        
        let count = layout.calculateBaseItemWidth()
        
        XCTAssertEqual(count, 100)
    }
    
    func testRatioWidth() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 800), collectionViewLayout: layout)
        layout.setBaseCellHeight(150)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateBaseItemWidth()
        
        XCTAssertEqual(count, 100)
    }
    
    func testColumnCountWidth() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 800), collectionViewLayout: layout)
        cv.contentSize = CGSize(width: 300, height: 800)
        layout.setColumnCount(3)
        layout.setBaseCellHeight(150)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateBaseItemWidth()
        
        XCTAssertEqual(count, 100)
    }
    
    func testColumnClosureWidth() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 800), collectionViewLayout: layout)
        cv.contentSize = CGSize(width: 400, height: 800)
        layout.calculateColumns = { 4 }
        layout.setColumnCount(3)
        layout.setBaseCellHeight(200)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateBaseItemWidth()
        
        XCTAssertEqual(count, 100)
    }
    
    func testWidth() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: 400, height: 800), collectionViewLayout: layout)
        layout.setBaseCellWidth(500)
        layout.calculateColumns = { 4 }
        layout.setColumnCount(3)
        layout.setBaseCellHeight(200)
        layout.cellAspectRatio = CGSize(width: 2, height: 3)
        
        let count = layout.calculateBaseItemWidth()
        
        XCTAssertEqual(count, 500)
    }
    
    func testContentHeight() {
        let layout = LUXMultiSizeCollectionViewLayout()
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 800, height: 400), collectionViewLayout: layout)
        
        layout.cellAspectRatio = CGSize(width: 100, height: 100)
        layout.calculateColumns = {
            let columns: Int
            let screenWidth = cv.bounds.size.width
            if screenWidth > 700 {
                columns = 4
            } else if screenWidth > 500 {
                columns = 3
            } else {
                columns = 2
            }
            return columns
        }
        layout.widthInColumns = { [weak layout] indexPath, available in
            if (layout?.columnCount ?? 2) > 2 && available > 1 && indexPath.item == 0 {
                return 2
            }
            return 1
        }
        layout.heightInRows = { [weak layout] indexPath, available in
            if (layout?.columnCount ?? 2) > 2 && available > 1 && indexPath.item == 0 {
                return 2
            }
            return 1
        }
        
        layout.cacheFrames(1, { _ in 10 })
        layout.setContentSizeFromCache()
        
        XCTAssertEqual(layout.collectionViewContentSize.height, 800)
    }
}
