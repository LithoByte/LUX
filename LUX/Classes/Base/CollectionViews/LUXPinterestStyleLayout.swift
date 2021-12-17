//
//  LUXPinterestStyleLayout.swift
//  LUX
//
//  Created by Remmington Damper on 12/12/21.
//

import UIKit


public class LUXPinterestStyleLayout: UICollectionViewLayout {
    
    private var numberOfColumns = 2
    private let cellPadding: CGFloat = 6
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    
    private var _contentSize: CGSize? { didSet { invalidateLayout() }}
    public func setContentSize(_ contentSize: CGSize) { _contentSize = contentSize }
    
    open var heightForCellAtIndexPath: ((UICollectionView, IndexPath) -> CGFloat)?
    
    private var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    open func setContentSizeFromCache() {
        if let last = cache.last {
            _contentSize = CGSize(width: contentWidth, height: last.frame.minY + last.frame.height)
        }
    }
    
    public override var collectionViewContentSize: CGSize {
      return CGSize(width: contentWidth, height: contentHeight)
    }
    
    public override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        cacheFramesAndCalculate(collectionView.numberOfSections, collectionView.numberOfItems(inSection:))
        
        setContentSizeFromCache()

    }
    
    open func cacheFramesAndCalculate(_ numberOfSections: Int, _ numberOfItemsInSection: (Int) -> Int) {
        cache.removeAll()
        guard cache.isEmpty, let collectionView = collectionView else { return }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        
        for column in 0..<numberOfColumns {
          xOffset.append(CGFloat(column) * columnWidth)
        }
        
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
          let indexPath = IndexPath(item: item, section: 0)
            
            let photoHeight = heightForCellAtIndexPath?(collectionView, indexPath) ?? 180
          let height = cellPadding * 2 + photoHeight
          let frame = CGRect(x: xOffset[column],
                             y: yOffset[column],
                             width: columnWidth,
                             height: height)
          let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
          let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
          attributes.frame = insetFrame
          cache.append(attributes)

          contentHeight = max(contentHeight, frame.maxY)
          yOffset[column] = yOffset[column] + height

          column = column < (numberOfColumns - 1) ? (column + 1) : 0
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
