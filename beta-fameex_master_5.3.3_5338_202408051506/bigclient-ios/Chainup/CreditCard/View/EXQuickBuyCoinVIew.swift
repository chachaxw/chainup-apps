//
//  EXQuickBuyCoinVIew.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXQuickBuyCoinVIew: EXView {
    
    var buyBlock:EXComVoidBlock?
    var vm = EXCreditCardViewModel()
    //MARK: lazy
    lazy var bgView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .equalSpacing
        v.spacing = 0
        return v
    }()
    lazy var send: EXQuickBuyCoinCell = {
        let v = EXQuickBuyCoinCell(frame: .zero)
        v.titleLabel.text = "creditCard_text1".localized()
        return v
    }()
    lazy var sendTipLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeState.fail, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
       // label.text = "creditCard_text10".localized() + "200-3000 HKD"
        label.isHidden = true
        return label
    }()
    lazy var midlleImg : EXQuickBuyCoinMiddleCell = {
        let v = EXQuickBuyCoinMiddleCell(frame: .zero)
        return v
    }()
    lazy var recieve: EXQuickBuyCoinCell = {
        let v = EXQuickBuyCoinCell(frame: .zero)
        v.input.isUserInteractionEnabled = false
        v.titleLabel.text = "creditCard_text2".localized()
        return v
    }()

    ///Reference price
    lazy var indicationView: EXPriceindicationView = {
        let v = EXPriceindicationView()
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(switchTap))
//        v.addGestureRecognizer(tap)
//        v.isUserInteractionEnabled = true
        return v
    }()
    
    lazy var buyBtn:EXButton = {
        let btnSell = EXButton()
        btnSell.setTitle("cl_lever_text4".localized(), for: .normal)
        btnSell.setTitleColor(UIColor.white, for: .normal)
        btnSell.setTitleColor(UIColor.white, for: .selected)
        btnSell.isSelected = false
        btnSell.backgroundColor = UIColor.ThemeView.highlight
        btnSell.layer.cornerRadius = 4
        btnSell.layer.masksToBounds = true
        btnSell.addTarget(self, action: #selector(buy), for: .touchUpInside)
        btnSell.isEnabled = false
        return btnSell
    }()

    
    required init(viewModel: EXViewModelProtocol?) {
        self.vm = viewModel as? EXCreditCardViewModel ?? EXCreditCardViewModel()
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: lifecycle
    override func setupView() {
        self.backgroundColor = .Ex.fill2
        self.addSubViews([bgView,buyBtn])
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        buyBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-15)
        }
        let h = 81
        midlleImg.addSubview(sendTipLabel)
        sendTipLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-50)
            make.top.equalToSuperview()
        }
        bgView.addArrangedSubviews([send,midlleImg,recieve,indicationView])
        send.snp.makeConstraints { make in
            make.height.equalTo(h)
        }
       
        midlleImg.snp.makeConstraints { make in
            make.height.equalTo(69)
        }
        recieve.snp.makeConstraints { make in
//            make.width.equalToSuperview()
            make.height.equalTo(h)
        }
        indicationView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalToSuperview()
        }
        
    }
    
    //MARK: data
    override func bindViewModel() {
        let sendvaild = send.input.rx.text.orEmpty.asObservable()
            .map { [weak self] str -> Bool in
                guard let strong = self else {return true}
                
                let pass = strong.vm.payPassed(input: str)
                strong.vm.payCoin.amount = str
                strong.inputDidChange(isFait: true)
                strong.buyBtn.isEnabled = pass
                if str.count == 0 {
                    strong.buyBtn.isEnabled = false
                    return true
                }
                return pass
            }
        
        sendvaild.bind(to: self.sendTipLabel.rx.isHidden).disposed(by: disposeBag)

        
        
        vm.coinlistResult.subscribe(onNext: { [weak self] status in
            guard let `self` = self else { return }
            print(status)
            self.reloadView()
        }).disposed(by: self.disposeBag)
        vm.ratelistResult.subscribe(onNext: { [weak self] status in
            guard let `self` = self else { return }
            print(status)
            self.updateRate()
        }).disposed(by: self.disposeBag)
        
    }
    
    
    //MARK: action
    @objc func buy(){
        self.buyBlock?()
    }
   
    //Input, update currency pairs
    func inputDidChange(isFait: Bool){
        vm.caculate(isFait: isFait)
        reloadView()
    }
    
    func reloadView(){
        vm.payCoin.coinPlaceHolder = vm.getPayRange()
        send.model = vm.payCoin
        recieve.model = vm.recieveCoin
        sendTipLabel.text = vm.payCoin.limitTip
    }
    
    func rateEmpty(){
        send.input.isUserInteractionEnabled = false
        vm.payCoin.amount = ""
        vm.recieveCoin.amount = ""
        buyBtn.isEnabled = false
    }
    func updateRate(){
        
        send.input.isUserInteractionEnabled = true
        if vm.rateModel == nil { //Handling unconfigured situations that have not been returned
            indicationView.rateLabel.text = "creditCard_text3".localized() + "quick_buy_coin_text1".localized()
            rateEmpty()
        }else{
            if vm.rateModel!.rate.isEmpty {
                indicationView.rateLabel.text = "creditCard_text3".localized() + "quick_buy_coin_text1".localized()
                rateEmpty()
            }else{
                let rate = vm.rateModel!.rate
                var unit = ""
                if vm.isBuy {
                    unit = vm.payCoin.name + "/" + vm.recieveCoin.mainChainSymbol
                }else{
                    unit = vm.payCoin.mainChainSymbol + "/" + vm.recieveCoin.name
                }
                print("更新汇率 = \(vm.payCoin.name) ")
                let rateTotal = "creditCard_text3".localized() + rate + " " +  unit // vm.recieveCoin.alias + "/" + vm.payCoin.name
                let attr = rateTotal.attributeString(specalSubStr: rate, specailAttri:[
                    NSAttributedString.Key.font: UIFont.Ex.regular(12),
                    NSAttributedString.Key.foregroundColor: UIColor.Ex.text1],
                                                     commonAttri: [
                                                        NSAttributedString.Key.font: UIFont.Ex.regular(12),
                                                        NSAttributedString.Key.foregroundColor: UIColor.Ex.text2
                                                     ])
                indicationView.rateLabel.attributedText = attr
            }
        }
        indicationView.availableLabel.isHidden = vm.isBuy
        if vm.isBuy == false{
            self.vm.getAavialAmount()
            let canUseAmountTotal = "available_balance".localized() + "：" + self.vm.canUse + " " + vm.payCoin.name
            let attr = canUseAmountTotal.attributeString(specalSubStr: self.vm.canUse, specailAttri:[
                NSAttributedString.Key.font: UIFont.Ex.regular(12),
                NSAttributedString.Key.foregroundColor: UIColor.Ex.text1],
                 commonAttri: [
                     NSAttributedString.Key.font: UIFont.Ex.regular(12),
                     NSAttributedString.Key.foregroundColor: UIColor.Ex.text2
                 ])
            indicationView.availableLabel.attributedText = attr
        }
        vm.payCoin.coinPlaceHolder = vm.getPayRange()
        vm.recieveCoin.coinPlaceHolder = vm.getReceviceRange()
        send.model = vm.payCoin
        recieve.model = vm.recieveCoin
    }
}

