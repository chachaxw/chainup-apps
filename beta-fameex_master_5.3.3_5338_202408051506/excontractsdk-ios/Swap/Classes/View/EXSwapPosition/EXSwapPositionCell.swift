//
//  SLSwapPositionCell.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/20.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
/// 仓位 cell 也用于 币种详情 English: /Position cells are also used for currency details
class EXSwapPositionCell : UITableViewCell {
    typealias PositionCellBlock = (EXSwapPositionModel) -> ()
    typealias EXSwapPositionCellBlock = () -> ()
    var StopPLBlock:PositionCellBlock?
    var SpeedCloseBlock:PositionCellBlock?
    var CloseBlock:PositionCellBlock?
//    var viewModel: EXContractHomeViewModel?
    var needReloadCellBlock : EXSwapPositionCellBlock?
    var willPushVcBlock:EXSwapPositionCellBlock?
    var positionModel : EXSwapPositionModel?
    
    private lazy var marginLine1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeView.seperator
        view.isHidden = true
        return view
    }()

    /// 多 空 类型 English: /Multiple empty type
    lazy var dealTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadBold, textColor: nil, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    /// 合约名称 English: /Contract Name
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    /// 合约类型 English: /Contract type
    lazy var contractTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.colorHighlight, alignment: NSTextAlignment.center)
        label.backgroundColor = UIColor.Ex.main3
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    
    /// 分享 English: /Sharing
    lazy var shareButton: RepeatButton = {
        let button = RepeatButton(buttonType: .custom, image: UIImage.exs_themeImageNamed(imageName: "public_icon_share"))
        button.ext_SetAddTarget(self, #selector(clickShareButton))
        return button
    }()
    
    lazy var shareLabel: UILabel = {
        let label = UILabel(text: "cp_extra_text116".ex_localized(), font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorHighlight, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickShareButton))
        label.addGestureRecognizer(tap)
        return label
    }()
    
    /// 开仓均价 English: /Average opening price
    lazy var openAverageView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.ext_UseAutoLayout()
        view.bottomLabel.font = UIFont.ThemeFont.HeadBold
        view.setTopText("cp_order_text7".ex_localized())
        return view
    }()
    
    /// 未实现盈亏 English: /Unrealized gains and losses
    lazy var PLNView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.showDashline = true
        view.ext_UseAutoLayout()
        view.setTopText("cl_roi_6".ex_localized())
        view.bottomLabel.font = UIFont.ThemeFont.HeadBold
        view.clickMiddleBtnBlock = { [weak self] in
            let alert = EXSPriceTypeAlertView(frame: CGRect(x: 0, y: 0, width:EXSCREEN_WIDTH, height: 280))
            EXAlert.showSheet(sheetView: alert)
            return
        }
        
        return view
    }()
    
    lazy var PLNRate: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.ext_UseAutoLayout()
        view.bottomLabel.font = UIFont.ThemeFont.HeadBold
        view.contentAlignment = .right
        view.setTopText("cp_calculator_text15".ex_localized())
        return view
    }()
    
    /// 虚线 English: /Dashed line
    lazy var dottedLineView: UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    /// 标记价格 English: /Mark price
    lazy var targetPriceView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.contentAlignment = .left
        view.setTopText("cp_overview_text20".ex_localized())
        view.bottomLabel.font = UIFont.ThemeFont.BodyBold
        return view
    }()
    
    /// 持仓量 English: /Position quantity
    lazy var holdingVolumeView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.setTopText("cp_order_text11".ex_localized() + " (" + "cp_overview_text9".ex_localized() + ")")
        view.contentAlignment = .left
        view.bottomLabel.font = UIFont.ThemeFont.BodyBold
        return view
    }()

    /// 预期强平价格 English: /Expected strong flat price
    lazy var flatPriceView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.showDashline = true
        view.ext_UseAutoLayout()
        view.contentAlignment = .right
        view.bottomLabel.font = UIFont.ThemeFont.HeadBold
        view.setTopText("cp_order_text9".ex_localized())
        view.clickMiddleBtnBlock = { [weak self] in
            let alert = EXCommonAlert()
            alert.configAlert(title: "cp_calculator_text4".ex_localized(), message: "cp_extra_text130".ex_localized(),bottomOnlyOneBtn: true) { _ in
                EXAlert.dismiss() 
            }
            EXAlert.showAlert(alertView: alert)
        }
        return view
    }()
    
    /// 保证金 English: /Margin
    lazy var depositView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.ext_UseAutoLayout()
        view.bottomLabel.font = UIFont.ThemeFont.BodyBold
        view.setTopText("cp_order_text12".ex_localized() + " (USDT)")
        return view
    }()
    
    /// 保证金率 English: /Margin ratio
    lazy var marginRateView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.showDashline = true
        view.contentAlignment = .right
        view.ext_UseAutoLayout()
        view.setTopText("cp_extra_text135".ex_localized())
        view.bottomLabel.font = UIFont.ThemeFont.BodyBold
        view.clickMiddleBtnBlock = { [weak self] in
            guard let model = self?.positionModel else {
                return
            }
            let msg =  "cp_extra_text129".ex_localized()
            let alert = EXCommonAlert()
            alert.configAlert(title: "cp_extra_text135".ex_localized(), message: msg,bottomOnlyOneBtn: true) { _ in
                EXAlert.dismiss()
            }
            EXAlert.showAlert(alertView: alert)
            
        }
        return view
    }()
    
    /// 横线 English: /Horizontal line
    lazy var horLineView: UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    /// 调整保证金 English: /Adjust margin
    lazy var adjustDepositButton: EXButton = {
        let button = EXButton(buttonType: .custom, title: "cp_order_text16".ex_localized(), titleFont: UIFont.ThemeFont.SecondaryBold, titleColor: UIColor.ThemeLabel.colorLite)
        button.ext_SetAddTarget(self, #selector(clickAdjustDepositButton))
        button.selectStyle = .defultColorBlueLine
        return button
    }()
    
    /// 止盈止损 English: /Stop profit and stop loss
    lazy var stopProfitOrLossButton: EXButton = {
        let button = EXButton(buttonType: .custom, title: "cp_overview_text12".ex_localized(), titleFont: UIFont.ThemeFont.SecondaryBold, titleColor: UIColor.ThemeLabel.colorLite)
        button.ext_SetAddTarget(self, #selector(clickStopProfitOrLossButton))
        button.selectStyle = .defultColorBlueLine
        return button
    }()
    lazy var speedClosePositionBtn: RepeatButton = {
        let button = RepeatButton(buttonType: .custom, title: "cp_order_text18".ex_localized(), titleFont: UIFont.ThemeFont.SecondaryBold, titleColor: UIColor.ThemeLabel.colorLite)
        button.ext_UseAutoLayout()
        button.ext_SetAddTarget(self, #selector(clickSpeedCloseBtn))
        button.backgroundColor = UIColor.ThemeView.card2
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    /// 平仓 English: /Closing position
    lazy var closeContractButton: EXButton = {
        let button = EXButton(buttonType: .custom, title: "cp_overview_text2".ex_localized(), titleFont: UIFont.ThemeFont.SecondaryBold, titleColor: UIColor.ThemeLabel.colorLite)
        button.ext_UseAutoLayout()
        button.ext_SetAddTarget(self, #selector(clickCloseContractButton))
        button.selectStyle = .defultColorBlueLine
        return button
    }()
    
    /// 底部分隔视图 English: /Bottom Divided View
    lazy var bottomMarginView: UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeNav.bg
        return view
    }()
    
    lazy var btnContainer: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var warningLightView: EXWarninglightsView = {
        let v = EXWarninglightsView()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(adlClick))
        v.addGestureRecognizer(tap)
        v.isUserInteractionEnabled = true
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        self.backgroundColor = UIColor.ThemeView.card1
        self.contentView.backgroundColor = UIColor.ThemeView.card1
        self.contentView.exs_addSubViews([marginLine1, dealTypeLabel, nameLabel, contractTypeLabel,warningLightView,shareButton, openAverageView, PLNView, PLNRate, dottedLineView, targetPriceView, holdingVolumeView, flatPriceView, depositView, marginRateView, horLineView,bottomMarginView])
        self.addSubview(btnContainer)
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    
    标记价格-总持仓 English: Mark Price - Total Position
    保证金 English: Margin
    总持仓     - 保证金率 English: Total position - margin ratio
    已结算     - 开仓均价 English: Settled - average opening price
    保证金     - 标记价格 English: Margin - Mark Price
    可开仓位   -预计强平价格 English: Open positions - expected strong flat price

     
     
     */
    private func initLayout() {
        let horMargin = 15
        let verMargin = 12
        dealTypeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(22)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dealTypeLabel.snp.right).offset(5)
            make.height.equalTo(19)
            make.centerY.equalTo(dealTypeLabel)
        }
        contractTypeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(18)
            make.width.equalTo(35)
            make.centerY.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(4)
        }
        
        warningLightView.snp.makeConstraints { make in
            make.left.equalTo(contractTypeLabel.snp.right).offset(8)
            make.height.equalTo(8)
            make.width.equalTo(18)
            make.centerY.equalTo(dealTypeLabel)
        }
        shareButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.right.equalTo(-5)
            make.centerY.equalTo(dealTypeLabel)
        }
        /// 盈亏 English: /Profit and loss
        PLNView.snp.makeConstraints { (make) in
            
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(dealTypeLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        PLNRate.snp.makeConstraints { (make) in
            make.width.top.equalTo(PLNView)
            make.height.equalTo(40)
            make.right.equalToSuperview().offset(-15)
            make.left.equalTo(PLNView.snp.right)
        }

        dottedLineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(0.5)
            make.top.equalTo(PLNView.snp.bottom).offset(12)
        }
        //targetPriceView
        holdingVolumeView.snp.makeConstraints { (make) in
            make.height.equalTo(36)
            make.left.equalTo(PLNView)
            make.top.equalTo(dottedLineView.snp.bottom).offset(12)
        }
        //保证金 English: Margin
        depositView.snp.makeConstraints { (make) in
            make.height.equalTo(holdingVolumeView)
            make.width.equalTo(holdingVolumeView)
            make.left.equalTo(holdingVolumeView.snp.right)
            make.top.equalTo(holdingVolumeView)
        }
        
        marginRateView.snp.makeConstraints { (make) in
            make.height.top.equalTo(depositView)
            make.width.equalTo(depositView)
            make.left.equalTo(depositView.snp.right)
            make.right.equalToSuperview().offset(-15)
        }
        openAverageView.snp.makeConstraints { (make) in
            make.height.width.left.equalTo(holdingVolumeView)
            make.top.equalTo(holdingVolumeView.snp.bottom).offset(verMargin)
        }
        targetPriceView.snp.makeConstraints { (make) in
            make.height.equalTo(depositView)
            make.width.equalTo(depositView)
            make.left.equalTo(openAverageView.snp.right)
            make.top.equalTo(depositView.snp.bottom).offset(verMargin)
        }
        
        flatPriceView.snp.makeConstraints { (make) in
            make.height.equalTo(marginRateView)
            make.width.equalTo(marginRateView)
            make.left.equalTo(targetPriceView.snp.right)
            make.top.equalTo(marginRateView.snp.bottom).offset(verMargin)
        }
       
        btnContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(30)
            make.top.equalTo(flatPriceView.snp.bottom).offset(16)
        }
        btnContainer.addArrangedSubviews([adjustDepositButton,stopProfitOrLossButton,closeContractButton,speedClosePositionBtn])

        horLineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
    }
}


