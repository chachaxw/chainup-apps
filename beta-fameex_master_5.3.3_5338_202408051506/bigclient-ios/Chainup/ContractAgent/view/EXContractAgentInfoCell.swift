//
//  EXContractAgentInfoCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXContractAgentInfoCell: EXInviteBasicCell {
    
   private var model: EXAgentContractModel?
    
    
    lazy var rebateRateV: UILabel = {
        let v = UILabel(text: "RebateRate".localized(), font: .Ex.regular(12), textColor: .Ex.text2)
        return v
    }()
    
    lazy var rebateRateValueV: UILabel = {
        let v = UILabel(font: .Ex.medium(14), textColor: .Ex.text1)
        return v
    }()
    
    lazy var rebateRateValueDoubtButton: UIButton = {
        let v = UIButton(type: .custom)
        v.imageView?.contentMode = .scaleAspectFit
        v.enlargeInteractionEdge(with: 5)
        v.setImage(UIImage.themeImageNamed(imageName: "public_hint").reSizeImage(reSize: CGSize(width: 14, height: 14)), for: .normal)
        v.isHidden = true
        return v
    }()
    
    lazy var rebateRateContainer: UIView = {
        let v = UIView()
        return v
    }()
    
    
    ////
    lazy var mngTotalUserV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.bottomTextColor = .Ex.text1
        v.topText = "MngTotalUser".localized()
        v.bottomText = "--"
        return v
    }()
    
    
    lazy var totalUV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.textAlignment = .right
        v.bottomTextColor = .Ex.text1
        v.topText = "coAgent_text_childTotalUSDT".localized()
        v.bottomText = "--"
        return v
    }()
    
    lazy var yesterdayV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.bottomTextColor = .Ex.text1
        v.topText = "coAgent_text_yesterdayReturn".localized()
        v.bottomText = "--"
        return v
    }()

    lazy var beforeYesterdayV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.textAlignment = .right
        v.bottomTextColor = .Ex.text1
        v.topText = "coAgent_text_byesterdayReturn".localized()
        v.bottomText = "--"
        return v
    }()
    
    lazy var infoContainer: UIView = {
        let v = UIView()
        return v
    }()
    
    override func onCreate() {
        super.onCreate()
        titleView.contentInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        contentView.addSubViews([titleView, infoContainer])
        infoContainer.addSubViews([rebateRateContainer,
                                   mngTotalUserV, totalUV,
                                   yesterdayV, beforeYesterdayV])
        rebateRateContainer.addSubViews([rebateRateV, rebateRateValueV, rebateRateValueDoubtButton])
        
        ///
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.width.equalToSuperview()
            make.height.equalTo(52)
        }
        infoContainer.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
        
        ///
        rebateRateContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.height.equalTo(40)
        }
        
        rebateRateV.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        rebateRateValueV.snp.makeConstraints { make in
            make.top.equalTo(rebateRateV.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(rebateRateV).multipliedBy(1.143)
        }
        rebateRateValueDoubtButton.snp.makeConstraints { make in
            make.left.equalTo(rebateRateValueV.snp.right).offset(4)
            make.centerY.equalTo(rebateRateValueV)
            make.right.lessThanOrEqualToSuperview()
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        ///
        mngTotalUserV.snp.makeConstraints { make in
            make.top.equalTo(rebateRateContainer.snp.bottom).offset(16)
            make.left.equalToSuperview()
            make.height.equalTo(rebateRateContainer)
        }
        
        totalUV.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.greaterThanOrEqualTo(mngTotalUserV.snp.right).offset(8)
            make.centerY.height.equalTo(mngTotalUserV)
        }
        
        ///
        yesterdayV.snp.makeConstraints { make in
            make.top.equalTo(mngTotalUserV.snp.bottom).offset(16)
            make.left.equalToSuperview()
            make.height.equalTo(mngTotalUserV)
            make.bottom.equalToSuperview()
        }
        beforeYesterdayV.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.greaterThanOrEqualTo(yesterdayV.snp.right).offset(8)
            make.centerY.height.equalTo(yesterdayV)
        }
     
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        rebateRateValueDoubtButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self else { return }
            guard let scaleInfo = self.model?.scaleInfo, scaleInfo.count != 0 else { return }
            let v = EXRebateRatioAlert()
            v.dataList = scaleInfo
            EXAlert.showAlert(alertView: v)
        }).disposed(by: disposeBag)
        
    }
   
    
    
    func bindAgentModel(config: EXInvitationPublicConfigModel?, model: EXAgentContractModel?) {
        super.setInvitePublicConfigModel(config)
        self.model = model
        if let coBrokerRuleUrl = config?.config.coBrokerRuleUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
           !coBrokerRuleUrl.isEmpty {
            titleView.ruleButton.isHidden = false
        }
        
        if let roleType = model?.roleType, roleType == 0, 
            let scaleInfo = self.model?.scaleInfo, scaleInfo.count != 0 {
            rebateRateValueDoubtButton.isHidden = false
        }
        
        titleView.titleLabel.text   = model?.roleName
        rebateRateValueV.text      = (model?.scaleReturn.bigMul("100") ?? "--") + "%"
        mngTotalUserV.bottomText    = model?.countAgent
        totalUV.bottomText          = model?.amountTotal.formatAmount("USDT")
        yesterdayV.bottomText       = model?.amountYesterday.formatAmount("USDT")
        beforeYesterdayV.bottomText = model?.amountBYesterday.formatAmount("USDT")
      }
    
}



