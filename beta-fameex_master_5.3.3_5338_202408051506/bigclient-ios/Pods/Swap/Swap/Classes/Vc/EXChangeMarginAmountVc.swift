//
//  EXChangeMarginAmountVc.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

//class EXChangeMarginAmountVc: EXSNavCustomVC {
//
//    typealias ClickAdjustDeposit = (Bool) -> ()
//    var clickAdjustDeposit : ClickAdjustDeposit?
//
//    var positionModel : EXSwapPositionModel?{
//        didSet {
//
//            infoVaild.decail = positionModel?.ex_contractInfo?.value_unit ?? ""
//        }
//    }
//
//    var infoVaild:EXSInputLimitDelegate = EXSInputLimitDelegate()
//
//
//    var asset : EXCItemCoinModel? {
//        get {
//            return EXSwapPersonInfo.shared.getSwapAssetItem(withCoin: positionModel?.ex_contractInfo?.margin_coin)
//        }
//    }
//
//    var less_qty = ""
//
//    var most_qty = ""
//
//    lazy var headerView : UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.ThemeNav.bg
//        return view
//    }()
//
//    ///Current margin
//    lazy var currentDepositLabel: UILabel = {
//        let text = String(format: "%@(%@)", "cp_extra_text165".ex_localized(),positionModel?.ex_contractInfo?.quote_coin ?? "USDT")
//        let label = UILabel(text: text, font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
//        label.numberOfLines = 0
//        return label
//    }()
//    lazy var currentDepositPrice: UILabel = {
//        let text = "--"
//        let label = UILabel(text: text, font: UIFont.ThemeFont.BodyBold, textColor: UIColor.ThemeState.warning, alignment: .left)
//        label.numberOfLines = 0
//        return label
//    }()
//
//    ///Adjusted Qiangping Price
//    lazy var forceLabel: UILabel = {
//        let text = "cp_extra_text166".ex_localized()
//        let label = UILabel(text: text, font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
//        label.numberOfLines = 0
//        return label
//    }()
//    lazy var forcePrice: UILabel = {
//        let text = "--"
//        let label = UILabel(text: text, font: UIFont.ThemeFont.BodyBold, textColor: UIColor.ThemeState.warning, alignment: .left)
//        label.numberOfLines = 0
//        return label
//    }()
//
//    ///Adjusted lever
//    lazy var levelLabel: UILabel = {
//        let text = "cp_order_text27".ex_localized()
//        let label = UILabel(text: text, font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .right)
//        label.numberOfLines = 0
//        return label
//    }()
//    lazy var level: UILabel = {
//        let text = "--"
//        let label = UILabel(text: text, font: UIFont.ThemeFont.BodyBold, textColor: UIColor.ThemeState.warning, alignment: .right)
//        label.numberOfLines = 0
//        return label
//    }()
//
//    ///Deposit quantity
//    lazy var depositInput: EXSTextField = {
//        let input = EXSTextField()
//        input.enableTitleModel = true
//        input.input.keyboardType = UIKeyboardType.decimalPad
//        input.titleLabel.secondaryRegular()
//        input.setTitle(title: "cp_extra_text165".ex_localized())
//        input.setPlaceHolder(placeHolder: "cp_calculator_text39".ex_localized())
//
//        input.input.rx.text.orEmpty.asObservable().subscribe{ [ weak self] (event) in
//            guard let mySelf = self else{return}
//
//            if let str = event.element{
//                if str.greaterThan(mySelf.most_qty){
//                    input.input.text = self?.most_qty
//                    EXAlert.showFail(msg: self?.depositLabel.text ?? "")
//                }
//            }
//        }.disposed(by: self.exs_disposeBag)
//        input.textfieldValueChangeBlock = {[weak self]str in
//            guard let mySelf = self else{return}
//            mySelf.textFieldValueHasChanged(textField: input.input)
//        }
//        return input
//    }()
//    ///Margin Scope
//    lazy var depositLabel: UILabel = {
//        let text = String(format:"%@ 0 %@","cp_str_margin_range".ex_localized(),positionModel?.ex_contractInfo?.margin_coin ?? "USDT")
//
//        let label = UILabel(text: text, font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
//        label.numberOfLines = 0
//        return label
//    }()
//    ///Confirm
//    lazy var confirmButton: EXSButton = {
//        let button = EXSButton()
//        button.setTitle("cp_calculator_text16".ex_localized(), for: .normal)
//        button.addTarget(self, action: #selector(clickConfirmButton), for: .touchUpInside)
//        return button
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.contentView.exs_addSubViews([headerView,currentDepositLabel,currentDepositPrice,forceLabel,depositInput,depositLabel,levelLabel,level,confirmButton,forcePrice])
//        self.initLayout()
//        self.depositInput.input.delegate = infoVaild
//
//    }
//
//    override func setNavCustomV() {
//        self.setTitle("cp_order_text16".ex_localized())
//        self.navtype = .list
//    }
//
//    deinit {
//
//        NotificationCenter.default.removeObserver(self)
//    }
//}


