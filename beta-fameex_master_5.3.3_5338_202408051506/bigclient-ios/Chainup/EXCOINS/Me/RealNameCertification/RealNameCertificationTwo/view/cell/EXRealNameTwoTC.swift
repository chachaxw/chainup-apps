//
//  EXRealNameTwoTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage
import EXKit
class EXRealNameTwoTC: UITableViewCell,MarkCheckable {
    
    var entity = EXRealBtnEntity()
    
    typealias ClickBtnBlock = (Int) -> ()
    typealias UploadImageBlock = (Int) -> ()
    var clickBtnBlock : ClickBtnBlock?
    var reUploadBtnBlock : UploadImageBlock?
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var imgCoverBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.extUseAutoLayout()
        btn.extSetAddTarget(self, #selector(clickImgBtn))
        return btn
    }()
    
    lazy var img : UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    internal lazy var reuploadBgView :UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.isHidden = true
        return v
    }()
    internal lazy var reloadMarkView :UIView = {
        let v =  UIView()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(reupload))
        v.addGestureRecognizer(tap)
        v.isUserInteractionEnabled = true
        
        let img = UIImageView()
        img.image = UIImage.themeImageNamed(imageName: "personal_upload")
        v.addSubview(img)
        
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorHighlight
        label.text = "personal_Center_text31".localized()
        
        v.addSubViews([img,label])
        img.snp_makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.width.height.equalTo(28)
            make.centerX.equalToSuperview()
        }
        label.snp_makeConstraints { make in
            make.top.equalTo(img.snp_bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        return v
    }()

    internal lazy var checkMarkView : CheckMarkView = {
        let check =  CheckMarkView.init(style:.xMarkBig, isChecked:true, presenter:self)
        check.isHidden = true
        return check
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        self.selectionStyle = .none
        contentView.addSubViews([titleLabel,img,imgCoverBtn])
        imgCoverBtn.addSubViews([checkMarkView,reuploadBgView])
        reuploadBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.top.equalToSuperview().offset(16)
        }
        img.snp.makeConstraints { (make) in
            make.height.equalTo(140)
            make.width.equalTo(240)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        imgCoverBtn.snp.makeConstraints { make in
            make.edges.equalTo(img)
        }
        checkMarkView.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.height.width.equalTo(70)
        }
        reuploadBgView.addSubview(reloadMarkView)
        reloadMarkView.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.center.equalToSuperview()
        }
    }
    
    func setCell(_ entity : EXRealBtnEntity){
        self.entity = entity
        titleLabel.text = entity.title
        if entity.image != nil{
            img.image = entity.image
        }else{
            img.image = UIImage.themeImageNamed(imageName: entity.placeholderImg)
        }
        reuploadBgView.isHidden = entity.imgUrl == ""
    }
    
    @objc func reupload(){
        self.reUploadBtnBlock?(self.tag - 1000)
    }
    //Click on the button
    @objc func clickImgBtn(){
        if self.entity.imgUrl.hasPrefix("http"){//Zoom in with images
            EXAlert.showPhotoBrowser(urls: [self.entity.imgUrl])
        }else{//No image added
            clickBtnBlock?(self.tag - 1000)
        }
    }
    
    func didTapped(isCheck: Bool) {
        checkMarkView.checked = true
        self.entity.imgUrl = ""
        self.entity.image = nil
//        checkMarkView.isHidden = true
        (self.yy_viewController as? EXRealNameTwoVC)?.mainView.tableView.reloadData()
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

