//
//  EXAssetHeader.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXAssetHeader: NibBaseView {
    @IBOutlet var headerCollection: UICollectionView!
    var dataList:[EXCommonAssetModel] = []
    typealias PageValueChange = (Int) -> ()
    var currentPageCallback:PageValueChange?
    var page:Int = 0
    
    override func onCreate() {
        prepare()
    }

    func prepare() {
        headerCollection.register(UINib.init(nibName: "EXAssetCollectionCell", bundle: nil)
            , forCellWithReuseIdentifier: "EXAssetCollectionCell")
        let flowLayout = EXCollectionCenterFlowLayout()
        flowLayout.pageCallback = {[weak self] page in
            self?.page = page
            self?.currentPageCallback?(page)
        }
        headerCollection.showsHorizontalScrollIndicator = false
        headerCollection.showsVerticalScrollIndicator = false 
        headerCollection.collectionViewLayout = flowLayout
        headerCollection.isPagingEnabled = false
        headerCollection.backgroundColor = UIColor.ThemeNav.bg 
    }
    
    func updateHeaderDatas(_ models:[EXCommonAssetModel]) {
        dataList.removeAll()
        self.dataList = models
        self.headerCollection.reloadData()
    }
    
    func reloadHeader() {
        self.headerCollection.reloadData()
    }
    
    func headerScroll(_ toIndex:Int) {
        self.headerCollection.scrollToItem(at: IndexPath.init(row: toIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
}

extension EXAssetHeader : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let assetModel = self.dataList[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EXAssetCollectionCell", for: indexPath) as! EXAssetCollectionCell
        cell.bindAssetModel(assetModel)
        return cell
    }
}
