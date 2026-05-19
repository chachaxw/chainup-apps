//
//  EXSNaviDrawerView.swift
//  Chainup
//
//  Created by cwd on 2022/11/27.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXSNaviDrawerView: EXCOCustomBaseView {
    var btnClick: EXComVoidBlock?
    var isFromKLine = true {
        didSet{
            if isFromKLine == false{
                self.backgroundColor = UIColor.ThemeView.bg
                self.titleLabel.textColor = UIColor.Ex.text1
                self.line.backgroundColor = UIColor.ThemeView.seperator
            }
        }
    }
    override func setSubView() {
        self.backgroundColor = UIColor.ThemekLine.viewBg
        self.addSubViews([popBtn,chooseBtn,line,titleLabel])
        
        popBtn.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            
        }
        line.snp.makeConstraints { make in
            make.left.equalTo(popBtn.snp.right).offset(8)
            make.width.equalTo(0.5)
            make.height.equalTo(18)
            make.centerY.equalToSuperview()
        }
        // 图片大小16  按钮40  图片距离父视图间距 24/2 = 12 English: Image size 16, button 40, image distance from parent view 24/2=12
        chooseBtn.snp.makeConstraints { make in
            make.left.equalTo(line.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(chooseBtn.snp.right).offset(8)
            make.height.equalTo(22)
            make.centerY.equalTo(chooseBtn)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickChooseBtn))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    
    @objc func clickChooseBtn(){
        self.btnClick?()
    }
    
    @objc func navPop(){
        self.yy_viewController?.navigationController?.popViewController(animated: true)
    }
    
    lazy var popBtn :RepeatButton = {
        let btn = RepeatButton()
        btn.ext_UseAutoLayout()
        btn.exs_setEnlargeEdgeWithTop(10, left: 20, bottom: 10, right: 15)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_return"), for: .normal)
        btn.ext_SetAddTarget(self, #selector(navPop))
        return btn
    }()
   
    // 切换合约 English: Switch contracts
    lazy var chooseBtn : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage.exs_themeImageNamed(imageName: "public_icon_switchcurrency")
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickChooseBtn))
        img.addGestureRecognizer(tap)
        img.isUserInteractionEnabled = true
        return img
    }()
    
    //分割线 English: Division line
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor =  UIColor.Ex.kLine.fill4//UIColor.ThemekLine.seperator
        return v
    }()
    
    // 合约名称 English: Contract Name
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.isUserInteractionEnabled = true
        label.font = UIFont.ThemeFont.H3Bold
        label.textColor = UIColor.Ex.kLine.text1
        label.text = "--"
        return label
    }()
}

