//
//  EXCollectionCenterFlowLayout.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXCollectionCenterFlowLayout: UICollectionViewFlowLayout {
    var itemWidth : CGFloat = SCREEN_WIDTH - 35
    var horizonGap : CGFloat = 8
    typealias ScrollPageCallback = (Int)  -> ()
    var pageCallback:ScrollPageCallback?
    
    override init() {
        super.init()
        customPrepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customPrepare()
        fatalError("init(coder:) has not been implemented")
    }
    
    func customPrepare() {
        self.itemSize = CGSize(width: itemWidth, height: 120)
        self.minimumLineSpacing = horizonGap
        self.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
//        let horizontalInset = (SCREEN_WIDTH - itemWidth) / 2
        self.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 15, right: 15)
    }
    
    func pageWidth() -> CGFloat {
        return self.itemSize.width + self.minimumLineSpacing
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let contentX = self.collectionView!.contentOffset.x
        let currentPage = contentX / self.pageWidth()
        if fabs(velocity.x) > 0.2 {
            let nextPage = velocity.x > 0 ? ceilf(Float(currentPage)) : floorf(Float(currentPage))
            let pointX = CGFloat(roundf(Float(nextPage))) * self.pageWidth()
            pageCallback?(Int(nextPage))
            return CGPoint(x: pointX, y: proposedContentOffset.y)
        }else {
            let nextpage = roundf(Float(currentPage))
            pageCallback?(Int(nextpage))
            let pointX = CGFloat(nextpage) * self.pageWidth()
            return CGPoint(x:pointX, y: proposedContentOffset.y)
        }
        
//        pageCallback()
    }
}
