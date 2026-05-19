//
//  EXSShareSheet.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/1/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

public enum PingFangFaimly: String {
    case regular = "PingFangSC"
    case medium = "PingFangSC-Medium"
}

class EXSContractShareModel : NSObject{
    
    class func getShareStringAndImage(_ str : String) -> (String,String){
        var text = ""
        var imageName = ""
        
        //图片分 <50, >50% English: Image score<50,>50%
        if str.contains("-"){
            imageName = "contract_loss_1"
            if str.lessThan("-100"){
                text = "cp_str_lose_intro5".ex_localized()
                imageName = "contract_loss_2"
            }else if str.lessThan("-50"){
                text = "cp_str_lose_intro4".ex_localized()
                imageName = "contract_loss_2"
            }else if str.lessThan("-20"){
                text = "cp_str_lose_intro3".ex_localized()
            }else if str.lessThan("-5"){
                text = "cp_str_lose_intro2".ex_localized()
            }else{
                text = "cp_str_lose_intro1".ex_localized()
            }
        }else{
            imageName = "contract_profit_1"
            if str.greaterThan("100"){
                imageName = "contract_profit_2"
                text = "cp_str_win_intro5".ex_localized()
            }else if str.greaterThanOrEqual("50"){
                imageName = "contract_profit_2"
                text = "cp_str_win_intro4".ex_localized()
            }else if str.greaterThanOrEqual("20"){
                text = "cp_str_win_intro3".ex_localized()
            }else if str.greaterThanOrEqual("5"){
                text = "cp_str_win_intro2".ex_localized()
            }else{
                text = "cp_str_win_intro1".ex_localized()
            }
        }
        return (text,imageName)
    }
}
    
class EXSShareSheet: UIView {
    //
    typealias AlertCallback = (Int,UIImage?) -> ()
    var alertCallback : AlertCallback?
    
    var position : EXSwapPositionModel? {
        didSet {
            if position != nil {
                 updateShareSheetInfo(position!)
            }
        }
    }
    
    var shareV : EXSShareView = {
        let share = EXSShareView()
        share.clipsToBounds = false
        return share
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initLayout()
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismiss))
        self.addGestureRecognizer(tap)
    }
    
    @objc func dismiss(){
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        self.backgroundColor = UIColor.ThemeView.mask
        shareV.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubview(shareV)
        shareV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(320~)
            make.height.equalTo(357~)
        }

    }

    @objc func clickWechat(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            let image = self.shareV.asImage()//self.getShareImage()
            self.alertCallback?(2,image)
        }
       // EXSShareSheet.dismiss(v: self)
    }
    
//    func getShareImage() -> UIImage {
//        shareV.removeFromSuperview()
//        self.exs_addSubViews([shareV])
//        shareV.snp.makeConstraints { (make) in
//            make.left.right.bottom.top.equalToSuperview()
//        }
//        return shareV.asImage()
//    }
    func updateShareSheetInfo(_ position: EXSwapPositionModel) {
//验证逻辑的代码 English: Code for verifying logic
//        let temp = ["1%","5%","20%","30%","50%","90%","100%","120%"]
//        let temp2 = temp.map { return "-" + $0 }
//        let temp3 = temp + temp2
//        for item in temp3 {
//            let (showString,imageName) = EXContractShareModel.getShareStringAndImage(item.extStringSub(NSRange.init(location: 0, length: item.count - 1)))
//            //print("item = \(item), string=\(showString), image = \(imageName)")
//        }
        
        let r = position.returnRate.toPercentString(2)
        let (showString,_) = EXSContractShareModel.getShareStringAndImage(r.extStringSub(NSRange.init(location: 0, length: r.count - 1)))
        shareV.level.text = position.position_type.introduce + "\(position.leverageLevel)X  "
        let detailStr = showString
        
        
        shareV.defineLabel.text = detailStr  //String(format:"\"%@\"",detailStr)
        var rate = position.returnRate.toPercentString(2)
        var imageName = "public_loss"
        if position.returnRate.greaterThanOrEqual(BTZERO) {
            rate = "+" + rate
            imageName = "public_profit"
        } else {
            shareV.rateLabel.textColor = UIColor.ThemekLine.down
        }
        if position.side == .openEmpty { //开空 English: Open air
            shareV.directBtn.text = "cp_order_text15".ex_localized()
            shareV.directBtn.textColor = UIColor.ThemekLine.down
        }else{
            shareV.directBtn.textColor = UIColor.ThemekLine.up
        }
        shareV.bgView.image = UIImage.exs_themeImageNamed(imageName: imageName)
        shareV.rateLabel.text = rate
        shareV.swapName.text = position.ex_contractInfo?.symbol
        
        if let info = position.ex_contractInfo {
            
            shareV.nameLabel.text = info.contractShowType
        }
        shareV.fairLabel.text = "cp_order_text31".ex_localized()
        shareV.fairPrice.text = position.index_px.toPricePrecision(withContractID: position.instrument_id)

        shareV.openPrice.text = position.avg_open_px.toPricePrecision(withContractID:position.instrument_id)
    }
    // MARK:- interface

    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.clickWechat()
        }
    }
    static func dismiss(v: UIView) {
        for view in UIApplication.shared.keyWindow!.subviews {
            if view is EXSShareSheet {
                v.removeFromSuperview()
                break
            }
        }
    }
    
    static func createShareViewWithPosition(_ position : EXSwapPositionModel) -> EXSShareSheet {
        let alert = EXSShareSheet(frame: CGRect.init(x: 0, y: 0, width:EXSCREEN_WIDTH, height: EXS_SCREEN_HEIGHT))
        alert.position = position
        return alert
    }
}

