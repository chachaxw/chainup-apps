//
//  EXTitleIconSheetItem.swift
//  Chainup
//
//  Created by liuxuan on 2022/11/16.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import SnapKit

public class EXSheetIconBtnModel:NSObject {
    public var title:String = ""
    public var icon:String = ""
}

public class EXTitleIconSheetItem: UIView {
    
    lazy var titleBg:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.bg
        return v
    }()
    
    lazy var tapBtn :UIButton = {
        let l = UIButton()
        l.backgroundColor = UIColor.clear
        return l
    }()
    
    lazy var titleLabel:UILabel = {
        let l = UILabel()
        l.isUserInteractionEnabled = false
        l.textColor = UIColor.ThemeLabel.colorLite
        l.font = UIFont.ThemeFont.HeadMedium
        return l
    }()
    
    lazy var titleIcon:UIImageView = {
        let l = UIImageView()
        l.isUserInteractionEnabled = false
        l.contentMode = .scaleAspectFit
        return l
    }()
    
    lazy var lineView:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleBg)
        self.addSubview(tapBtn)
        self.addSubview(lineView)
        titleBg.addSubViews([titleLabel,titleIcon])
        tapBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        titleBg.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        titleIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.equalTo(16)
            make.centerY.equalTo(titleLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleIcon.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(22)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
