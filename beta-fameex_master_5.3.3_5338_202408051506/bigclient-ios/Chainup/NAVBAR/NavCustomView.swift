//
//  NavCustomView.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
//import SnapKit
import Swap
typealias ClickPopBtnBlock = () -> ()

class NavCustomView: UIView {
    
    var clickPopBtnBlock : ClickPopBtnBlock?//Callback by clicking the return button
    
    lazy var tagView :EXTagView = {
        let view = EXTagView.commonTagView()
        view.isHidden = true
        return view
    }()

    //background
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor =  .clear//UIColor.ThemeView.card1
        return view
    }()
    
    //title
    lazy var middleTitle : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.Ex.medium(16)
        return label
    }()
    
    var popBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.extUseAutoLayout()
        btn.setImage(UIImage.exs_themeImageNamed(imageName:"public_return"), for: UIControl.State.normal)
        btn.setEnlargeEdgeWithTop(10, left: 20, bottom: 10, right: 20)
        return btn
    }()

    
    lazy var cancelBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.extUseAutoLayout()
        btn.addTarget(self, action: #selector(clickPopBtn), for: UIControl.Event.touchUpInside)
        btn.extSetTitle(LanguageTools.getString(key: "common_text_btnCancel"), 14, UIColor.ThemeLabel.colorMedium, UIControl.State.normal)
        btn.layoutIfNeeded()
        btn.isHidden = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.card1
        self.addSubview(backView)
        self.backView.addSubViews([tagView, middleTitle , popBtn,cancelBtn])
        self.addConstraint()
        popBtn.extSetAddTarget(self, #selector(clickPopBtn))
    }
    
    func transparentStyle() {
        popBtn.snp.remakeConstraints() { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        popBtn.setImage(UIImage.themeImageNamed(imageName:"web_back"), for: UIControl.State.normal)
        self.middleTitle.textColor = UIColor.white
        self.backgroundColor = UIColor.clear
    }

    
    func setCancelBtn(){
        cancelBtn.isHidden = false
        popBtn.isHidden = true
    }
    
    //MARK: adding constraints
    func addConstraint() {
        backView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(NAV_STATUS_HEIGHT)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        middleTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
            make.left.equalTo(popBtn.snp.right).offset(10)
            make.width.lessThanOrEqualTo(SCREEN_WIDTH - 100)
        }
        popBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(14)
            make.centerY.equalToSuperview()
        }
    }
    
//    func showMarketTag(market:String,offset:CGFloat = 5){
//        let symbol = EXAppMarketManager.sharedInstance.getMarketLeft(market)
//        let marketTag = EXAppMarketManager.sharedInstance.getCoinMarketTag(symbol)
//        if marketTag.isEmpty {
//            tagView.isHidden = true
//        }else {
//            tagView.isHidden = false
////            tagView.text = marketTag
//            tagView.setTitle(marketTag, for: .normal)
//            tagView.snp.remakeConstraints { (make) in
//                make.left.equalTo(middleTitle.snp.right).offset(offset)
//                make.top.equalTo(middleTitle.snp.top)
//                make.width.height.equalTo(20)
//            }
////            tagView.titleResizeSize()
//        }
//    }
    
    //MARK: Set the module on the right, and the title needs to change its display area according to the price control on the right
    func setRightModule(_ views : [UIView] , rightSize : (Int , Int) = (19,19), alignPopBtn: Bool = false){
        self.addSubViews(views)
        for i in 0..<views.count{
            let view = views[i]
            let rightDistance : CGFloat = CGFloat((i + 1) * 10 + i * rightSize.0)
            view.snp.makeConstraints { (make) in
                if alignPopBtn {
                    make.top.equalTo(popBtn)
                }else{
                    make.centerY.equalTo(middleTitle)
                }
                make.height.equalTo(rightSize.1)
                make.width.equalTo(rightSize.0)
                make.right.equalTo(-rightDistance)
            }
        }
        if views.count > 2{
            middleTitle.snp.updateConstraints { (make) in
                make.right.equalTo(-views.count * 25)
            }
        }
    }
    
    //MARK: Set the module on the left, and the title needs to change its display area according to the price control on the right
    func setLeftModule(_ views : [UIView]  , _ showPopBtn : Bool = true , leftSize : (Int , Int) = (19,19)){
        self.addSubViews(views)
        for i in 0..<views.count{
            let view = views[i]
            let left : CGFloat = showPopBtn ? 20 : 0
            popBtn.isHidden = !showPopBtn
            let leftDistance : CGFloat = CGFloat((i + 1) * 10 + i * leftSize.0) + left
            view.snp.makeConstraints { (make) in
                make.centerY.equalTo(middleTitle)
                make.height.equalTo(leftSize.1)
                make.width.equalTo(leftSize.0)
                make.left.equalTo(leftDistance)
            }
        }
        if views.count > 1{
            middleTitle.snp.updateConstraints { (make) in
                make.left.equalTo(views.count * 25)
            }
        }
    }
    
    //MARK: Callback for clicking the return button
    @objc func clickPopBtn(){
        clickPopBtnBlock?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

