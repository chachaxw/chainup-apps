//
//  EXHomeScrollFlowLayout.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/18.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXHomeScrollFlowLayout: UICollectionViewFlowLayout {
    private var sectionDic : [String:Int] = [:]
    private var allAttributes:[UICollectionViewLayoutAttributes] = []
    
    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        guard  let collection = self.collectionView else {
            return
        }
        let section = collection.numberOfSections
        self.allAttributes.removeAll()
        for sec in 0..<section {
            let count = collection.numberOfItems(inSection: sec)
            for item in 0..<count {
                let indexPath = IndexPath.init(item: item, section: sec)
                if let attributes = self.layoutAttributesForItem(at: indexPath) {
                    self.allAttributes.append(attributes)
                }
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        guard  let collection = self.collectionView else {
            return CGSize(width: 0, height: 0)
        }
        
        var actualLo = 0
        for (_,value) in sectionDic {
            actualLo += value
        }
        return CGSize(width: CGFloat(actualLo)*collection.frame.width, height: collection.contentSize.height)
    }
    
    
    func applyLayoutAttributes(attributes:UICollectionViewLayoutAttributes) {
        
        guard let collection = self.collectionView else {
            return
        }
        
        
        if let _ = attributes.representedElementKind {
            return
        }
        

        let itemW = attributes.frame.size.width
        let itemH = attributes.frame.size.height
        
        let width = collection.frame.size.width
        let height = collection.frame.size.height
        
        let itemIdx = attributes.indexPath.item
        
        let stride:CGFloat = (self.scrollDirection == .horizontal) ? width : height
        
        let section = attributes.indexPath.section
        let itemCount = collection.numberOfItems(inSection: section)
        
        let offset:CGFloat = CGFloat(section) * stride
        
        //Calculate the number of items in the x direction
        let xCount:Int = Int((width / itemW))
        //Calculate the number of items in the y direction
        let yCount:Int = Int((height / itemH))
        //Calculate the total number of pages
        let allCount = (xCount * yCount)
        //Get the number of pages for each section, starting from 0
        let page = itemIdx / allCount
        
        //Remainder, used to calculate the offset of item x
        let remain = (itemIdx % xCount)
        
        //Quotient, used to calculate the offset of item y
        let merchant = (itemIdx-page*allCount)/xCount

        //Offset of each item in the x-direction
        var xCellOffset = CGFloat(remain) * itemW
        //Offset of each item in the y-direction
        var yCellOffset = CGFloat(merchant) * itemH
        
        
        //Obtain the number of pages occupied by items in each section
        let pageRe = (itemCount % allCount == 0) ? (itemCount / allCount) : (itemCount / allCount) + 1

        //Correspond each section to pageRe and calculate the following positions
        let key = "\(section)"
        sectionDic[key] = pageRe
        
        if(self.scrollDirection == .horizontal) {
            
            var actualLo = 0;
            //Add the number of pages in each section
            for (_,value) in sectionDic {
                actualLo += value
            }
            //Subtract the last set of page numbers from the last number obtained
            let lastSection = sectionDic.count - 1
            if let lastPage = sectionDic["\(lastSection)"] {
                actualLo -= lastPage
            }
            let pageWidth = CGFloat(page) * width
            let actualWidth = CGFloat(actualLo) * width
            xCellOffset += (pageWidth + actualWidth)

        } else {
            yCellOffset += offset
        }
        attributes.frame = CGRect(x: xCellOffset, y: yCellOffset, width: itemW, height: itemH)
    }
    
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attr = super.layoutAttributesForItem(at: indexPath) {
            self.applyLayoutAttributes(attributes: attr)
            return attr
        }
        return nil
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.allAttributes
    }
    
}

