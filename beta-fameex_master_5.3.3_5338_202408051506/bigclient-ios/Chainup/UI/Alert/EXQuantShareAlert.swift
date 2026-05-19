//
//  EXQuantShareAlert.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/31.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit


class EXQuantShareItem:EXBaseModel {
    var title:String = ""
    var titleColor:UIColor = UIColor.ThemeLabel.colorMedium
    var value:String = ""
    var valueColor:UIColor = UIColor.ThemeLabel.colorLite
}

class EXQuantShareModel:EXBaseModel {
    var mainShares:[EXQuantShareItem] = []
    var subShares:[EXQuantShareItem] = []
    
    class func getQuantShareModel(item:EXQuantStrategyListItem) -> EXQuantShareModel{
        //Grid profit+annualized income
        let shareM = EXQuantShareModel()
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(item.symbol)
        var mainItems:[EXQuantShareItem] = []
        let itemMain = EXQuantShareItem()
        itemMain.title = "quant_grid_profit".localized() + "(\(coinmap.marketName.aliasName()))"
        itemMain.value = item.totalProfit.decimalString(value: coinmap.priceDecimal()).plusSymbolStr()
        itemMain.valueColor = item.totalProfit.getValueColor()
        mainItems.append(itemMain)
        let itemMainB = EXQuantShareItem()
        itemMainB.title = "quant_annualized_yield".localized()
        itemMainB.value = item.fmtValue(item.annualizedYield.formatAmountUseDecimal("2") + "%")
        itemMainB.valueColor =  item.annualizedYield.getValueColor()
        mainItems.append(itemMainB)
        shareM.mainShares = mainItems
        
        //交易对//运行时间//Arbitrage frequency
        var subItems:[EXQuantShareItem] = []
        let itemA:EXQuantShareItem = EXQuantShareItem()
        itemA.title = "filter_mix_tradeCoinPair".localized()
        itemA.value = coinmap.showName
        subItems.append(itemA)
        let itemB:EXQuantShareItem = EXQuantShareItem()
        itemB.title = "quant_run_time".localized()
        
        
        var endTime = item.endTime
//        if item.strategyStatus == "1" {//running / 3 end
            endTime = DateTools.getMillTimeInterval()
//        }
        
        itemB.value = DateTools.updateTimeToCurrennTime(timeStamp:NumberHandler.handleDouble(item.startTime), endTimeStamp: NumberHandler.handleDouble(endTime),isPravate: true)
        subItems.append(itemB)
        let itemC:EXQuantShareItem = EXQuantShareItem()
        itemC.title = "quant_order_pending_totalcount".localized()
        let timeForAll = item.totalProfitTimes.count > 0 ? item.totalProfitTimes : "0"
        itemC.value = timeForAll + "otc_other_times".localized()
        subItems.append(itemC)
        shareM.subShares = subItems
        return shareM
    }
}

class EXNewQuantShareAlert: UIView {
    
    var shareIdx: Int = 0
    var shareModel: EXQuantShareModel?
    
    var subShareTitles: [UILabel] = []
    var subShareValues: [UILabel] = []
    
