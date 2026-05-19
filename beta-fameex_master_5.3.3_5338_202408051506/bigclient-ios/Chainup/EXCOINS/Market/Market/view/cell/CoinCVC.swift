//
//  CoinCVC.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/6.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

class CoinCVC: UICollectionViewCell {
    
    //Click on the thermal signal
//    public var subject : BehaviorSubject<Int> = BehaviorSubject(value: 0)
    
    //Displayed buttons
    lazy var btn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.extUseAutoLayout()
        btn.isUserInteractionEnabled = false
        btn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for:.selected)
        btn.setTitleColor(UIColor.ThemekLine.labcolorMedium, for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.layoutIfNeeded()
        return btn
    }()
    
    //The line below the button
    lazy var hline : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemekLine.viewHighlight
        
        return view
    }()
    
//    override func bindUI() {
//        super.bindUI()
////        _ = subject.asObserver().subscribe({ (event) in
////            if let tag = event.element{
////
////            }
////        }).disposed(by: disposeBagForBinding)
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubViews([btn,hline])
//        contentView.backgroundColor = UIColor.ThemekLine.navBg
        addConstraints()
    }
    
    func addConstraints() {
        btn.snp.makeConstraints { (make) in
            make.bottom.equalTo(hline.snp.top).offset(-10)
//            make.centerX.equalTo(contentView)
//            make.width.lessThanOrEqualToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(17)
        }
        
        hline.snp.makeConstraints { (make) in
            make.centerX.equalTo(btn)
            make.width.equalTo(20)
            make.bottom.equalTo(contentView)
            make.height.equalTo(3)
        }
        
    }
    
    func setCellWithEntity(_ entity : CoinEntity, _ fromKline:Bool = false){
       
        self.btn.isSelected = entity.showLine
        
        btn.setTitle(entity.name.aliasName(), for: .normal)
//        btn.setTitle("0000000000000", for: .normal)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        let att = super.preferredLayoutAttributesFitting(layoutAttributes);
        if let string = btn.titleLabel?.text as? String {
            //        let string:NSString = texts.text! as NSString
            
            var newFram = string.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: btn.bounds.size.height), options: .usesLineFragmentOrigin, attributes: [
                NSAttributedString.Key.font : btn.titleLabel?.font
                ], context: nil)
            newFram.size.height += 10;
            newFram.size.width += 30;
            att.frame = newFram;
        }
        //If the child controls on your cell are not created using constraints, then you must also modify the frame of the controls on the cell
        // self.textLabel.frame = CGRectMake(0, 0, attributes.frame.size.width, 30);
        
        return att;
    }
    
}

