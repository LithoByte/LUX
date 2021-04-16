//
//  LUXPinterestCollectionLayout.swift
//  LUX
//
//  Created by Calvin Collins on 3/16/21.
//

import UIKit

public func multiSizeInsetsForPadding(_ horizontal: CGFloat, _ vertical: CGFloat) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: vertical, right: horizontal)
}

public class LUXMultiSizeCollectionViewLayout: UICollectionViewLayout {
    
    /**
     Override these methods to make the collectionviewLayout multisized
     */
    open var widthInColumns: (IndexPath, Int) -> Int = { _,_ in return 1 }
    open var heightInRows: (IndexPath, Int) -> Int = { _,_ in return 1 }
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var _columnCount: Int? { didSet { invalidateLayout() }}
    public var calculateColumns: (() -> Int)?
    public func setColumnCount(_ columns: Int) { _columnCount = columns }
    
    private var _baseCellWidth: CGFloat? { didSet { invalidateLayout() }}
    public func setBaseCellWidth(_ width: CGFloat) { _baseCellWidth = width }
    
    private var _baseCellHeight: CGFloat? { didSet { invalidateLayout() }}
    public func setBaseCellHeight(_ height: CGFloat) { _baseCellHeight = height }
    
    private var _contentSize: CGSize? { didSet { invalidateLayout() }}
    public func setContentSize(_ contentSize: CGSize) { _contentSize = contentSize }
    
    private var itemCount: Int { calculateItemCount() }
    
    public var cellAspectRatio: CGSize?
    public var columnCount: Int { calculateDefaultColumnCount() }
    public var baseCellWidth: CGFloat { calculateBaseItemWidth() }
    public var baseCellHeight: CGFloat { calculateBaseItemHeight() }
    
    open var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - insets.left - insets.right
    }
    
    public override var collectionViewContentSize: CGSize {
        return _contentSize ?? CGSize(width: contentWidth, height: CGFloat(itemCount * columnCount) * baseCellHeight)
    }
    
    open func calculateItemCount() -> Int {
        var count = 0
        if let cv = collectionView {
            for i in 0..<cv.numberOfSections { count += cv.numberOfItems(inSection: i) }
        }
        return count
    }
    
    open func calculateBaseItemWidth() -> CGFloat {
        if let width = _baseCellWidth { return width }
        if let columns = calculateColumns?() {
            return contentWidth / CGFloat(columns)
        }
        if let columns = _columnCount { return contentWidth / CGFloat(columns) }
        if let height = _baseCellHeight, let ratio = cellAspectRatio {
            return ratio.width * height / ratio.height
        }
        if let height = _baseCellHeight { return height }
        
        return 200
    }
    
    open func calculateBaseItemHeight() -> CGFloat {
        if let height = _baseCellHeight { return height }
        if let columns = calculateColumns?(), let ratio = cellAspectRatio {
            let width = contentWidth / CGFloat(columns)
            return ratio.height * width / ratio.width
        }
        if let columns = _columnCount, let ratio = cellAspectRatio {
            let width = contentWidth / CGFloat(columns)
            return ratio.height * width / ratio.width
        }
        if let width = _baseCellWidth, let ratio = cellAspectRatio {
            return ratio.height * width / ratio.width
        }
        if let width = _baseCellWidth { return width }
        
        return 200
    }
    
    open func calculateDefaultColumnCount() -> Int {
        if let columns = calculateColumns?() { return columns }
        if let columns = _columnCount { return columns }
        if let width = _baseCellWidth { return Int(contentWidth / width) }
        if let height = _baseCellHeight, let ratio = cellAspectRatio {
            let width = ratio.width * height / ratio.height
            return Int(contentWidth / width)
        }
        
        return 2
    }
    
    
    public override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        cacheFrames(collectionView.numberOfSections, collectionView.numberOfItems(inSection:))
        
        setContentSizeFromCache()
    }
    
    open func setContentSizeFromCache() {
        if let last = cache.last {
            _contentSize = CGSize(width: contentWidth, height: last.frame.minY + last.frame.height)
        }
    }
    
    open func cacheFrames(_ numberOfSections: Int, _ numberOfItemsInSection: (Int) -> Int) {
        cache.removeAll()
        for i in 0..<numberOfSections {
            let itemCount = numberOfItemsInSection(i)
            var grid = [[Bool]](repeating: [Bool](repeating: true, count: columnCount), count: itemCount)
            for j in 0..<itemCount {
                let indexPath = IndexPath(item: j, section: i)
                
                let sizeOptions = sizeOptionsInUnits(grid)
                let widthCount = widthInColumns(indexPath, sizeOptions.2)
                let heightCount = heightInRows(indexPath, sizeOptions.2)
                grid = fill(grid, sizeOptions, widthCount, heightCount)
                
                let x = CGFloat(sizeOptions.0) * baseCellWidth
                let y = CGFloat(sizeOptions.1) * baseCellHeight
                let width = CGFloat(widthCount) * baseCellWidth
                let height = CGFloat(heightCount) * baseCellHeight
                
                let frame = CGRect(x: x, y: y, width: width, height: height)
                
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attribute.frame = frame
                cache.append(attribute)
            }
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        for attribute in cache {
            if attribute.frame.intersects(rect) {
                attributes.append(attribute)
            }
        }
        return attributes
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

func sizeOptionsInUnits(_ grid: [[Bool]]) -> (Int, Int, Int) {
    var y = 0
    var x = 0
    var count = 0
    for i in 0..<grid.count {
        let row = grid[i]
        for j in 0..<row.count {
            if row[j] {
                if count == 0 {
                    y = i
                    x = j
                    count = 1
                } else {
                    count += 1
                }
            } else if count != 0 {
                break
            }
        }
        if count != 0 {
            return (x, y, count)
        }
    }
    return (x, y, count)
}

func fill(_ grid: [[Bool]], _ sizeOptions: (Int, Int, Int), _ widthCount: Int, _ heightCount: Int) -> [[Bool]] {
    var grid = grid
    for m in 0..<widthCount {
        for n in 0..<heightCount {
            grid[sizeOptions.1 + n][sizeOptions.0 + m] = false
        }
    }
    return grid
}
