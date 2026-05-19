//
//  EXHomeNominateCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/12.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
import Swap
//Left and right spacing 16 3 cells 2 spacing 16
let EXHomeNominateCellMaxWidth = (SCREEN_WIDTH - 16 * 2 - 16 * 2) / 3
class EXHomeNominateCell: EXHomeBaseCell {
    var itemSizeDic = [String: CGSize]()
    var recommends : [EXHomeTicker] = []
    
    lazy var collectionV : UICollectionView = {
        let collectionV = UICollectionView.init(frame: CGRect.init(x: Margin_L, y: 0, width: SCREEN_WIDTH - Margin_LL, height: collectionCCSize.1) , collectionViewLayout: getCollectionLayout())
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.backgroundColor = UIColor.ThemeView.bg
        collectionV.register(RecommendCVC.classForCoder(), forCellWithReuseIdentifier: "RecommendCVC")
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.isPagingEnabled = false
        collectionV.backgroundColor = UIColor.ThemeView.bg
        collectionV.isScrollEnabled = false
        return collectionV
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubViews([collectionV])

    }
    
    
    lazy var collectionCCSize : (CGFloat,CGFloat) = {
        let width = (SCREEN_WIDTH - Margin_LL) / 3
        if EXHomeViewModel.isUIStatusNormal() {
            if EXHomeViewModel.homepageStyle() == .momo{
                return (width,107)
            }
            return (width,92)
        }else if EXHomeViewModel.status() == .two{
            return (width,92)
        }
        return (0,0)
    }()
    
    
    func getCollectionLayout() -> UICollectionViewFlowLayout{
        let collectionLayout = UICollectionViewFlowLayout.init()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.minimumLineSpacing = 16
        collectionLayout.itemSize = CGSize.init(width: collectionCCSize.0, height: collectionCCSize.1)
        return collectionLayout
    }
    
    
    func bindRecommendCoins(_ coins:[EXHomeTicker]) {
        recommends = coins
        
        //        pageControl.isHidden = coins.count <= 3
        //        if coins.count % 3 > 0{
        //            let count  = CGFloat(coins.count / 3 + 1)
        //
        //            pageControl.snp.remakeConstraints { (make) in
        //                make.centerX.equalToSuperview()
        //                make.bottom.equalToSuperview().offset(-6)
        //                make.height.equalTo(2)
        //                make.width.equalTo(pageControl.sliderWidth*count)
        //            }
        //        }else{
        //            let count  = CGFloat(coins.count / 3)
        //
        //            pageControl.snp.remakeConstraints { (make) in
        //                make.centerX.equalToSuperview()
        //                make.bottom.equalToSuperview().offset(-6)
        //                make.height.equalTo(2)
        //                make.width.equalTo(pageControl.sliderWidth*count)
        //            }
        //        }
        
        collectionV.reloadData()
    }
    
    func updateNewItem(homeTicker:EXHomeTicker,idx:Int) {
        if recommends.count > idx {
            if let cell = collectionV.cellForItem(at: IndexPath.init(row: idx, section: 0 )) as? RecommendCVC {
                cell.bindCellRecommends(homeTicker)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gotoContractDetailVC(row:Int) {
        
        let tickerModel = recommends[row]
        var itemModel = tickerModel.itemModel
        if itemModel == nil {
            itemModel = tickerModel.mapToBtItemModel()
        }
        let vc = EXSwapKLineDetailVC()
        vc.itemModel = itemModel
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}



extension EXHomeNominateCell :  UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entity = recommends[indexPath.row]
        let cell : RecommendCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendCVC", for: indexPath) as! RecommendCVC
        cell.bindCellRecommends(entity)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if EXHomeViewModel.isContractStatus() {
            gotoContractDetailVC(row:indexPath.row)
            return
        }
        
        let entity = recommends[indexPath.row]
        
        let coinmapentity = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(entity.name)
        let vc = EXKlineDetailNewVC(entity: coinmapentity)
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let entity = recommends[indexPath.item]
        
        let itemKey = entity.showName
        
        if let itemSize = itemSizeDic[itemKey]{
            return itemSize
        }
        
        let title = entity.showName + "+100.99%" //Calculate the maximum width based on the maximum fluctuation range
        
        var maxWidth = title.textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width: SCREEN_WIDTH).width + 2
        
        if maxWidth > EXHomeNominateCellMaxWidth {
            maxWidth = EXHomeNominateCellMaxWidth
        }
        if maxWidth <= 2 {
            maxWidth = EXHomeNominateCellMaxWidth
        }
        var size = CGSize(width: maxWidth, height: 92)
        if EXHomeViewModel.isUIStatusNormal() {
            if EXHomeViewModel.homepageStyle() == .momo{
                size = CGSize(width: maxWidth, height: 107)
            }
        }
        itemSizeDic[itemKey] = size
        return size
    }
}


