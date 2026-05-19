//
//  EXSButton.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import RxSwift
@IBDesignable

//右上角的对勾 English: The checkmark in the upper right corner
class EXCheckButton: UIButton {
    //是否显示右上角的对勾 English: Is the check mark in the upper right corner displayed
    override var isSelected: Bool{
        didSet{
            self.checkImage.isHidden = !isSelected
            
            if self.isEnabled{
                self.checkImage.image = UIImage.svg_themeImageNamed(imageName: "public_selecteds")
                if self.isSelected {
                    self.backgroundColor = UIColor.Ex.main3
                    self.layer.borderColor = UIColor.Ex.main1.cgColor
                }else{
                   
                    self.backgroundColor = UIColor.ThemeView.card2
                    self.layer.borderColor = UIColor.ThemeView.card2.cgColor
                }
            }else{
                self.checkImage.image = UIImage.svg_themeImageNamed(imageName: "public_selecteds_not")
                self.backgroundColor = UIColor.ThemeBtn.disable
                self.layer.borderColor = UIColor.ThemeBtn.disable.cgColor
            }
            
        }
    }
    override var isEnabled: Bool{
        didSet{
            if isEnabled{
                self.checkImage.image = UIImage.svg_themeImageNamed(imageName: "public_selecteds")
                if self.isSelected {
                    self.backgroundColor = UIColor.Ex.main3 
                    self.layer.borderColor = UIColor.Ex.main1.cgColor
                }else{
                    self.backgroundColor = UIColor.ThemeView.card2
                    self.layer.borderColor = UIColor.ThemeView.card2.cgColor
                }
            }else{
                self.checkImage.image = UIImage.svg_themeImageNamed(imageName: "public_selecteds_not")
                self.backgroundColor = UIColor.ThemeBtn.disable
                self.layer.borderColor = UIColor.ThemeBtn.disable.cgColor
            }
        }
    }
    var tapClickBlock: EXCombuttonBlock?
    var checkImage = UIImageView() //右上角对勾 English: Upper right corner checkmark
    override init(frame: CGRect){
        super.init(frame: frame)
        config()
    }
    required init?(coder: NSCoder){
        super.init(coder: coder)
        config()
    }
    func config(){
        self.addSubview(checkImage)
        checkImage.image = UIImage.svg_themeImageNamed(imageName: "public_selecteds")
        checkImage.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.height.equalTo(24)
        }
        self.backgroundColor = UIColor.ThemeView.card2
        self.titleLabel?.font = UIFont.ThemeFont.BodyBold
        self.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .disabled)
        self.setTitleColor(UIColor.ThemeLabel.colorLite, for: .selected)
        self.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        self.layer.borderColor = UIColor.ThemeView.card2.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        self.addClickEevnt()
    }
    //过滤高频事件 English: Filter high-frequency events
    func addClickEevnt(){
        self.rx.tap.asObservable().debounce(.milliseconds(100), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] in
            self?.tapClickBlock?(self!)
        }).disposed(by: disposeBag)
    }
}

class EXSButton: EXButton{
    
}


