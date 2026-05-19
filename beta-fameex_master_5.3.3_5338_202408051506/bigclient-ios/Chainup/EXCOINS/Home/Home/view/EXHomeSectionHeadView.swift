//
//  EXHomeSectionHeadView.swift
//  Chainup
//
//  Created by zewu wang on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXHomeSectionHeadView: UIView, UICollectionViewDelegate , UICollectionViewDataSource {
    
    typealias ClickListBlock = (Int) -> ()
    var clickListBlock : ClickListBlock?
    
    var tableViewRowDatas : [EXHomeSectionHeadEntity] = []
    {
        didSet{
            self.collectionV.reloadData()
        }
    }
    
    var sectionEntity = EXHomeSectionEntity()
    
    lazy var collectionV : UICollectionView = {
        let collectionV = UICollectionView.init(frame: CGRect.init(x: 15, y: 0, width: SCREEN_WIDTH, height: 46) , collectionViewLayout: getCollectionLayout())
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.backgroundColor = UIColor.ThemeView.bg
        collectionV.isPagingEnabled = true
        collectionV.register(EXHomeSectionHeadCC.classForCoder(), forCellWithReuseIdentifier: "EXHomeSectionHeadCC")
        collectionV.delegate = self
        collectionV.bounces = false
        collectionV.dataSource = self
        collectionV.backgroundColor = UIColor.ThemeView.bg
        return collectionV
    }()
    
    func getCollectionLayout() -> UICollectionViewFlowLayout{
        let collectionLayout = UICollectionViewFlowLayout.init()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.minimumLineSpacing = 30
        collectionLayout.estimatedItemSize = CGSize.init(width: 10, height: 46)
        return collectionLayout
    }
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var sectionview : EXHomeSectionView = {
        let view = EXHomeSectionView()
        view.extUseAutoLayout()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([collectionV,lineV,sectionview])
        lineV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(collectionV.snp.bottom)
            make.height.equalTo(0.5)
        }
        sectionview.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(22)
            make.top.equalTo(lineV.snp.bottom)
        }
        
        if EXHomeViewModel.status() == .three{
            sectionview.isHidden = true
        }
        
    }
    
    func setSectionView(_ left : String , middle : String , right : String){
        sectionEntity.leftname = left
        sectionEntity.middlename = middle
        sectionEntity.rightname = right
        sectionview.setView(sectionEntity)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        self.clickListBlock?(index)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : EXHomeSectionHeadCC = collectionView.dequeueReusableCell(withReuseIdentifier: "EXHomeSectionHeadCC", for: indexPath) as! EXHomeSectionHeadCC
        cell.setCell(entity)
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXHomeSectionView : UIView {
    
    lazy var leftLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorDark
        return label
    }()
    
    lazy var middleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .right
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorDark
        return label
    }()
    
    lazy var rightLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorDark
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg

        let nameWidth = EXHomeRankNewCell.nameLabelWidth()

        addSubViews([leftLabel,middleLabel,rightLabel])
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(MARGIN_LEFT)
            make.top.equalToSuperview()
            make.height.equalTo(16)
            make.width.equalTo(nameWidth)
        }
        middleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leftLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-116)
            make.centerY.equalTo(leftLabel)
            make.height.equalTo(16)
        }
        rightLabel.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.centerY.equalTo(leftLabel)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    func setView(_ entity : EXHomeSectionEntity){
        leftLabel.text = entity.leftname
        rightLabel.text = entity.rightname
        middleLabel.text = entity.middlename
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXHomeSectionHeadCC : UICollectionViewCell{
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadBold
        label.textAlignment = .center
        return label
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeBtn.highlight
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        contentView.addSubViews([nameLabel,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(22)
            make.left.right.equalToSuperview()
        }
        lineV.snp.makeConstraints { (make) in
            make.width.equalTo(15)
            make.height.equalTo(3)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    //Set Cell
    func setCell(_ entity : EXHomeSectionHeadEntity){
        nameLabel.text = entity.name
        if entity.select == "0"{//Unchecked 
            lineV.isHidden = true
            nameLabel.textColor = UIColor.ThemeLabel.colorMedium
        }else{//Selected
            lineV.isHidden = false
            nameLabel.textColor = UIColor.ThemeLabel.colorLite
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

