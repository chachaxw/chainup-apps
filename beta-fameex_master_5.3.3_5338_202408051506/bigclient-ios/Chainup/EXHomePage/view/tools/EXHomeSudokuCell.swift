//
//  EXHomeSudokuView.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/12.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit

class EXHomeSudokuCell: EXHomeBaseCell {
    
    static let collectionItemHeight:CGFloat = 60
    static let numberOfColumn:Int = 5
    static let collectionTopY:CGFloat = 12
    var style:HomeKingKongType = .singleRow
    var sudokudatas:[CmsAppDataItem] = []
    typealias MoreKingKongCallback = ()->()
    var onMoreCallback:MoreKingKongCallback?
    
    lazy var sudokuCollection : UICollectionView = {
        let collectionV = UICollectionView.init(frame: CGRect.zero , collectionViewLayout: self.getCollectionLayout())
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.showsVerticalScrollIndicator = false
        collectionV.backgroundColor = UIColor.ThemeView.bg
        collectionV.register(EXHomeFuncCC.classForCoder(), forCellWithReuseIdentifier: "EXHomeFuncCC")
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.isPagingEnabled = true
        collectionV.bounces = false
        collectionV.clipsToBounds = false
        if #available(iOS 11.0, *) {
            collectionV.contentInsetAdjustmentBehavior = .never
        }
        return collectionV
    }()
    
    //indicator
    lazy var pageControl : EXPageControl = {
        let pageControl = EXPageControl()
        pageControl.isHidden = true
        pageControl.extUseAutoLayout()
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(pageControl)
        contentView.addSubview(sudokuCollection)
        

        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(2)
            make.left.right.equalToSuperview()
        }
    }
    
    func getCollectionLayout() -> UICollectionViewFlowLayout{
        let width = (SCREEN_WIDTH / CGFloat(EXHomeSudokuCell.numberOfColumn)).rounded(.down)
        let collectionLayout = EXHomeScrollFlowLayout.init()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.minimumLineSpacing = 0
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.itemSize = CGSize.init(width: width, height: EXHomeSudokuCell.collectionItemHeight)
        return collectionLayout
    }
    
    func bindSudokus(_ arr :[CmsAppDataItem],style:HomeKingKongType){
        sudokudatas = arr
        self.style = style
        var itemH:CGFloat = 0
        if arr.count > 0 {
            if style == .singleRow {
                itemH = EXHomeSudokuCell.collectionItemHeight
            }else if style == .doubleRow {
                if arr.count <= EXHomeSudokuCell.numberOfColumn {
                    itemH = EXHomeSudokuCell.collectionItemHeight
                }else {
                    itemH = EXHomeSudokuCell.collectionItemHeight*2
                }
            }
        }
        sudokuCollection.frame = CGRect.init(x: 0, y: EXHomeSudokuCell.collectionTopY, width: SCREEN_WIDTH, height: itemH)
        sudokuCollection.reloadData()
    }
    
    func addEntity(){
        sudokudatas.append(CmsAppDataItem())
        if sudokudatas.count % EXHomeSudokuCell.numberOfColumn > 0{
            addEntity()
        }
    }
    
    //Monitor manual deceleration completion
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetx : CGFloat = scrollView.contentOffset.x
        let page : Int = Int(offsetx/SCREEN_WIDTH)
        pageControl.currentPage = page
    }
    
    //End of scrolling animation
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXHomeSudokuCell {
    
    class func getHeightBySudokuItems(count: Int,style:HomeKingKongType) -> CGFloat {
        //Top 16+item height 64+bottom 2
        var itemHeight:CGFloat = 0
        if count > 0 {
            if style == .singleRow {
                itemHeight = EXHomeSudokuCell.collectionItemHeight
            }else {
                if count <= EXHomeSudokuCell.numberOfColumn {
                    itemHeight = EXHomeSudokuCell.collectionItemHeight
                }else {
                    itemHeight = EXHomeSudokuCell.collectionItemHeight*2
                }
            }

            return EXHomeSudokuCell.collectionTopY + itemHeight + 4
        }else {
            return 0
        }
    }
    
}

extension EXHomeSudokuCell : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if style == .singleRow {
            return min(sudokudatas.count, EXHomeSudokuCell.numberOfColumn)
        }else  {
            return min(sudokudatas.count,EXHomeSudokuCell.numberOfColumn*2)
        }
    }
    
    func isMoreCellIdx(idxPath:IndexPath) ->Bool {
        var isMoreCell:Bool = false
        if self.style == .singleRow {
            if sudokudatas.count > EXHomeSudokuCell.numberOfColumn,idxPath.row == EXHomeSudokuCell.numberOfColumn - 1 {
                isMoreCell = true
            }
        }else if self.style == .doubleRow {
            if sudokudatas.count > EXHomeSudokuCell.numberOfColumn*2,idxPath.row == EXHomeSudokuCell.numberOfColumn*2 - 1 {
                isMoreCell = true
            }
        }
        return isMoreCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entity = sudokudatas[indexPath.row]
        let cell : EXHomeFuncCC = collectionView.dequeueReusableCell(withReuseIdentifier: "EXHomeFuncCC", for: indexPath) as! EXHomeFuncCC
        if isMoreCellIdx(idxPath: indexPath) {
            cell.nameLabel.text =  "common_action_showMore".localized()
            cell.imgV.image = EXKitBundle.svgImage(named: "home_service_more")
        }else {
            cell.bindCell(entity)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isMoreCellIdx(idxPath: indexPath) {
            self.onMoreCallback?()
        }else {
            let entity = sudokudatas[indexPath.row]
            if entity.type == ""{
                return
            }
            if let vc = self.yy_viewController{
                HomeGOTO().gotoVC(vc, tnativeUrl: entity.nativeUrl, httpUrl: entity.fmtUrl(),title:entity.title)
            }
        }
    }
}

