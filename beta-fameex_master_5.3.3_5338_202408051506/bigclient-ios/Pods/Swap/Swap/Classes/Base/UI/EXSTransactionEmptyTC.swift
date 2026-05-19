//
//  EXTransactionEmptyTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXSTransactionEmptyTC: UITableViewCell {
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView.init()
        imgV.ext_UseAutoLayout()
        imgV.image = EXKitBundle.svgImage(named: "public_nocontentyet")
        return imgV
    }()
    
    lazy var label : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
//        label.textColor = UIColor.ThemeLabel.colorMedium
//        label.font = UIFont.ThemeFont.SecondaryRegular
//        label.text = LanguageTools.getString(key: "cp_extra_text52")
        label.attributedText = NSMutableAttributedString().exs_add(string: "cp_extra_text52".ex_localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryBold , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium])
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        self.backgroundColor = UIColor.ThemeView.card1
        self.contentView.backgroundColor = UIColor.ThemeView.card1
        contentView.exs_addSubViews([imgV,label])
        imgV.snp.makeConstraints { (make) in
            
            make.center.equalToSuperview()
            
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
        imgV.snp.remakeConstraints { (make) in
            make.height.width.equalTo(40)
            make.top.equalToSuperview().offset(150)
            make.centerX.equalToSuperview()
        }
    }
    
    func reloadEmptyView(_ index : Int){
        if index != 0{
            label.attributedText = NSMutableAttributedString().exs_add(string: "cp_extra_text52".ex_localized() + ",", attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryBold , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium]).exs_add(string: "common_text_refresh".ex_localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryBold , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorHighlight])
        }else{
            label.attributedText = NSMutableAttributedString().exs_add(string: "cp_extra_text52".ex_localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryBold , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium])
        }
    }
    
    @objc func clickLabel(){
//        BasicParameter.getVersionForPublicInfo()
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