//extension EXChangeMarginAmountVc {
//    private func initLayout() {
//        headerView.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.right.equalToSuperview().offset(-15)
//            make.top.equalTo(self.navCustomView.snp.bottom).offset(15)
//            make.height.equalTo(60)
//        }
//
//        currentDepositLabel.snp.makeConstraints { (make) in
//
//            make.left.equalToSuperview().offset(25)
//            make.top.equalTo(self.navCustomView.snp.bottom).offset(25)
//            make.height.equalTo(15)
//        }
//
//        currentDepositPrice.snp.makeConstraints { (make) in
//            make.top.equalTo(currentDepositLabel.snp.bottom).offset(10)
//            make.left.equalTo(currentDepositLabel)
//        }
//
//        forceLabel.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(currentDepositLabel)
//        }
//        forcePrice.snp.makeConstraints { (make) in
//            make.centerX.height.equalTo(forceLabel)
//            make.top.equalTo(forceLabel.snp.bottom).offset(10)
//        }
//        levelLabel.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-25)
//            make.top.equalTo(self.navCustomView.snp.bottom).offset(25)
//            make.height.equalTo(15)
//        }
//        level.snp.makeConstraints { (make) in
//            make.right.height.equalTo(levelLabel)
//            make.top.equalTo(levelLabel.snp.bottom).offset(10)
//        }
//        depositInput.snp.makeConstraints { (make) in
//            make.left.equalTo(15)
//            make.right.equalTo(-15)
//            make.top.equalTo(self.headerView.snp.bottom).offset(15)
//        }
//        depositLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(15)
//            make.right.equalTo(-15)
//            make.top.equalTo(self.depositInput.snp.bottom).offset(5)
//        }
//        confirmButton.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.right.equalToSuperview().offset(-15)
//            make.height.equalTo(44)
//            make.top.equalTo(depositLabel.snp.bottom).offset(20)
//        }
//    }
//
//    func updatePositionModel(_ positionModel : EXSwapPositionModel) {
//
//        self.positionModel = positionModel
//        self.positionModel?.ex_contractInfo = positionModel.ex_contractInfo
//
//        self.currentDepositLabel.text = String(format: "%@(%@)", "cp_extra_text165".ex_localized(),positionModel.ex_contractInfo?.margin_coin ?? "USDT")
//        let im = positionModel.im.toValuePrecision(withContract: positionModel.instrument_id)
//
//        forcePrice.text = positionModel.calculateReducePrice()
//        less_qty = im.bigSub(positionModel.canSubMarginAmount).toValuePrecision(withContract: self.positionModel!.instrument_id)
//
//        self.currentDepositPrice.text = im
//        self.depositInput.input.text = im
//        if let a = self.asset {
//
//            most_qty = im.bigAdd(a.canUseAmount).toValuePrecision(withContract: self.positionModel!.instrument_id)
//        }
//        if let marginCoin = positionModel.ex_contractInfo?.margin_coin {
//
//            depositLabel.text = String(format:"%@ %@-%@%@","cp_str_margin_range".ex_localized(),less_qty,most_qty,marginCoin)
//        }
//
//
//        let reality = self.positionModel?.calculateLeverage() ?? "1"
//
//        self.level.text = String(format:"%@X",reality.exs_decimalString(1))
//    }
//
//    func textFieldValueHasChanged(textField:UITextField) {
//        if self.positionModel == nil {
//            return
//        }
//        if textField == self.depositInput.input {
//            let text = textField.text ?? "0"
//            if text.lessThan(less_qty) || text.greaterThan(most_qty) {
//                if positionModel!.position_type == .pursueType{
//                    forcePrice.text = "--"
//                    self.level.text = "--"
//                }
//                confirmButton.isUserInteractionEnabled = false
//                confirmButton.color = UIColor.ThemeBtn.disable
//                return
//            }
//            confirmButton.isUserInteractionEnabled = true
//            confirmButton.color = UIColor.ThemeBtn.highlight
//            if let position = EXSwapPositionModel.mj_object(withKeyValues: self.positionModel?.mj_keyValues()) {
//
//                position.ex_contractInfo = self.positionModel?.ex_contractInfo
//
//                position.im = text
//
//                var reality = position.calculateLeverage()
//                let arrLeverage = reality.components(separatedBy: ".")
//                if arrLeverage.count == 2 {
//                    reality = arrLeverage[0].bigAdd(DecimalOne)
//                }
//
//                self.level.text = String(format:"%@X",reality)
//                if self.positionModel?.position_type == .allType { //Full warehouse
//                    return
//                }
//                forcePrice.text = position.calculateReducePrice()
//            }
//        }
//    }
//
//    @objc func clickConfirmButton() {
//        if self.positionModel != nil {
//            var im = self.positionModel!.im
//            im = im.toValuePrecision(withContract: positionModel!.instrument_id)
//            if self.depositInput.input.text == "" {
//                EXAlert.showFail(msg: "redpacket_send_inputAmount".ex_localized())
//                return
//            }
//
//            var currentIM = self.depositInput.input.text ?? "0"
//            currentIM = currentIM.toValuePrecision(withContract: positionModel!.instrument_id)
//            let qty = currentIM.bigSub(im)
//            var oper_type = "2"
//            if im.lessThan(currentIM) {
//                oper_type = "1"
//            }
//            if (qty.isZero()) {
//                self.navigationController?.popViewController(animated: true)
//                return
//            }
//            confirmButton.isUserInteractionEnabled = false
//
//            EXContractNetwork.changePositionMargin(id: self.positionModel!.instrument_id, positionId: self.positionModel!.pid, amount: qty, type:oper_type) {[weak self] success in
//
//                if success {
//                    self?.clickAdjustDeposit?(true)
//                    self?.navigationController?.popViewController(animated: true)
//                }
//                self?.confirmButton.isUserInteractionEnabled = true
//            }
//        }
//    }
//}