// MARK: - Click Events
extension EXSwapPositionCell {
    
    @objc func adlClick() {
        let alert = EXCommonAlert()
        alert.configAlert(title: "cp_adl_title".ex_localized(),message: "cp_adl_content".ex_localized(),onlyOneBtnTitle:"cp_extra_text28".ex_localized(),bottomOnlyOneBtn: true ) { _ in
            
        }
        EXAlert.showAlert(alertView: alert)
    }
    
    /// 点击调整保证金 English: /Click to adjust margin
    @objc func clickAdjustDepositButton() {
        guard let model = self.positionModel else {
            return
        }
        let pm = model
        let sheet = EXChangeMarginAmountSheet(frame: CGRect(x: 0, y: 0, width: EXSCREEN_WIDTH, height: 420))
        sheet.positionModel = pm
        sheet.clickAddButton()
        sheet.transferBtn.rx.tap.subscribe { (_) in
            EXAlert.dismiss()
            let coin = self.positionModel?.ex_contractInfo?.margin_coin ?? ""
            if let vc = self.superview?.exs_viewContainingController {
                
                EXSwapPlatformSDK.shared.transferOnClickedCallBack?(coin,vc)
            }
        }.disposed(by: self.exs_disposeBag)

        sheet.confimModelCallBack = {
            EXAlert.dismissEnd {
                EXAlert.showSuccess(msg:  "cp_content_text24".ex_localized())
            }
            self.needReloadCellBlock?()
        }
        EXAlert.showSheet(sheetView: sheet)


    }
    