    lazy var shareImgView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.image = UIImage(named: "trade_grid.png")
        return iv
        
    }()
   
    lazy var titleL: UILabel = {
        let v = UILabel(font: .Ex.medium(30), textColor: .white)
        v.numberOfLines = 1
        v.text = "grid_share_title".localized()
        return v
    }()
    
    lazy var titleNoteL: EXInsetLabel = {
        let v = EXInsetLabel(font: .Ex.medium(12), textColor: .white, alignment: .center)
        v.backgroundColor = .extColorWithHex("#4D4D4D")
        let text = "grid_share_desc".localized()
        v.text = text
        v.edgeInset = text.isEmpty ? .zero : .init(top: 4, left: 12, bottom: 4, right: 12)
        v.numberOfLines = 2
        return v
    }()

    lazy var shareTitleL:UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text2
        lable.font = UIFont.Ex.medium(12)
        lable.textAlignment = .center
        return lable
    }()
    
    lazy var shareContentL:UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text2
        lable.font = UIFont.Ex.bold(32)
        lable.textAlignment = .center
        return lable
    }()
    
    lazy var leftBtn:UIButton = {
        let button = UIButton(type: .custom)
        button.setEnlargeEdgeWithTop(20, left: 20, bottom: 20, right: 20)
        button.setImage(UIImage.themeImageNamed(imageName: "swipe-down"), for: .normal)
        button.addTarget(self, action: #selector(leftAction), for: .touchUpInside)
        return button
    }()
    
    lazy var rightBtn:UIButton = {
        let button = UIButton(type: .custom)
        button.setEnlargeEdgeWithTop(20, left: 20, bottom: 20, right: 20)
        button.setImage(UIImage.themeImageNamed(imageName: "swipe-up"), for: .normal)
        button.addTarget(self, action: #selector(rightAction), for: .touchUpInside)
        return button
    }()
    
    lazy var leftTitleL:UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text2
        lable.font = UIFont.Ex.medium(12)
        lable.textAlignment = .center
        return lable
    }()
    
    lazy var leftContentL:UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text1
        lable.font = UIFont.Ex.medium(14)
        lable.textAlignment = .center
        return lable
    }()
    
    lazy var middleTitleL:UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text2
        lable.font = UIFont.Ex.medium(12)
        lable.textAlignment = .center
        return lable
    }()
    
    lazy var middleContentL:UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text1
        lable.font = UIFont.Ex.medium(14)
        lable.textAlignment = .center
        return lable
    }()
    
    lazy var rightTitleL:UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text2
        lable.font = UIFont.Ex.medium(12)
        lable.textAlignment = .center
        return lable
    }()
    
    lazy var rightContentL:UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text1
        lable.font = UIFont.Ex.medium(14)
        lable.textAlignment = .center
        return lable
    }()
    
    lazy var horLine:UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill4
        return v
    }()
    
    
    lazy var logoImgView: UIImageView = {
        let iv = UIImageView()
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 8
        iv.image = UIImage.themeImageNamed(imageName: "AppIcon")
        return iv
        
    }()
    
    lazy var companyTitle:UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text1
        lable.font = UIFont.Ex.medium(14)
        lable.textAlignment = .center
        lable.text = EXKitStanders.getAppName()
        return lable
    }()
    
    lazy var slogan:UILabel = {
        let lable = UILabel()
        lable.textColor = .Ex.text1
        lable.font = UIFont.Ex.medium(10)
        lable.textAlignment = .center
        lable.text = "common_share_detail".localized()
        return lable
    }()
    
    lazy var qrCodeImgView: UIImageView = {
        let iv = UIImageView()
        iv.image = QRCodeCreate().creteScancode(UserInfoEntity.sharedInstance().inviteUrl)
        return iv
    }()
    
    lazy var shareView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .Ex.fill6
        return view
    }()
    
    lazy var shareBtn: EXButton = {
        let btn = EXButton(type: .custom)
        btn.setTitle("common_share_confirm".localized(), for: .normal)
        btn.addTarget(self, action: #selector(shareBtnClick), for: .touchUpInside)
        btn.contentEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: 12)
        return btn
    }()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        shareView.layer.cornerRadius = 12
        titleNoteL.extSetCornerRadius(CGRectGetHeight(titleNoteL.frame) * 0.5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        createUI()
        self.snp.makeConstraints { make in
            make.height.equalTo(588)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createUI(){
        
        subShareTitles = [leftTitleL,middleTitleL,rightTitleL];
        subShareValues = [leftContentL,middleContentL,rightContentL]
        
        self.addSubview(shareView)
        shareView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 315, height: 476))
        }
        
        shareView.addSubview(shareImgView)
        shareImgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(shareImgView.snp.width).multipliedBy(0.781)
        }
        
        shareView.addSubViews([titleL, titleNoteL])
        titleL.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(42)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-32)
        }
        titleNoteL.snp.makeConstraints { make in
            make.top.equalTo(titleL.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-32)
        }
        titleNoteL.superview?.layoutIfNeeded()

        let titleStackView: UIStackView = UIStackView()
        shareView.addSubview(titleStackView)
        titleStackView.axis = .vertical
        titleStackView.spacing = 2
        titleStackView.addArrangedSubviews([shareTitleL,shareContentL])
        
        titleStackView.snp.makeConstraints { make in
            make.top.equalTo(shareImgView.snp.bottom).offset(23)
            make.centerX.equalToSuperview()
            
        }
        
        
        shareView.addSubview(leftBtn)
        leftBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titleStackView)
            make.left.equalTo(48)
        }
        
        shareView.addSubview(rightBtn)
        rightBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titleStackView)
            make.right.equalTo(-48)
        }
        
        let leftStackView = verStackView(topView: leftTitleL, bottomView: leftContentL, alignment: .leading)
        let middleStackView = verStackView(topView: middleTitleL, bottomView: middleContentL,alignment: .center)
        let rightStackView = verStackView(topView: rightTitleL, bottomView: rightContentL,alignment: .trailing)
        leftStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        middleStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        rightStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        shareView.addSubViews([leftStackView, middleStackView, rightStackView])

       
        leftStackView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(28)
        }
        middleStackView.snp.makeConstraints { make in
            make.top.equalTo(leftStackView)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(leftStackView.snp.right).offset(2)
            make.bottom.equalTo(leftStackView)
        }
        rightStackView.snp.makeConstraints { make in
            make.top.equalTo(leftStackView)
            make.left.greaterThanOrEqualTo(middleStackView.snp.right).offset(2)
            make.right.equalToSuperview().offset(-28)
            make.bottom.equalTo(leftStackView)
        }
        
        
        shareView.addSubview(horLine)
        horLine.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.4)
            make.top.equalTo(leftStackView.snp.bottom).offset(15.5)
        }
        
        shareView.addSubview(logoImgView)
        logoImgView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(horLine.snp.bottom).offset(15)
            make.width.height.equalTo(40)
        }
        
        shareView.addSubview(companyTitle)
        companyTitle.snp.makeConstraints { make in
            make.left.equalTo(logoImgView.snp.right).offset(9.5)
            make.top.equalTo(logoImgView.snp.top).offset(2)
            
        }
        
        shareView.addSubview(slogan)
        slogan.snp.makeConstraints { make in
            make.left.equalTo(logoImgView.snp.right).offset(9.5)
            make.bottom.equalTo(logoImgView.snp.bottom).offset(-2)
        }
        
        shareView.addSubview(qrCodeImgView)
        qrCodeImgView.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.width.height.equalTo(40)
            make.centerY.equalTo(logoImgView.snp.centerY)
        }
        
        self.addSubview(shareBtn)
        shareBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
            make.top.equalTo(shareView.snp.bottom).offset(30)
        }
    
    }
    
    func verStackView(topView:UIView,bottomView: UIView, alignment: UIStackView.Alignment) -> UIStackView{
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5.6
        stackView.alignment = alignment
        stackView.addArrangedSubviews([topView,bottomView])
        return stackView
    }
   
}

