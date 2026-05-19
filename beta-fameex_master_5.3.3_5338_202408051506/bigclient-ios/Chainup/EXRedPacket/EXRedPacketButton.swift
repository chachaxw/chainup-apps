//
//  EXRedPacketButton.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXRedPacketButton: UIView {
    
    //MARK: Single Example
    public static var sharedInstance : EXRedPacketButton{
        struct Static {
            static let instance : EXRedPacketButton = EXRedPacketButton()
        }
        return Static.instance
    }
    
    typealias ClickBtnBlock = (Int) -> ()//0 Cancel 1 Red Envelope
    var clickBtnBlock : ClickBtnBlock?
    
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(UIImage.themeImageNamed(imageName: "public_deleteall"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickBtn))
        btn.tag = 1000
        return btn
    }()
    
    lazy var redPacketBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        
        btn.extSetAddTarget(self, #selector(clickBtn))
        btn.tag = 1001
        return btn
    }()
    
    func reloadView(){
        if LanguageTools.isHan() == true{
            redPacketBtn.setImage(UIImage.themeImageNamed(imageName: "redenvelope"), for: UIControl.State.normal)
        }else{
            redPacketBtn.setImage(UIImage.themeImageNamed(imageName: "redenvelope_english"), for: UIControl.State.normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.extUseAutoLayout()
        reloadView()
        addSubViews([cancelBtn,redPacketBtn])
        cancelBtn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        cancelBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(16)
            make.height.equalTo(17)
            make.top.equalToSuperview()
        }
        redPacketBtn.snp.makeConstraints { (make) in
            make.right.equalTo(cancelBtn.snp.left)
            make.top.equalToSuperview().offset(7)
            make.width.equalTo(40)
            make.height.equalTo(52)
        }
    }
    
    //Click on the button
    @objc func clickBtn(_ btn : UIButton){
        self.clickBtnBlock?(btn.tag - 1000)
    }
    
    func show(_ view : UIView){
        view.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.height.equalTo(59)
            make.width.equalTo(64)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-64)
        }
    }
    
    func dismiss(){
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

