//
//  NavCustomView.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
//import SnapKit
import EXKit

class EXSNavCustomView: UIView {
    
    typealias ClickPopBtnBlock = () -> ()
    var clickPopBtnBlock : ClickPopBtnBlock?//点击返回按钮的回调 English: Callback for clicking the return button

    //background
    lazy var backView : UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor =  .clear//UIColor.ThemeView.bg
        return view
    }()
    
    //title
    lazy var middleTitle : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.H3Bold
        return label
    }()
    
    var popBtn : UIButton = {
        let btn = UIButton()
        btn.ext_UseAutoLayout()
        btn.setImage(UIImage.exs_themeImageNamed(imageName:"public_return"), for: .normal)
        btn.exs_setEnlargeEdgeWithTop(10, left: 20, bottom: 10, right: 20)
        btn.addTarget(self, action: #selector(pop), for: .touchUpInside)
        return btn
    }()

    
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.ext_UseAutoLayout()
        btn.addTarget(self, action: #selector(clickPopBtn), for: UIControl.Event.touchUpInside)
        btn.ext_SetTitle("cp_overview_text56".ex_localized(), 14, UIColor.ThemeLabel.colorMedium, .normal)
        btn.layoutIfNeeded()
        btn.isHidden = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor =  UIColor.ThemeView.bg
        self.addSubview(backView)
        self.backView.exs_addSubViews([middleTitle, popBtn,cancelBtn])
        self.addConstraint()
    }
    @objc func pop(){
        AppService.topViewController().navigationController?.popViewController(animated: true)
    }
    
    func setCancelBtn(){
        cancelBtn.isHidden = false
        popBtn.isHidden = true
    }
    
    //MARK: adding constraints
    func addConstraint() {
        backView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(EX_NAV_STATUS_HEIGHT)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        middleTitle.snp.makeConstraints { (make) in
            make.height.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(EXSCREEN_WIDTH - 100)
        }
        popBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
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
//            tagView.setTitle(marketTag, for: .normal)
//            let tagWidth = tagView.commonTagWidth(titleStr: marketTag)
//            tagView.snp.remakeConstraints { (make) in
//                make.left.equalTo(middleTitle.snp.right).offset(offset)
//                make.top.equalTo(middleTitle.snp.top)
//                make.width.equalTo(tagWidth)
//            }
//        }
//    }
    
    //MARK: Set the module on the right, and the title needs to change its display area according to the price control on the right
    func setRightModule(_ views : [UIView] , rightSize : (Int , Int) = (19,19)){
        self.exs_addSubViews(views)
        for i in 0..<views.count{
            let view = views[i]
            let rightDistance : CGFloat = CGFloat((i + 1) * 10 + i * rightSize.0)
            view.snp.makeConstraints { (make) in
                make.centerY.equalTo(middleTitle)
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
        self.exs_addSubViews(views)
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

