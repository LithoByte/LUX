//
//  LUXPinterestStyleLayout.swift
//  LUX
//
//  Created by Remmington Damper on 12/12/21.
//

import UIKit


public class LUXPinterestStyleLayout: UICollectionViewLayout {
    private var _columnCount: Int? { didSet { invalidateLayout() }}
    public func setColumnCount(_ count: Int) { _columnCount = count }
    
    private var _cellPadding: CGFloat = 0 {didSet { invalidateLayout() }}
    public func setCellPadding(_ padding: CGFloat = 0) { _cellPadding = padding }
    
    private var _tuple: (columnCount: Int, baseItemWidth: CGFloat) = (0, 0.0)
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var _baseItemWidth: CGFloat? { didSet { invalidateLayout() }}
    public func setBaseItemWidth(_ width: CGFloat) { _baseItemWidth = width }
    
    public var widthForColumn: ((Int) -> CGFloat?)? = { _ in return nil }
    
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }
  
    private var _contentSize: CGSize? { didSet { invalidateLayout() }}
    public func setContentSize(_ size: CGSize) { _contentSize = size }
   
    private var itemCount: Int { calculateItemCount() }
    
    open var heightForCellAtIndexPath: ((UICollectionView, IndexPath) -> CGFloat)?
    
    
    open func setContentSizeFromCache() {
        if let last = cache.last {
            _contentSize = CGSize(width: contentWidth, height: last.frame.minY + last.frame.height)
        }
    }
    
    public override var collectionViewContentSize: CGSize {
      return _contentSize ?? CGSize(width: contentWidth, height: contentHeight)
    }
    
    open func calculateItemCount() -> Int {
        var count = 0
        if let cv = collectionView {
            for i in 0..<cv.numberOfSections { count += cv.numberOfItems(inSection: i) }
        }
        return count
    }
    
    public override func prepare() {
        super.prepare()
        
        cacheFramesAndCalculate()
        setContentSizeFromCache()

    }
    
    private func calculateXOffset() -> [CGFloat] {
        var columnCount: Int = 0
        var xOffSet: [CGFloat] = []
        var offSet: CGFloat = 0
        
        if let columnCount = _columnCount {
            let columnWidth = contentWidth / CGFloat(_columnCount!)
            offSet = columnWidth
            for column in 0..<columnCount {
                xOffSet.append(offSet * CGFloat(column))
            }
        } else if let baseWidth = _baseItemWidth {
            if _columnCount == nil {
                columnCount = Int(contentWidth / baseWidth)
                offSet = baseWidth / CGFloat(columnCount)
                
                for column in 0..<columnCount {
                    xOffSet.append(offSet * CGFloat(column))
                }
            } else {
                columnCount = _columnCount!
                for column in 0..<columnCount {
                    xOffSet.append((CGFloat(baseWidth)) * CGFloat(column))
                }
            }
        } else {
            for column in 0..<2 {
                xOffSet.append((contentWidth / 2) * CGFloat(column))
            }
        }
        return xOffSet
    }
    
    open func cacheFramesAndCalculate() {
        cache.removeAll()
        guard cache.isEmpty, let collectionView = collectionView else { return }
        
        let xOffset = calculateXOffset()
        let columnWidth = contentWidth / CGFloat(_columnCount!)
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: _columnCount!)

        for item in 0..<itemCount {
        let indexPath = IndexPath(item: item, section: 0)
            
        let photoHeight = heightForCellAtIndexPath?(collectionView, indexPath) ?? 180
            let height = _cellPadding * 2 + photoHeight
            
            //had to give a magic number. Not sure if the magic number is good.
            let frame = CGRect(x: xOffset[column],
                             y: yOffset[column],
                             width: columnWidth,
                             height: height)
        let insetFrame = frame.insetBy(dx: _cellPadding, dy: _cellPadding)
            
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = insetFrame
        cache.append(attributes)

        contentHeight = max(contentHeight, frame.maxY)
        yOffset[column] = yOffset[column] + height

            column = column < ( _columnCount! - 1) ? (column + 1) : 0
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
