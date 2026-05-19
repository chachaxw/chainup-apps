//
//  EXHomeMenuSheet.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/27.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXHomeMenuSheet: UIView {
    
    var sudokudatas:[CmsAppDataItem] = []
    let animationDuration: Double = 0.8
    let delayBase: Double = 0.1
    
    var showedIdxPath:[IndexPath] = []
    typealias MenuCallback = (CmsAppDataItem) -> ()
    var menuItemCallback:MenuCallback?
    
    lazy var titleBg:UIView = {
        let l = UIView()
        l.backgroundColor = UIColor.ThemeView.bg
        return l
    }()
    
    lazy var titleLabel:UILabel = {
        let l = UILabel()
        l.textColor = UIColor.ThemeLabel.colorLite
        l.font = UIFont.ThemeFont.HeadMedium
        l.text = "common_action_showMore".localized()
        return l
    }()
    
    lazy var closeBtn:UIButton = {
        let l = UIButton.init(type: .custom)
        l.setImage(UIImage.themeImageNamed(imageName: "sheet_close"), for: .normal)
        l.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return l
    }()
    
    
    lazy var sudokuCollection : UICollectionView = {
        let collectionV = UICollectionView.init(frame: CGRect.zero , collectionViewLayout: EXKitLayouts.homeMenuVerticalLayouts())
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.showsVerticalScrollIndicator = false
        collectionV.backgroundColor = UIColor.ThemeView.bg
        collectionV.register(EXHomeFuncCC.classForCoder(), forCellWithReuseIdentifier: "EXHomeFuncCC")
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.isPagingEnabled = false
        collectionV.bounces = true
        collectionV.clipsToBounds = false
        if #available(iOS 11.0, *) {
            collectionV.contentInsetAdjustmentBehavior = .never
        }
        return collectionV
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: [.topLeft,.topRight], radius: 20)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubViews([sudokuCollection,titleBg])
        titleBg.addSubview(titleLabel)
        titleBg.addSubview(closeBtn)
        
        titleBg.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(MARGIN_LEFT)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-MARGIN_LEFT)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    func bindSudokus(_ arr :[CmsAppDataItem]){
        sudokudatas = arr
        var itemH:CGFloat = 0
        let layout = EXKitLayouts.homeMenuVerticalLayouts()
        let itemSectionH = layout.sectionInset.top + layout.sectionInset.bottom
        
        let numberOfLines:CGFloat = CGFloat(ceilf(Float(arr.count)/Float(EXHomeSudokuCell.numberOfColumn)))
        
        if arr.count > 0 {
            if arr.count <= EXHomeSudokuCell.numberOfColumn {
                itemH = layout.itemSize.height + itemSectionH
            }else {
                let allItemsH = layout.itemSize.height*numberOfLines + layout.minimumLineSpacing*(numberOfLines - 1) + itemSectionH
                itemH = min(allItemsH, CONTENTVIEW_HEIGHT - 52)
            }
        }
        
        sudokuCollection.snp.remakeConstraints { make in
            make.top.equalTo(titleBg.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(itemH)
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
        sudokuCollection.reloadData()
    }
    
    @objc func dismiss() {
        EXAlert.dismiss()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension EXHomeMenuSheet : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sudokudatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entity = sudokudatas[indexPath.row]
        let cell : EXHomeFuncCC = collectionView.dequeueReusableCell(withReuseIdentifier: "EXHomeFuncCC", for: indexPath) as! EXHomeFuncCC
        cell.bindCell(entity)
        return cell
    }
    
    func moveAnimation(collection:UICollectionView, cell:UICollectionViewCell,idxPath:IndexPath) {
        
        let column = Double(cell.frame.minX / cell.frame.width)
        let row = Double(cell.frame.minY / cell.frame.height)
        let distance = sqrt(pow(column, 2) + pow(row, 2))
        let delay = sqrt(distance) * delayBase

        let toframe = cell.frame
        cell.frame = CGRect(x: cell.frame.origin.x, y:cell.frame.origin.y + cell.bounds.size.height, width: cell.bounds.size.width, height: cell.bounds.size.height)
        cell.contentView.alpha = 0
        UIView.animate(withDuration: animationDuration, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: []) {
            cell.contentView.alpha = 1
            cell.frame = toframe
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if showedIdxPath.contains(indexPath) {
            return;
        }else {
            showedIdxPath.append(indexPath)
            self.moveAnimation(collection: collectionView,cell: cell, idxPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        EXAlert.dismissEnd(complete: {
            let entity = self.sudokudatas[indexPath.row]
            if entity.type.count > 0{
                self.menuItemCallback?(entity)
            }
        }, delay: 0.1)
    }
}

