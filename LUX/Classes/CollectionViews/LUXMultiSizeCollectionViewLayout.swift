//
//  LUXPinterestCollectionLayout.swift
//  LUX
//
//  Created by Calvin Collins on 3/16/21.
//

import UIKit

public class LUXMultiSizeCollectionViewLayout: UICollectionViewLayout {
    var cache: [UICollectionViewLayoutAttributes] = []
    
    public var numCol:Int = 2 {
        didSet {
            invalidateLayout()
        }
    }
    public var cellHeight: CGFloat = 100 {
        didSet {
            invalidateLayout()
        }
    }
    private var numItems: Int {
        return collectionView?.numberOfItems(inSection: 0) ?? 0
    }
    private var numRows: Int {
        return numItems % numCol == 0 ? numItems / numCol : numItems / numCol + 1
    }
    public var padding: CGFloat = 6 {
        didSet {
            invalidateLayout()
        }
    }
    
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - insets.left - insets.right
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: CGFloat(numRows + 1) * cellHeight)
    }
    
    /**
     Override these methods to make the collectionviewLayout multisized
     */
    open var widthForCellAt = widthForObjectAt
    open var xForCellAt = xForObjectAt
    
    public override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        cache.removeAll()
        for item in 0..<numItems {
            let indexPath = IndexPath(item: item, section: 0)
            let y = CGFloat(Int(item/numCol)) * cellHeight
            let x = self.xForCellAt(collectionView, numCol, IndexPath(item: item, section: 0))
            let width = self.widthForCellAt(collectionView, numCol, IndexPath(item: item, section: 0))
            let frame = CGRect(x: x, y: y, width: width, height: cellHeight)
            let inset = frame.insetBy(dx: padding, dy: padding)
            
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = inset
            cache.append(attribute)
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
    
    public func layout(_ attributes: inout [UICollectionViewLayoutAttributes], height: CGFloat, numCol: Int, numItems: Int, padding: CGFloat) {

    }
}

public let widthForObjectAt: (UICollectionView, Int, IndexPath) -> CGFloat = { collectionView, cols, _ in
    let insets = collectionView.contentInset
    return (collectionView.frame.width - insets.left - insets.right)/CGFloat(cols)
}
public let xForObjectAt: (UICollectionView, Int, IndexPath) -> CGFloat = { collectionView, cols, path in
    let width = widthForObjectAt(collectionView, cols, path)
    return width * CGFloat(path.item % cols)
}