extension EXNewQuantShareAlert{
    
    @objc func shareBtnClick(){
        EXAlert.dismissEnd(complete: {
            let image = self.shareView.screenShot()
            if let topVc = AppService.topViewController() {
                ShareHandler.share(topVc, image: image, completionHandler: {
                    //                    self.clickSelf()
                })
            }
        }, delay: 0.0)
    }
    
    @objc func leftAction() {
        guard let model = self.shareModel else {return}
        shareIdx -= 1
        if shareIdx < 0 {
            shareIdx = model.mainShares.count - 1
        }
        updateShareMain(idx: shareIdx)
    }
    
    @objc func rightAction() {
        guard let model = self.shareModel else {return}
        shareIdx += 1
        if shareIdx > model.mainShares.count - 1 {
            shareIdx = 0
        }
        updateShareMain(idx: shareIdx)
    }
    
    func updateShareMain(idx:Int) {
        guard let model = self.shareModel else {return}
        if model.mainShares.count > idx {
            let mainItemA = model.mainShares[idx]
            shareTitleL.text = mainItemA.title
            shareTitleL.textColor = mainItemA.titleColor
            shareContentL.text = mainItemA.value
            shareContentL.textColor = mainItemA.valueColor
        }
    }

    func bindShareModels(model:EXQuantShareModel) {
        if model.mainShares.count > shareIdx {
            self.shareModel = model
            updateShareMain(idx: shareIdx)
            if model.subShares.count == subShareTitles.count{
                for (idx,item) in model.subShares.enumerated() {
                    let title = subShareTitles[idx]
                    let value = subShareValues[idx]
                    title.text = item.title
                    title.textColor = item.titleColor
                    value.text = item.value
                    value.textColor = item.valueColor
                }
            }
        }
    }
    
    
}



