//
//  AddSubtractView.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/10.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class AddSubtractView: UIView {
    //True is+false is-
    typealias ClickAddSubBlock = (Bool) -> ()
    var clickAddSubBlock : ClickAddSubBlock?
    //+Button
    lazy var addBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.tag = 1000
        btn.extSetAddTarget(self, #selector(clickBtn))
        btn.extSetTitle("+", 12, UIColor.ThemeView.highlight, UIControlState.normal)
        return btn
    }()
    
    //-Button
    lazy var subBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.tag = 1001
        btn.extSetAddTarget(self, #selector(clickBtn))
        btn.extSetTitle("-", 12, UIColor.ThemeView.highlight, UIControlState.normal)
        return btn
    }()
    
    //Middle line
    lazy var vline : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([addBtn,subBtn,vline])
        addBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(vline).offset(10)
            make.height.equalTo(12)
            make.width.equalTo(12)
        }
        vline.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(13)
            make.width.equalTo(1)
        }
        subBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(vline).offset(-10)
            make.height.equalTo(12)
            make.width.equalTo(12)
        }
    }
    
    @objc func clickBtn(_ btn : UIButton){
        let b = btn.tag == 1000 ? true : false
        clickAddSubBlock?(b)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

