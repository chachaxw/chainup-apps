//
//  PopUpView.swift
//  Chainup
//
//  Created by zewu wang on 2023/1/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class PopUpView: UIView {

    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.bg
        view.extSetCornerRadius(4)
        return view
    }()
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetTextColor(UIColor.ThemeLabel.colorMedium, fontSize: 16)
        return label
    }()
    
    lazy var contentLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.numberOfLines = 0
        label.extSetTextColor(UIColor.ThemeLabel.colorMedium, fontSize: 14)
        return label
    }()
    
    lazy var commitBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.extSetAddTarget(self, #selector(clickCommitBtn))
        btn.contentHorizontalAlignment = .right
        btn.extSetTitle(LanguageTools.getString(key: "know"), 16, UIColor.ThemeView.highlight, UIControl.State.normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.mask
        self.addSubViews([backView])
        backView.addSubViews([titleLabel,contentLabel,commitBtn])
        backView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(titleLabel.snp.top).offset(-20)
            make.bottom.equalTo(commitBtn).offset(20)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(contentLabel.snp.top).offset(-15)
            make.height.equalTo(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.lessThanOrEqualTo(SCREEN_HEIGHT - 117 - 20)
        }
        commitBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(contentLabel.snp.bottom).offset(30)
            make.height.equalTo(16)
        }
    }
    
    func setView(_ titleStr : String , contentStr : String){
        
        titleLabel.text = titleStr
        contentLabel.text = contentStr
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        appDelegate.window??.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func clickCommitBtn(){
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
