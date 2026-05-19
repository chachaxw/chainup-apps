//
//  EXRebateRatioAlert.swift
//  Chainup
//
//  Created by cwd on 2023/5/26.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
//Rebate ratio
class EXRebateRatioAlert: EXCustomBaseView {

    let cellId = "EXRebateRatioCell"
    var dataList:[ScalceInfoItem]?{
        didSet{
            guard dataList != nil else{
                return
            }
            
            updateColloctionViewHeight()
            self.mainView.reloadData()
        }
    }
    
    
    
    override func setSubView() {

        self.backgroundColor = .Ex.fill6
        self.addSubViews([titleLabel,mainView,sure])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(25)
        }
        mainView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(180)
        }
        sure.snp.makeConstraints { make in
            make.top.equalTo(mainView.snp.bottom).offset(20)
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: .allCorners, radius: 12)
    }
 
    func updateColloctionViewHeight(){
        let h = getColloctionViewHeight(count: self.dataList!.count)
        mainView.snp.updateConstraints { make in
            make.height.equalTo(h)
        }
    }
    func getColloctionViewHeight(count: Int) -> CGFloat {
        let rows =  (count + 1) / 2 //Number of rows
        let total = rows * 28 + (rows - 1) * 10
        return CGFloat(total)
    }
    ///Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"RebateRate".localized(), font: UIFont.ThemeFont.H3Medium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.center)
        return label
    }()
    
    lazy var mainView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let w: CGFloat = (SCREEN_WIDTH - 80 - 8 ) / 2
        layout.itemSize = CGSize(width: w, height: 28)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        //Create a UICollectionView object
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .ThemeView.bg
        collectionView.register(EXRebateRatioCell.self, forCellWithReuseIdentifier: cellId)
        return collectionView
    }()
    
    //confirm
    lazy var sure: EXButton = {
        let btn = EXButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.setTitle(LanguageTools.getString(key:"alert_common_iknow"), for: .normal)
        return btn
    }()
}
extension EXRebateRatioAlert{
    @objc func clickBtn(){
        EXAlert.dismiss()
    }
    
}

extension EXRebateRatioAlert: UICollectionViewDelegate,UICollectionViewDataSource{
    //Implement methods in the UICollectionViewDataSource protocol
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? EXRebateRatioCell {
            
            let item = self.dataList?[indexPath.row]
            cell.scaleItem = item
            return cell
        }
       
        return UICollectionViewCell()
    }
}


class EXRebateRatioCell: UICollectionViewCell{
    
    var scaleItem: ScalceInfoItem? {
        didSet{
            
            if let level = scaleItem?.level{
                titleLabel.text =  String(format:"agent_level".localized(),level)
            }
            valueLabel.text = (scaleItem?.scale ?? "0" ).bigMul("100") + "%"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(){
        self.contentView.backgroundColor = .Ex.fill3
        self.contentView.extSetCornerRadius(2)
        self.contentView.addSubViews([pointLabel,titleLabel,valueLabel])
        pointLabel.snp.makeConstraints { make in
            make.height.width.equalTo(4)
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(pointLabel.snp_right).offset(6)
            make.centerY.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    ///Name
    lazy var pointLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .Ex.main1
        return label
    }()
    
    ///Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.Ex.Harmony(size: 12, weight: .regular), textColor: .Ex.main1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    ///
    lazy var valueLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.Ex.Harmony(size: 12, weight: .medium), textColor: .Ex.text1, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
}





