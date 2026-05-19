//
//  EXTransactionEmptyTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXTransactionEmptyTC: UITableViewCell {
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView.init()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "thedefault")
        return imgV
    }()
    
    lazy var label : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
//        label.textColor = UIColor.ThemeLabel.colorMedium
//        label.font = UIFont.ThemeFont.SecondaryRegular
//        label.text = LanguageTools.getString(key: "common_tip_nodata")
        label.attributedText = NSMutableAttributedString().add(string: "common_tip_nodata".localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.BodyRegular , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium])
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([imgV,label])
        imgV.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(28)
        }
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imgV.snp.bottom).offset(10)
            make.height.equalTo(17)
            make.left.right.equalToSuperview()
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickLabel))
        label.addGestureRecognizer(tap)
    }
    
    func setBig(){
//        imgV.image = UIImage.themeImageNamed(imageName: "quotes_norecord")
        imgV.snp.updateConstraints { (make) in
            make.height.width.equalTo(40)
            make.top.equalToSuperview().offset(150)
        }
    }
    
    func reloadEmptyView(_ index : Int){
        if index != 0{
            label.attributedText = NSMutableAttributedString().add(string: "common_tip_nodata".localized() + ",", attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.BodyRegular , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium]).add(string: "common_text_refresh".localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.BodyRegular , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorHighlight])
        }else{
            label.attributedText = NSMutableAttributedString().add(string: "common_tip_nodata".localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.BodyRegular , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium])
        }
    }
    
    @objc func clickLabel(){
       // EXAppVersionHandler.getVersionForPublicInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