//class EXContractAgentInfoCell: UITableViewCell {
//
//    var model: EXAgentContractModel?
//    lazy var infoView: EXThreeColumnView = {
//        let rowA = EXThreeColumnView()
//        rowA.btnClickBlock = {  [weak self] in
//            guard let newSelf = self else{
//                return
//            }
//            newSelf.ratioAlert()
//            
//        }
//        return rowA
//    }()
//
//    
//    lazy var container :EXTwoByTwoContainer = {
//        let rowA = EXTwoByTwoContainer()
//        return rowA
//    }()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.selectionStyle = .none
//        contentView.backgroundColor = UIColor.ThemeView.bg
//        contentView.addSubViews([infoView,container])
//        
//        infoView.snp.makeConstraints { (make) in
//            make.top.equalTo(20)
//            make.left.equalToSuperview().offset(15)
//            make.right.equalToSuperview().offset(-15)
//            make.height.equalTo(54)
//            make.bottom.equalTo(container.snp.top).offset(-5)
//        }
//        
////        container.snp.makeConstraints { (make) in
////            make.top.equalTo(cellTitle.snp.bottom).offset(20)
////            make.left.equalToSuperview().offset(15)
////            make.right.equalToSuperview().offset(-15)
////            make.bottom.equalToSuperview().offset(-15)
////        }
//        container.snp.makeConstraints { (make) in
//            make.top.equalTo(infoView.snp.bottom).offset(5)
//            make.left.equalToSuperview().offset(15)
//            make.right.equalToSuperview().offset(-15)
//            make.bottom.equalToSuperview().offset(-15)
//        }
//    }
//    
//    func getStyle()->ExThreeColumnStyle {
//        let style = ExThreeColumnStyle()
//        style.topLabelFont = self.themeHNFont(size: 12)
//        style.topLabelColor = UIColor.ThemeLabel.colorMedium
//        style.bottomLabelFont = self.themeHNBoldFont(size: 14)
//        style.bottomLabelColor = UIColor.ThemeLabel.colorLite
//        return style
//    }
//    
//    func ratioAlert(){
//        let v = EXRebateRatioAlert()
//        v.dataList = self.model?.scaleInfo
//        EXAlert.showAlert(alertView: v)
//        return
//
//    }
//    func bindCellInfo(model :EXAgentContractModel) {
//        var models:[ExThreeColumnDataModel] = []
//        
//        let modell = ExThreeColumnDataModel()
//        modell.title = "RebateRate".localized()
//        modell.content = model.scaleReturn.bigMul("100") + "%"//Direct push back commission
//        modell.style = self.getStyle()
//        models.append(modell)
//
//        if model.roleType == 0  { //0: Proportional broker, 1: Extreme broker
//            modell.content = model.rebateRate()
//            infoView.indicatorBtn.isHidden = false
//        }
//        
//        infoView.bindItems(with: models,ignoreModelCount: false)
//        
//        let modelB = EXTwoByTwoItemModel() //Number of users
//          modelB.ltitleColor = UIColor.ThemeLabel.colorMedium
//          modelB.rtitleColor = UIColor.ThemeLabel.colorMedium
//          modelB.lcontentFont = self.themeHNBoldFont(size: 14)
//          modelB.lcontentColor = UIColor.ThemeLabel.colorLite
//          modelB.rcontentFont = self.themeHNBoldFont(size: 14)
//          modelB.rcontentColor = UIColor.ThemeLabel.colorLite
//          modelB.ltitle = "MngTotalUser".localized()
//          modelB.rtitle = "coAgent_text_childTotalUSDT".localized()
//          modelB.ltitleFont = self.themeHNFont(size: 12)
//          modelB.rtitleFont = self.themeHNFont(size: 12)
//
//          let modelC = EXTwoByTwoItemModel() //Yesterday's return of commission
//          modelC.ltitleColor = UIColor.ThemeLabel.colorMedium
//          modelC.rtitleColor = UIColor.ThemeLabel.colorMedium
//          modelC.lcontentFont = self.themeHNBoldFont(size: 14)
//          modelC.lcontentColor = UIColor.ThemeLabel.colorLite
//          modelC.rcontentFont = self.themeHNBoldFont(size: 14)
//          modelC.rcontentColor = UIColor.ThemeLabel.colorLite
//          modelC.ltitle = "coAgent_text_yesterdayReturn".localized()
//          modelC.rtitle = "coAgent_text_byesterdayReturn".localized()
//          modelC.ltitleFont = self.themeHNFont(size: 12)
//          modelC.rtitleFont = self.themeHNFont(size: 12)
//
//          modelB.lcontent = model.countAgent//Number of customers
//          modelB.rcontent = model.amountTotal.formatAmount("USDT")//Accumulated commission conversion
//          modelC.lcontent = model.amountYesterday.formatAmount("USDT")//Yesterday's commission converted into
//          modelC.rcontent = model.amountBYesterday.formatAmount("USDT")//Previous day's commission conversion
//          container.bindContainers([modelB,modelC])
//    }
//
//    func bindAgentModel(model:EXAgentContractModel?) {
//        guard let data = model else {
//            return
//        }
//        self.model = model
//        bindCellInfo(model: data)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//}
//
