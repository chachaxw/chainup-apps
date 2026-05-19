//
//  EXHomeFunCView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage

class EXHomeFuncThreeAllView : UIView{
       
    lazy var oneView : EXHomeFuncOneView = {
        let view = EXHomeFuncOneView()
        view.extUseAutoLayout()
        view.isHidden = true
        return view
    }()
    
    lazy var twoView : EXHomeFuncOtherView = {
        let view = EXHomeFuncOtherView()
        view.extUseAutoLayout()
        view.isHidden = true
        return view
    }()
    
    lazy var threeView : EXHomeFuncOtherView = {
        let view = EXHomeFuncOtherView()
        view.extUseAutoLayout()
        view.isHidden = true
        return view
    }()
    
    lazy var bottomLineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeNav.bg
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeNav.bg
        addSubViews([oneView,twoView,threeView,bottomLineV])
        oneView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.height.equalTo(102)
            make.width.equalTo(redproportion * 230)
        }
        twoView.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.height.equalTo(46)
            make.left.equalTo(oneView.snp.right).offset(10)
        }
        threeView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(twoView.snp.bottom).offset(10)
            make.height.equalTo(46)
            make.left.equalTo(oneView.snp.right).offset(10)
        }
        bottomLineV.snp.makeConstraints { (make) in
            make.right.bottom.left.equalToSuperview()
            make.height.equalTo(10)
        }
    }
    
    //Set view
    func setView(_ arr : [HomeFunctionEntity]){
        if arr.count > 0{
            oneView.isHidden = false
            oneView.setView(arr[0])
        }
        if arr.count > 1{
            twoView.isHidden = false
            twoView.setView(arr[1])
        }
        if arr.count > 2{
            threeView.isHidden = false
            threeView.setView(arr[2])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXHomeFuncOneView : UIView{
    
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var detailTitleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.numberOfLines = 0
        return label
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        return imgV
    }()
    
    var entity = HomeFunctionEntity()
    var itemModel = CmsAppDataItem()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([backView,imgV])
        backView.addSubViews([titleLabel,detailTitleLabel])
        backView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalTo(imgV.snp.left)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(imgV.snp.left).offset(-10)
        }
        detailTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(imgV.snp.left).offset(-10)
            make.bottom.equalToSuperview()
        }
        imgV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-3)
            make.width.equalTo(125)
            make.height.equalTo(75)
            make.top.equalToSuperview().offset(16)
        }
        let att = UITapGestureRecognizer.init(target: self, action: #selector(clickView))
        self.addGestureRecognizer(att)
    }
    
    func setView(_ entity : HomeFunctionEntity){
        self.entity = entity
        titleLabel.text = entity.title
        detailTitleLabel.text = entity.subhead
        if let url = URL.init(string: entity.imageUrl){
            imgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
        }
    }
    
    func bindModel(_ model: CmsAppDataItem) {
        self.itemModel = model
        titleLabel.text = model.title
        detailTitleLabel.text = model.subhead
        if let url = URL.init(string: model.imageUrl){
            imgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
        }
    }
    
    @objc func clickView(){
        if itemModel.type.count  > 0 {
            if let vc = self.yy_viewController{
                HomeGOTO().gotoVC(vc, tnativeUrl: itemModel.nativeUrl, httpUrl: itemModel.fmtUrl(),title:itemModel.title)
            }
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXHomeFuncOtherView : UIView{
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        return imgV
    }()
    
    var entity = HomeFunctionEntity()
    var itemModel = CmsAppDataItem()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([titleLabel,imgV])
        imgV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(26)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgV.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
            make.right.equalToSuperview().offset(-10)
        }
        let att = UITapGestureRecognizer.init(target: self, action: #selector(clickView))
        self.addGestureRecognizer(att)
    }
    
    func setView(_ entity : HomeFunctionEntity){
        self.entity = entity
        titleLabel.text = entity.title
        if let url = URL.init(string: entity.imageUrl){
            imgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
        }
    }
    
    
    func bindModel(_ model: CmsAppDataItem) {
        self.itemModel = model
        titleLabel.text = model.title
        if let url = URL.init(string: model.imageUrl){
            imgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
        }
    }
    
    
    @objc func clickView(){
        if itemModel.type.count  > 0 {
            if let vc = self.yy_viewController{
                HomeGOTO().gotoVC(vc, tnativeUrl: itemModel.nativeUrl, httpUrl: itemModel.fmtUrl(),title:itemModel.title)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

