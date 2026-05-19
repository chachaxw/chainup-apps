//
//  EXRecommendCollectionViewCell.swift
//  EXKit_Example
//
//  Created by cwd on 2022/7/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class EXRecommendCollectionViewCell: UICollectionViewCell {
    var item = RecommendItem() {
        didSet{
            titleLabel.text = item.title
            titleLabel.attributedText = item.attrtitle
            subTitleLabel.text = item.subtitle
            let img =  item.isSelected ? EXKitBundle.svgImage(named: "public_checked") : EXKitBundle.image(named: "public_unselected")
            checkImg.image = img
            if item.sigle{
                self.singleLine() //单行
            }
        }
    }
   
    
    ///名称
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"--", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        return label
    }()
    
    ///
    lazy var subTitleLabel: UILabel = {
        let label = UILabel(text:"--", font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorDark, alignment: NSTextAlignment.left)
        return label
    }()
    
    lazy var checkImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        return arrowImmg
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configSubView(){
        self.backgroundColor = UIColor.ThemeView.card2
        self.extSetCornerRadius(10)
        self.contentView.addSubViews([titleLabel,subTitleLabel,checkImg])
        checkImg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(16)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(11)
            make.right.lessThanOrEqualTo(checkImg)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
       
    }
    //合约只显示一行
    func singleLine(){
        subTitleLabel.isHidden = true
        titleLabel.numberOfLines = 0
        titleLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(11)
            make.centerY.equalToSuperview()
        }
    }
}
