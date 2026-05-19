//
//  Screening CollectionView.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/28.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit

class ScreeningCollectionView: UIView {
    
    typealias ClickCellBlock = (Int) -> ()
    var clickCellBlock : ClickCellBlock?
    
    var collectionDatas : [CoinEntity] = [CoinEntity()]
    let collectionVH :CGFloat = 30
//    var fromKline = false
//    var max = 5
//    {
//        didSet{
//            collectionV.setCollectionViewLayout(getCollectionLayout(), animated: false)
//        }
//    }
    
    var F_width = SCREEN_WIDTH
    {
        didSet{
            collectionV.setCollectionViewLayout(getCollectionLayout(), animated: false)
        }
    }
    
    var num = 10
    
    lazy var collectionV : UICollectionView = {
        let collectionV = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: collectionVH) , collectionViewLayout: getCollectionLayout())
//        collectionV.collectionViewLayout.invalidateLayout()
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.extUseAutoLayout()
        collectionV.register(CoinCVC.classForCoder(), forCellWithReuseIdentifier: "CoinCVC")
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.backgroundColor = UIColor.ThemeNav.bg
        return collectionV
    }()
    
    func getCollectionLayout() -> UICollectionViewFlowLayout{
        let width = F_width / CGFloat((self.collectionDatas.count <= num ? self.collectionDatas.count : num))
        let collectionLayout = UICollectionViewFlowLayout.init()
        collectionLayout.scrollDirection = .horizontal
//        collectionLayout.minimumLineSpacing = 20
//        collectionLayout.itemSize = CGSize.init(width: width, height: collectionVH)
        collectionLayout.estimatedItemSize = CGSize.init(width: width, height: collectionVH)
//        collectionLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        return collectionLayout
    }
    
    //Update the constraints of collectionView after obtaining data
    func reloadCollectionVLayout(){
//        DispatchQueue.main.async {
            self.collectionV.collectionViewLayout.invalidateLayout()
            UIView.setAnimationsEnabled(false)
            self.collectionV.reloadData()
            self.collectionV.setCollectionViewLayout(self.getCollectionLayout(), animated: true)
            UIView.setAnimationsEnabled(true)
            self.collectionV.reloadData()
//        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionDatas[0].showLine = true
        addSubview(collectionV)
        collectionV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func updateCollectionV(_ frame : CGRect){
        collectionV = UICollectionView.init(frame: frame, collectionViewLayout: getCollectionLayout())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionV.collectionViewLayout.invalidateLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ScreeningCollectionView : UICollectionViewDelegate,UICollectionViewDataSource{
    //MARK:------------------------------CollectionDelegate----------------------------------
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entity = collectionDatas[indexPath.row]
        let cell : CoinCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinCVC", for: indexPath) as! CoinCVC
        cell.tag = 1000 + indexPath.row
        cell.setCellWithEntity(entity,self.fromKline)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        //Click on cell to update
        updateCollectionCell(collectionView, didSelectItemAt: indexPath)
    }
    
    //Update collectionCell
    func updateCollectionCell(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        clickCellBlock?(indexPath.row)
        slidingCollection(indexPath)
    }
    
    func slidingCollection(_ indexPath : IndexPath){
        for i in 0..<collectionDatas.count{
            if indexPath.row == i{
                collectionDatas[i].showLine = true
                if let cell = self.collectionV.cellForItem(at: indexPath) as? CoinCVC{
                    cell.setCellWithEntity(collectionDatas[i])
                }
            }else{
                if collectionDatas[i].showLine == true{
                    collectionDatas[i].showLine = false
                    if let cell = self.collectionV.cellForItem(at: IndexPath.init(row: i, section: 0)) as? CoinCVC{
                        cell.setCellWithEntity(collectionDatas[i])
                    }
                }else{
                    collectionDatas[i].showLine = false
                }
            }
        }
//        self.collectionV.layoutIfNeeded()
        self.collectionV.reloadData()
        if collectionDatas.count > indexPath.row{
            self.collectionV.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }
    

}


