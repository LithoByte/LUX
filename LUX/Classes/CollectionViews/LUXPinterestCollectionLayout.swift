//
//  LUXPinterestCollectionLayout.swift
//  LUX
//
//  Created by Calvin Collins on 3/16/21.
//

import UIKit

public class LUXPinterestCollectionLayout: UICollectionViewLayout {
    var cache: [UICollectionViewLayoutAttributes] = []
    var delegate: LUXPinterestCollectionViewLayoutDelegate?
    
    private var numCol:Int = 2
    private var cellHeight: CGFloat = 100
    private var numItems: Int {
        return collectionView?.numberOfItems(inSection: 0) ?? 0
    }
    private var numRows: Int {
        return numItems % numCol == 0 ? numItems / numCol : numItems / numCol + 1
    }
    private var padding: CGFloat = 6
    
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - insets.left - insets.right
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: CGFloat(numRows + 1) * cellHeight)
    }
    
    public override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        cache.removeAll()
        for item in 0..<numItems {
            let indexPath = IndexPath(item: item, section: 0)
            let y = CGFloat(Int(item/numCol)) * cellHeight
            guard let x = delegate?.collectionView(collectionView, xForObjectAt: IndexPath(item: item, section: 0)), let width = delegate?.collectionView(collectionView, widthForObjectAt: IndexPath(item: item, section: 0)) else { continue }
            
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

protocol LUXPinterestCollectionViewLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, widthForObjectAt indexPath: IndexPath) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, xForObjectAt indexPath: IndexPath) -> CGFloat
}