    /// 点击止盈止损 English: /Click on stop profit and stop loss
    @objc func clickStopProfitOrLossButton() {
        
        guard let model = self.positionModel else {
            return
        }
        self.StopPLBlock?(model)
        self.willPushVcBlock?()

    }
    //闪电平仓 English: Lightning liquidation
    @objc func clickSpeedCloseBtn() {
        guard let model = self.positionModel else {
            return
        }
        self.SpeedCloseBlock?(model)

    }
    //MARK: 点击平仓 English: MARK: Click to close the position
    @objc func clickCloseContractButton() {
       
        guard let model = self.positionModel else {
            return
        }
        self.CloseBlock?(model)
    }

    
    func getSideDesc() -> String {
        
        var side = "cp_extra_text4".ex_localized()
        if positionModel!.side == .openMore {
            side = "cp_extra_text5".ex_localized()
        }
        return side
    }
    
    private func getDecimal(unit: String) -> Int {
        let arr = unit.components(separatedBy: ".")
        var count = 0
        if arr.count == 2 {
            count = arr.last?.count ?? 8
        }
        return count
    }
    
    /// 点击分享 public_icon_share English: /Click to share public_ Icon_ Share
    @objc func clickShareButton() {
        let alert = EXSShareSheet.createShareViewWithPosition(self.positionModel!)
        alert.alertCallback = { [weak self] (idx, image) in
            if idx == 2 {
                let activity = UIActivity()
                var activityItems : [Any] = []
                if image == nil {
                    return
                }
                activityItems.append(image!)
                let activities = [activity]
                let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
                activityController.excludedActivityTypes = [.copyToPasteboard,.assignToContact]
                activityController.modalPresentationStyle = .fullScreen
                let vc = self!.findController()
                vc?.present(activityController, animated: true) { () -> Void in
                }
                activityController.completionWithItemsHandler = {activityType, completed, returnedItems, activityError in
                    if activityError == nil , completed == true{
                    }else{
                        NSLog("失败")
                    }
                    EXSShareSheet.dismiss(v: alert)
                }
            } else if idx == 1 {
                if image != nil {
                    UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self?.saveImg(image:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
        alert.show()
        EXNewTracking.shared.track(event: .swapOwnShare, info: [:])
    }
    
    @objc func saveImg(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil{
            EXAlert.showFail(msg: "common_tip_saveImgFail".ex_localized())
            return
        }
        EXAlert.showSuccess(msg: "common_tip_saveImgSuccess".ex_localized())
    }

}

extension EXSwapPositionCell {
    
    func handleMarketCloseOrder(price:String,volume:String) {
        if self.positionModel == nil {
            return
        }
    }
    
    fileprivate func updateLayoutBy(_ model: EXSwapPositionModel) {
        
        if model.position_type == .allType {
            adjustDepositButton.isHidden = true
        }else {
            adjustDepositButton.isHidden = false
        }
    }
    
    func updateCell(model: EXSwapPositionModel) {
        if model.ex_contractInfo == nil {
            return
        }
        positionModel = model
        updateOne(model: model)
        updateTwo(model: model)
          
    }
    //这些是变的，价格类数据需要每次都刷 English: These are changes, price data needs to be refreshed every time
    func updateTwo(model: EXSwapPositionModel){
        PLNView.bottomLabel.setUpAndDownText(model.openRealizedAmount.toValuePrecision(withContract: model.instrument_id))
        PLNRate.bottomLabel.setUpAndDownText(model.returnRate.toPercentString(2))
        PLNRate.bottomLabel.set_TextColor(model.returnRate)
//        realizedAmountView.setBottomText(model.profitRealizedAmount.toValuePrecision(withContract: model.instrument_id))
        targetPriceView.setBottomText(model.index_px.toPricePrecision(withContractID: model.instrument_id))
        flatPriceView.setBottomText(handleflatPrice(flatprice: model.reducePrice,id: model.instrument_id))
        depositView.setBottomText(model.im.toValuePrecision(withContract: model.instrument_id) )
        marginRateView.setBottomText(model.marginRate.toPercentString(2))
        holdingVolumeView.setBottomText(model.curQtyVolume)
//        canCloseVolumeView.setBottomText(model.canCloseVolumeDisplay)
    }
    
    //这些是不变的，不需要每次都刷,一次就够 English: These are unchanged, you don't need to brush them every time, just one time is enough
    func updateOne(model: EXSwapPositionModel){
        let coin = model.ex_contractInfo?.margin_coin ?? ""
        updateLayoutBy(model)
//            titleLabel.text = model.ex_contractInfo?.margin_coin ?? "" + "cp_order_text1".ex_localized()
        var color = UIColor.ThemekLine.down
        if model.side == .openMore {
            color = UIColor.ThemekLine.up
        }
        //仓位方向 English: Position direction
        dealTypeLabel.textColor = color
        dealTypeLabel.text = model.side.introduce
        //bidui 名称- 全仓 English: Bidui Name - Full Warehouse
        nameLabel.text = model.ex_contractInfo?.showName() ?? ""
        contractTypeLabel.text = model.position_type.introduce + "\(model.leverageLevel)X"
        contractTypeLabel.titleResizeSize()
        //开仓均价 English: Average opening price
        openAverageView.setBottomText(model.avg_open_px.toPricePrecision(withContractID: model.instrument_id))
        //保证金 English: Margin
        depositView.setTopText(String(format:"%@(%@)","cp_order_text12".ex_localized(),coin ))
        //未实现盈亏 English: Unrealized gains and losses
        PLNView.setTopText(String(format:"%@(%@)","cl_roi_6".ex_localized(), coin))
        updateVolumeLabel(model: model)
        
//        self.warningLightView.isHidden = model.adlLevel == 0
//        if model.adlLevel > 0 {
            self.warningLightView.number = model.adlLevel
//        }
        
    }
    
    func updateVolumeLabel(model: EXSwapPositionModel) {
        holdingVolumeView.setTopText("cp_order_text11".ex_localized() + " (" + (model.ex_contractInfo?.volumeUnit ?? "") + ")")
//        canCloseVolumeView.setTopText("cp_order_text35".ex_localized() + " (" + (model.ex_contractInfo?.volumeUnit ?? "") + ")")
       
    }
    
    func handleflatPrice(flatprice:String,id:Int64) -> String {
        
        if flatprice == "--" {
            return "--"
        }
        
        if flatprice.greaterThan("100000000") {
            return "100000000";
        }
        if flatprice.lessThan("0") {
            return "--"
        }
        return flatprice.toPricePrecision(withContractID: id)
        
    }
    
}