class EXSShareView: UIView {
    
    let bgV: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    /// icon
    let iconView: UIImageView = {
        let icon = UIImageView(image: EXSwapPrivateConfig.shared.appIcon)
        icon.layer.cornerRadius = 2
        icon.layer.masksToBounds = true
        return icon
    }()
    /// timer
    let timeLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.MinimumRegular, textColor:  UIColor.white, alignment: .center)
        label.text = EXSDateTools.dateToString(Date(), dateFormat: "MM/dd HH:mm:ss")
        label.backgroundColor = UIColor.extColorWithHex("#0E3269")
        return label
    }()
    
    /// 自定义话术 English: /Custom Script
    let defineLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.SecondaryBold, textColor:  UIColor.ThemeLabel.colorHighlight, alignment: .left)
        return label
    }()
    
    let appNameLabel: UILabel = {
        let label = UILabel(text: EXSwapPrivateConfig.shared.appName, font: UIFont.ThemeFont.BodyBold, textColor:  UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    
    /// 背景图 English: /Background image
    let bgView: UIImageView = {
        let bgV = UIImageView()
        return bgV
    }()
    
    /// 背景图 English: /Background image
    let bottomView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.card2
        return v
    }()
    
    /// 收益率 English: /Yield
    let profitRate: UILabel = {
        let label = UILabel(text: "cp_calculator_text15".ex_localized(), font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
        return label
    }()
    
    /// 仓位方向 English: /Position direction
    let directBtn: UILabel = {
        let label = UILabel(text:"cp_order_text6".ex_localized(), font: UIFont.ThemeFont.SecondaryMedium, textColor:  UIColor.ThemekLine.up, alignment: .center)
        return label
        
    }()
    
    /// 收益率 English: /Yield
    let rateLabel: UILabel = {
        let label = UILabel(text: "--%", font: UIFont.ThemeFont.H1Medium, textColor:  UIColor.ThemekLine.up, alignment: .left)
        return label
    }()
    
    /// 合约名称 English: /Contract Name
    let nameLabel: UILabel = {
        let label = UILabel(text: "cp_overview_text35".ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor:  UIColor.ThemeLabel.colorMedium, alignment: .center)
        return label
    }()
    ///交易对 English: /Transaction pairs
    let swapName: UILabel = {
        let label = UILabel(text: "BTCUSDT", font: UIFont.ThemeFont.H3Medium, textColor:  UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    ///杠杆 English: /Levers
    let level: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.SecondaryBold, textColor:  UIColor.ThemeLabel.colorMedium, alignment: .left)
        return label
    }()
    
    /// 最新价格 English: /Latest prices
    let fairLabel: UILabel = {
        let label = UILabel(text: "cp_order_text31".ex_localized(), font: UIFont.ThemeFont.MinimumBold, textColor:  UIColor.ThemeLabel.colorMedium, alignment: .right)
        return label
    }()
    
    let fairPrice: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.BodyBold, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    
    /// 开仓价格 English: /Opening price
    let openLabel: UILabel = {
        let label = UILabel(text: "cp_order_text7".ex_localized(), font: UIFont.ThemeFont.MinimumBold, textColor:  UIColor.ThemeLabel.colorMedium, alignment: .left)
        return label
    }()
    
    let openPrice: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.BodyBold, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    
    let line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeLabel.colorMedium
        return v
    }()
    
    /// 二维码 English: /QR code
    let qrView: UIImageView = {
        let qrIcon = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator", codeString: EXSwapPrivateConfig.shared.sharePage, size: CGSize(width: 50, height: 50), qrColor: UIColor.ThemeLabel.colorLite, bkColor: UIColor.ThemeView.bg)
        let bgV = UIImageView(image: qrIcon)
        bgV.backgroundColor = UIColor.ThemeView.bg
        return bgV
    }()
    
    ///
    let qrTipsLabel: UILabel = {
        let label = UILabel(text: "cp_stoporder_text4".ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        superview?.layoutSubviews()
       
        timeLabel.exs_roundCorners(corners: [.bottomRight], radius: 5)
        self.exs_roundCorners(corners: .allCorners, radius: 12)
        
    }
    private func initLayout() {
        //底部的logo 二维码 English: The logo QR code at the bottom
        let imageBg = UIImageView()
        imageBg.contentMode = .scaleAspectFill
        imageBg.image = UIImage.exs_themeImageNamed(imageName: "public_share")
        bottomView.addSubview(imageBg)
        bottomView.layer.cornerRadius = 10
        bottomView.layer.masksToBounds = true
        imageBg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageBg.addSubViews([iconView,appNameLabel,qrTipsLabel,qrView])
        ///appicon
        iconView.snp.makeConstraints { (make) in
            make.width.equalTo(44)
            make.height.equalTo(44)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(19)
           
        }
        ///appname
        appNameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(17)
            make.left.equalTo(iconView.snp.right).offset(12)
            make.height.equalTo(18)
        }
        
        qrTipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(appNameLabel)
            make.top.equalTo(appNameLabel.snp.bottom).offset(4)
        }
        ///二维码 English: /QR code
        qrView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-19)
            make.width.equalTo(46)
            make.height.equalTo(46)
            make.centerY.equalToSuperview()
        }
        
        self.exs_addSubViews([
            bgView,
            swapName,
            directBtn,line,level,
            defineLabel,
            profitRate,
            rateLabel,
            openLabel,
            fairLabel,
            openPrice,
            fairPrice,
            bottomView
         ])
        //币对 English: Coin pairs
        swapName.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(37)
            make.height.equalTo(22)
        }
        
        directBtn.snp.makeConstraints { (make) in
            make.left.equalTo(swapName.snp.left)
            make.top.equalTo(swapName.snp.bottom).offset(4)
            make.height.equalTo(16)
        }
        line.snp.makeConstraints { (make) in
            make.left.equalTo(directBtn.snp.right).offset(10)
            make.centerY.height.equalTo(directBtn)
            make.width.equalTo(1)
        }
        
        level.snp.makeConstraints { make in
            make.left.equalTo(line.snp.right).offset(10)
            make.centerY.height.equalTo(directBtn)
        }
        
        //不输就是赢 English: Not losing is winning
        defineLabel.snp.makeConstraints { (make) in
            make.left.equalTo(swapName.snp.left)
            make.top.equalTo(directBtn.snp.bottom).offset(8)
            make.height.equalTo(16)
        }
        
        //收益率 English: Yield
        profitRate.snp.makeConstraints { (make) in
            make.top.equalTo(defineLabel.snp.bottom).offset(40)
            make.height.equalTo(18)
            make.left.equalToSuperview().offset(20)
           
        }
        //收益率数字 English: Yield figures
        rateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profitRate.snp.bottom).offset(4)
            make.left.equalTo(profitRate)
            make.height.equalTo(32)
        }
        
        
        bgView.snp.makeConstraints { (make) in
            make.width.equalTo(180-26)
            make.right.equalToSuperview().offset(-26)
            make.top.equalToSuperview().offset(28)
            make.bottom.equalToSuperview().offset(-76)
            
        }
//        bgView.addSubview(timeLabel)
//        timeLabel.snp.makeConstraints {  make in
//            make.left.top.equalToSuperview()
//            make.height.equalTo(19)
//            make.width.equalTo(82)
//        }
       

        ///开仓均价 English: /Average opening price
        openLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(17)
            make.top.equalTo(rateLabel.snp.bottom).offset(20)
            make.height.equalTo(14)
        }
        
        let x = (Device_W - 32 * 2) * 0.5
        ///最新价格 English: /Latest prices
        fairLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(x)
            make.top.equalTo(openLabel.snp.top)
            make.height.equalTo(14)
        }
       
        openPrice.snp.makeConstraints { (make) in
            make.top.equalTo(openLabel.snp.bottom).offset(4)
            make.left.equalTo(openLabel)
            make.height.equalTo(18)
        }
        fairPrice.snp.makeConstraints { (make) in
            make.top.equalTo(openPrice.snp.top)
            make.left.equalTo(fairLabel)
            make.height.equalTo(18)
           
        }
       
        bottomView.snp.makeConstraints { make in
            make.height.equalTo(76)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        self.backgroundColor = UIColor.ThemeView.bg
    }
}

