//
//  EXBtoWithDrawCell.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

typealias ClickBtoCCellBlock = () -> ()

class EXBtoWithDrawCell : UITableViewCell{
    
    lazy var chooseCoinView : EXBtoCChooseCoinView = {
        let view = EXBtoCChooseCoinView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var chooseAccountView : EXBtoCChooseAccountView = {
        let view = EXBtoCChooseAccountView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var withDrawCoinView : EXBtoCWithDrawCoinView = {
        let view = EXBtoCWithDrawCoinView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var poundageView : EXBtoCPoundageView = {
        let view = EXBtoCPoundageView()
        view.extUseAutoLayout()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([chooseCoinView,chooseAccountView,withDrawCoinView,poundageView])
        chooseCoinView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(44)
        }
        chooseAccountView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(68)
            make.top.equalTo(chooseCoinView.snp.bottom)
        }
        withDrawCoinView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(94)
            make.top.equalTo(chooseAccountView.snp.bottom)
        }
        poundageView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(154)
            make.top.equalTo(withDrawCoinView.snp.bottom)
        }
    }
    
    func setCell(_ entity : EXBtoCwithDrawModel , coinmapEntity : B2CCoinMapItem){
        chooseCoinView.setView(entity.coinSymbol)
        chooseAccountView.setView(entity.account)
        withDrawCoinView.setView(entity.canuseAmount, symbol: entity.coinSymbol)
        withDrawCoinView.textFiled.decimal = coinmapEntity.showPrecision
        poundageView.setView(entity.poundage, symbol: entity.coinSymbol)
        poundageView.setwithDraw(coinmapEntity, symbol: coinmapEntity.symbol)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//Select Currency
class EXBtoCChooseCoinView: UIView {
    
    var clickBtoCCellBlock : ClickBtoCCellBlock?
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyBold
        return label
    }()
    
    lazy var chooseCoinLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.textAlignment = .right
        label.text = "charge_action_selectCoin".localized()
        return label
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.contentMode = .scaleAspectFit
        imgV.image = EXKitBundle.image(named: "public_positions_arrow_right")
        return imgV
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([nameLabel,chooseCoinLabel,imgV,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(16)
            make.right.equalTo(chooseCoinLabel.snp.left).offset(-10)
        }
        chooseCoinLabel.snp.makeConstraints { (make) in
            make.right.equalTo(imgV.snp.left).offset(-1)
            make.centerY.equalToSuperview()
            make.height.equalTo(17)
        }
        imgV.snp.makeConstraints { (make) in
            make.height.width.equalTo(8.5)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        lineV.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickView))
        self.addGestureRecognizer(tap)
    }
    
    func setView(_ symbol : String){
        nameLabel.text = symbol
    }
    
    @objc func clickView(){
        self.clickBtoCCellBlock?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//Withdrawal account
class EXBtoCChooseAccountView: UIView {
    
    typealias ClickAccountBlock = () -> ()
    var clickAccountBlock : ClickAccountBlock?

    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "b2c_text_withdrawAccount".localized()
        label.layoutIfNeeded()
        label.isUserInteractionEnabled = false
        return label
    }()
    
    lazy var withdrawAccountBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitle("b2c_text_withdrawAccountManager".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        btn.contentHorizontalAlignment = .right
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    lazy var textFiled : EXIconSelectionField = {
        let view = EXIconSelectionField()
        view.extUseAutoLayout()
        view.setPlaceHolder(placeHolder: "b2c_text_choosWithdrawAccount".localized())
        view.iconBtn.imageView?.contentMode = .scaleAspectFit
        view.iconBtn.setImage(EXKitBundle.image(named: "public_positions_arrow_right"), for: .normal)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([nameLabel,withdrawAccountBtn,textFiled])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(14)
        }
        withdrawAccountBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(14)
        }
        textFiled.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickView))
        self.addGestureRecognizer(tap)
    }
    
    @objc func clickView(){
        self.clickAccountBlock?()
    }
    
    func setView(_ account : String){
        textFiled.setText(text: account)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//Withdrawal amount
class EXBtoCWithDrawCoinView: UIView {
    
    typealias WithDrawCoinWriteBlock = (String) -> ()
    var withDrawCoinWriteBlock : WithDrawCoinWriteBlock?
    
    var canUseBlance = ""
    
    lazy var textFiled : EXOTCTradeTextField = {
        let view = EXOTCTradeTextField()
        view.extUseAutoLayout()
        view.setTitle(title: "b2c_text_withdrawAmount".localized())
        view.setPlaceHolder(placeHolder: "b2c_text_inputWithdrawAmount".localized())
        view.bottomRightLabel.isHidden = true
        view.input.keyboardType = UIKeyboardType.decimalPad
        view.actionBtn.setTitle("common_action_sendall".localized(), for: UIControl.State.normal)
        view.input.keyboardType = .decimalPad
        view.sendAllCallback = {[weak self] in
            guard let mySelf = self else{return}
            view.input.text = mySelf.canUseBlance
            self?.withDrawCoinWriteBlock?(mySelf.canUseBlance)
        }
        view.textfieldValueChangeBlock = {[weak self]str in
            self?.withDrawCoinWriteBlock?(str)
        }
        view.maxLenth = 16
        return view
    }()
    
//    lazy var availableBalanceLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.textColor = UIColor.ThemeLabel.colorMedium
//        label.font = UIFont.ThemeFont.SecondaryRegular
//        return label
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubViews([textFiled])
        textFiled.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(74)
        }
//        availableBalanceLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.top.equalTo(textFiled.snp.bottom).offset(8)
//            make.right.equalToSuperview().offset(-15)
//            make.height.equalTo(14)
//        }
    }
    
    func setView(_ canUseBlance : String , symbol : String){
        self.canUseBlance = canUseBlance
        textFiled.setBottomLeftText(value: "withdraw_text_available".localized() + " " + canUseBlance + " " + symbol)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//Handling fees
class EXBtoCPoundageView : UIView{
    
    lazy var poundageText : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.setTitle(title: "withdraw_text_fee".localized())
        text.enableTitleModel = true
        text.isUserInteractionEnabled = false
        return text
    }()
    
    lazy var singleMinLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeState.warning
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var singleMaxLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeState.warning
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var todayWithDrawLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeState.warning
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([poundageText,singleMinLabel,singleMaxLabel,todayWithDrawLabel])
        poundageText.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(20)
        }
        singleMinLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(14)
            make.top.equalTo(poundageText.snp.bottom).offset(20)
        }
        singleMaxLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(14)
            make.top.equalTo(singleMinLabel.snp.bottom).offset(6)
        }
        todayWithDrawLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(14)
            make.top.equalTo(singleMaxLabel.snp.bottom).offset(6)
        }
    }
    
    func setView(_ num : String , symbol : String){
        poundageText.setExtraText(symbol)
        poundageText.setText(text: num)
    }
    
    //Set withdrawal
    func setwithDraw(_ entity : B2CCoinMapItem , symbol : String){
        singleMinLabel.text = "b2c_text_singleWithdrawMin".localized() + entity.withdrawMin + " " + symbol
        singleMaxLabel.text = "b2c_text_singleWithdrawMax".localized() + entity.withdrawMax + " " + symbol
        todayWithDrawLabel.text = "b2c_text_todayWithdraw".localized() + entity.canWithdrawBalance + " " + symbol
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//matters needing attention
class BtoCAnnouncementsView : UIView {
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorDark
        label.text = "b2c_text_announcements".localized()
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var announcementLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.layoutIfNeeded()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutIfNeeded()
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([titleLabel,announcementLabel])
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(16)
            make.top.equalToSuperview().offset(16)
        }
        announcementLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func setView(_ announcement : String){
        announcementLabel.text = announcement
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

