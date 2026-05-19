//
//  SearchTC.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/6.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage

class SearchTC: UITableViewCell {
    
    var entity = SearchEntity()
    
    //name
    lazy var line : UIView = {
        let label = UIView()
        label.extUseAutoLayout()
        label.backgroundColor = UIColor.ThemeView.seperator
        return label
    }()
    
    
    //name
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        return label
    }()
    
    //picture
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        return imgV
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubViews([imgV,nameLabel,line])
        self.extSetCell(UIColor.ThemeView.bg)
        selectionStyle = .none
        imgV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgV.snp.right).offset(7)
            make.centerY.equalTo(contentView)
            make.height.equalTo(15)
            make.right.equalToSuperview().offset(-10)
        }
        
        line.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
            make.right.equalToSuperview()
        }
    }
    
    func setCellWithEntity(_ entity : SearchEntity){
        nameLabel.setCoinMap(entity.name.aliasCoinMapName())
        if let url = URL.init(string: entity.img){
            imgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
        }
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

//Cell with add button
class SearchAddTC : SearchTC{
    
    var userSymbolsVm:UserSymbolsVM!
    //add button
    lazy var addBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
//        btn.extSetCornerRadius(2)
        btn.extSetAddTarget(self, #selector(clickAddBtn))
        btn.setImage(UIImage.themeImageNamed(imageName: "quotes_optional_default"), for: UIControl.State.normal)
        btn.setImage(UIImage.themeImageNamed(imageName: "quotes_optional_selected"), for: UIControl.State.selected)
//        btn.extSetTitle(LanguageTools.getString(key: "add"), 13, UIColor.ThemeView.bg, UIControl.State.normal)
//        btn.extSetTitle(LanguageTools.getString(key: "cancel"), 13, UIColor.ThemeLabel.colorLite, UIControl.State.selected)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.userSymbolsVm = UserSymbolsVM()
        contentView.addSubViews([addBtn])
        imgV.isHidden = true
        
        nameLabel.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalTo(contentView)
            make.height.equalTo(15)
            make.right.equalToSuperview().offset(-10)
        }
        
        addBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
    }
    
    func setBtn(_ entity : SearchEntity){
        addBtn.isSelected = entity.state == "1"
        self.entity = entity
//        if entity.state == "0"{
//            addBtn.backgroundColor = UIColor.ThemeBtn.highlight
//        }else{
//            addBtn.backgroundColor = UIColor.clear
//        }
    }
    
    override func setCellWithEntity(_ entity: SearchEntity) {
        super.setCellWithEntity(entity)
        setBtn(entity)
    }
    
    //MARK: Click on the add button
    @objc func clickAddBtn(_ btn : UIButton){
        btn.isSelected = !btn.isSelected
        //delete
        let mapEntity = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(self.entity.name)
        userSymbolsVm.handleFavorite(actionType: btn.isSelected ? .singleAdd : .singleDelete, coinMaps: [mapEntity],callback: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//TC with selection on the right
class SearchChooseImgVTC : SearchTC {
    
    //Select button
    lazy var chooseImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.isHidden = true
        imgV.image = UIImage.init(named: "choose")
        return imgV
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubViews([chooseImgV])
        
        chooseImgV.snp.makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-10)
            make.centerY.equalTo(contentView)
            make.width.equalTo(12)
            make.height.equalTo(7)
        }
    }
    
    func setImgV(_ entity : SearchEntity){
        chooseImgV.isHidden = entity.state == "0"
    }
    
    override func setCellWithEntity(_ entity: SearchEntity) {
        super.setCellWithEntity(entity)
        setImgV(entity)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



