//
//  EXQuickBuyCoinCell.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXQuickBuyCoinCell: EXCustomBaseView {
    var cellBlock: EXComBoolBlock?
    var inputDetegate = EXComBaseFieldDelegate()
    var actionblock: EXComVoidBlock?
    var model = EXCreditCoin(){
        didSet{
            input.text = model.amount
            input.newSetPlaceHolderAtt(model.coinPlaceHolder, color: .Ex.text3, font: .Ex.medium(16))
            let w = EXQuickCoinView.getWidth(coin: model)
            iconView.snp.updateConstraints { make in
                make.width.equalTo(w)
            }
            iconView.layoutIfNeeded()
            iconView.coin = model
        }
    }
    
    lazy var mainview: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.Ex.fill3
        return v
    }()
    
    
    ///Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.Ex.medium(14), textColor: UIColor.Ex.text1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var input: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .decimalPad
        tf.textColor = UIColor.Ex.text1
        tf.font = UIFont.Ex.medium(24)
        tf.delegate = inputDetegate
        return tf
    }()
    
    lazy var iconView: EXQuickCoinView = {
        let v = EXQuickCoinView()
        v.tailing = true
        return v
    }()
    
    lazy var btn: UIButton = {
        let b = UIButton()
        b.addTarget(self, action: #selector(selectCoin), for: .touchUpInside)
        return b
    }()
    
    override func setSubView() {
        self.backgroundColor = .clear
        mainview.backgroundColor = .Ex.fill3
        self.addSubViews([mainview])
        mainview.snp.makeConstraints { make in
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.top.equalToSuperview().offset(10)
//            make.height.equalTo(81)
            make.edges.equalToSuperview()
        }
        
        mainview.addSubViews([titleLabel,input,iconView,btn])
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(18)
            make.height.equalTo(16)
        }
        input.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-14)
        }
        iconView.snp.makeConstraints { make in
            make.left.equalTo(input.snp.right)
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        btn.snp.makeConstraints { make in
            make.edges.equalTo(iconView)
        }
       
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        mainview.roundCorners(corners: .allCorners, radius: 6)
    }
    
    @objc func selectCoin(){
        self.actionblock?()
    }
    
}


