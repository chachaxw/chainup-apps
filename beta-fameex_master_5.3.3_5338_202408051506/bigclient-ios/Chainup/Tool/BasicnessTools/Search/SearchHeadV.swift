//
//  SearchHeadV.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class SearchHeadV: UIView {
    
    typealias ClickCancelBlock = () -> ()
    var clickCancelBlock : ClickCancelBlock?

    lazy var label : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.BodyRegular
        label.text = LanguageTools.getString(key: "common_action_history")
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(UIImage.themeImageNamed(imageName: "quotes_delete"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(removeSearchArray))
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        
        addSubViews([label,cancelBtn])
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(200)
            make.centerY.equalToSuperview()
            make.height.equalTo(17)
        }
        cancelBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.width.equalTo(46)
            make.right.equalToSuperview()
        }
    }
    
    @objc func removeSearchArray(){
        XUserDefault.removeSearchArray()
        clickCancelBlock?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
