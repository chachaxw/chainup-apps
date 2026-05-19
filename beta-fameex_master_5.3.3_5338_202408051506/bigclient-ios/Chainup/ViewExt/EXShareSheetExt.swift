//
//  EXShareSheet.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/1/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import Swap
class EXContractShareModel : NSObject{
    
    class func getDetailStr(_ str : String) -> String{
        var text = ""
        if str.contains("-"){
            if str.lessThan("-50"){
                text = "common_share_losePrompt100".ex_localized()
            }else if str.lessThan("-20"){
                text = "common_share_losePrompt50".ex_localized()
            }else if str.lessThan("-10"){
                text = "common_share_losePrompt20".ex_localized()
            }else if str.lessThan("-5"){
                text = "common_share_losePrompt10".ex_localized()
            }else{
                text = "common_share_losePrompt5".ex_localized()
            }
        }else{
            if str.greaterThan("50"){
                text = "common_share_winPrompt100".ex_localized()
            }else if str.greaterThan("20"){
                text = "common_share_winPrompt50".ex_localized()
            }else if str.greaterThan("10"){
                text = "common_share_winPrompt20".ex_localized()
            }else if str.greaterThan("5"){
                text = "common_share_winPrompt10".ex_localized()
            }else{
                text = "common_share_winPrompt5".ex_localized()
            }
        }
        return text
    }
    
}
class EXShareSheet: UIView {
    
    typealias AlertCallback = (Int,UIImage?) -> ()
    var alertCallback : AlertCallback?
    
    var position : EXSwapPositionModel? {
        didSet {
            if position != nil {
                 updateShareSheetInfo(position!)
            }
        }
    }
    
    var shareDialog: JSShareDialogModel? {
        didSet {
            if shareDialog != nil {
                updateShareSheetInfoWithShareDialog(shareDialog!)
            }
        }
    }
    
    lazy var shareBgView : UIView = {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 375, height: 667))
        return view
    }()
    
    lazy var copyLabel : UILabel = {
        let label = UILabel(text: "contract_final_right_interpretcopy".ex_localized(), font: UIFont.ThemeFont.BodyRegular, textColor:  UIColor.extColorWithHex("5D5E7C"), alignment: .center)
        return label
    }()
    
    let logoView: UIImageView = {
        let bgV = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "LOGO_share"))
        return bgV
    }()
    
    var shareV : EXShareView = {
        let share = EXShareView(frame: CGRect.init(x: 0, y: 0, width: 280, height: 500))
        share.clipsToBounds = false
        return share
    }()
    
    let saveBtn : UIButton = {

        let button = EXButton()
        button.setTitle("common_share_confirm".ex_localized(), for: .normal)
        button.ext_SetAddTarget(self, #selector(clickWechat))

        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initLayout()
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismiss))
        self.addGestureRecognizer(tap)
        
        
        saveBtn.extSetAddTarget(self, #selector(clickWechat))
    }
    
    @objc func dismiss(){
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        self.backgroundColor = UIColor.ThemeView.mask
        self.exs_addSubViews([shareV,saveBtn])
        shareV.snp.makeConstraints { (make) in
            make.width.equalTo(280)
            make.height.equalTo(500)
            make.centerX.equalTo(EXSCREEN_WIDTH * 0.5)
            make.top.equalTo((EXS_SCREEN_HEIGHT - 476 - 84) * 0.5)
        }
        saveBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.frame.width * 0.5)
            make.height.equalTo(44)
            make.width.equalTo(140)
            make.top.equalTo(shareV.snp.bottom).offset(40)
        }
    }
    
    @objc func clickCancel(_ btn : UIButton){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            self.alertCallback?(0,nil)
        }
        EXShareSheet.dismiss(v: self)
    }
    @objc func clickSave(_ btn : UIButton){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            let image = self.getShareImage()
            self.alertCallback?(1,image)
        }
        EXShareSheet.dismiss(v: self)
    }
    @objc func clickWechat(_ btn : UIButton){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            let image = self.getShareImage()
            self.alertCallback?(2,image)
        }
        EXShareSheet.dismiss(v: self)
    }
    
    func getShareImage() -> UIImage {
        shareV.removeFromSuperview()
        self.shareBgView.exs_addSubViews([shareV])
        shareV.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
        }
        shareV.updateLayout()
        shareV.setNeedsLayout()
        shareV.layoutIfNeeded()
        return shareV.asImage()
    }
    
    func updateShareSheetInfo(_ position: EXSwapPositionModel) {
//        let profit = position.unrealised_profit.bigDiv(position.im) ?? "0"
        let r = position.returnRate.toPercentString(2)
        let detailStr = EXContractShareModel.getDetailStr(r.ext_stringSub(NSRange.init(location: 0, length: r.count - 1)).bigMul("100"))
        shareV.defineLabel.text = String(format:"\"%@\"",detailStr)
        var rate = position.returnRate.toPercentString(2)
        if position.returnRate.greaterThanOrEqual(BTZERO) {
            rate = "+" + rate
        } else {
            shareV.rateLabel.textColor = UIColor.ThemekLine.down
        }
        if position.side == .openEmpty {
            shareV.directBtn.backgroundColor = UIColor.ThemekLine.down
            shareV.directBtn.setTitle("newContract_openShort".ex_localized(), for: .normal)
        }
        shareV.rateLabel.text = rate
        shareV.swapName.text = position.ex_contractInfo?.symbol
        
        if let info = position.ex_contractInfo {
            
            shareV.nameLabel.text = info.contractShowType
        }
        
        shareV.fairLabel.text = "newContract_text_fairPrice".ex_localized()
        shareV.fairPrice.text = position.index_px.toPricePrecision(withContractID: position.instrument_id)

        shareV.openPrice.text = position.avg_open_px.toPricePrecision(withContractID:position.instrument_id)
    }
    
    func updateShareSheetInfoWithShareDialog(_ shareDialog: JSShareDialogModel) {
        let r = shareDialog.rate
        let detailStr = EXContractShareModel.getDetailStr(r.extStringSub(NSRange.init(location: 0, length: r.count - 1)).bigMul("100"))
        shareV.defineLabel.text = String(format:"\"%@\"",detailStr)
        
        var rate = shareDialog.rate.formatAmountUseDecimal("2", holdZero: true) + "%"
        if shareDialog.rate.greaterThanOrEqual(BTZERO) {
            rate = "+" + rate
        } else {
            shareV.rateLabel.textColor = UIColor.ThemekLine.down
        }
        
        if shareDialog.side == "2" {
            shareV.directBtn.backgroundColor = UIColor.ThemekLine.down
            shareV.directBtn.setTitle("newContract_openShort".localized(), for: .normal)
        }
        
        shareV.openLabel.text = "contract_following_trader".localized()
        
        shareV.rateLabel.text = rate
        shareV.swapName.text = shareDialog.symbol
        shareV.nameLabel.text = "contract_perpetual_contract".localized()
        
        shareV.fairLabel.text = "contract_last_price".localized()
        shareV.fairPrice.text = shareDialog.avg_cost_px

        shareV.openPrice.text = shareDialog.kol_name
    }
    
    // MARK:- interface

    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    static func dismiss(v: UIView) {
        for view in UIApplication.shared.keyWindow!.subviews {
            if view is EXShareSheet {
                v.removeFromSuperview()
                break
            }
        }
    }
    
    static func createShareViewWithPosition(_ position : EXSwapPositionModel) -> EXShareSheet {
        let alert = EXShareSheet(frame: CGRect.init(x: 0, y: 0, width:EXSCREEN_WIDTH, height: EXS_SCREEN_HEIGHT))
        alert.position = position
        return alert
    }
    
    static func createShareViewWithShareDialog(_ shareDialog : JSShareDialogModel) -> EXShareSheet {
        let alert = EXShareSheet(frame: CGRect.init(x: 0, y: 0, width:SCREEN_WIDTH, height: SCREEN_HEIGHT))
        alert.shareDialog = shareDialog
        return alert
    }
}

class EXShareView: UIView {
    
    let bgV: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    /// icon
    let iconView: UIImageView = {
        let icon = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "AppIcon"))
        icon.layer.cornerRadius = 2
        icon.layer.masksToBounds = true
        return icon
    }()
    
    ///Custom Script
    let defineLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.H3Bold, textColor:  UIColor.ThemeLabel.colorLite, alignment: .center)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(text: EXSwapPlatformSDK.shared.appName, font: UIFont.systemFont(ofSize: 14, weight:.medium), textColor:  UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    
    ///Background image
    let bgView: UIImageView = {
        let bgV = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "contract_share_small"))
        return bgV
    }()
    
    ///Background image
    let bottomView: UIImageView = {
        let bgV = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "bg_moon"))
        return bgV
    }()
    
    ///Yield
    let profitRate: UILabel = {
        let label = UILabel(text: "contract_deposit_rate".ex_localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: .right)
        return label
    }()
    
    ///Position direction
    let directBtn: UIButton = {
        let btn = UIButton(buttonType: .custom, title: "newContract_openLong".ex_localized(), titleFont: UIFont.ThemeFont.MinimumRegular, titleColor: UIColor.ThemeLabel.white)
        btn.layer.cornerRadius = 1.5
        btn.layer.masksToBounds = true
        btn.isUserInteractionEnabled = false
        btn.backgroundColor = UIColor.ThemekLine.up
        return btn
    }()
    
    ///Yield
    let rateLabel: UILabel = {
        let label = UILabel(text: "--%", font: UIFont.ThemeFont.H1Bold, textColor:  UIColor.ThemekLine.up, alignment: .center)
        return label
    }()
    
    ///Contract Name
    let nameLabel: UILabel = {
        let label = UILabel(text: "contract_perpetual_contract".ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor:  UIColor.ThemeLabel.colorMedium, alignment: .center)
        return label
    }()
    
    let swapName: UILabel = {
        let label = UILabel(text: "BTCUSDT", font: UIFont.ThemeFont.SecondaryBold, textColor:  UIColor.ThemeLabel.colorLite, alignment: .center)
        return label
    }()
    
    let midLine1 : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    let midLine2 : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    ///Latest price
    let fairLabel: UILabel = {
        let label = UILabel(text: "contract_last_price".ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor:  UIColor.ThemeLabel.colorMedium, alignment: .center)
        return label
    }()
    
    let fairPrice: UILabel = {
        let label = UILabel(text: "5249.00", font: UIFont.ThemeFont.SecondaryBold, textColor:  UIColor.ThemeLabel.colorLite, alignment: .center)
        return label
    }()
    
    ///Opening price
    let openLabel: UILabel = {
        let label = UILabel(text: "contract_text_openAveragePrice".ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor:  UIColor.ThemeLabel.colorMedium, alignment: .center)
        return label
    }()
    
    let openPrice: UILabel = {
        let label = UILabel(text: "5230.00", font: UIFont.ThemeFont.SecondaryBold, textColor:  UIColor.ThemeLabel.colorLite, alignment: .center)
        return label
    }()
    
    let line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    ///QR code
    let qrView: UIImageView = {
        let qrIcon = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator", codeString: UserInfoEntity.sharedInstance().inviteUrl, size: CGSize(width: 50, height: 50), qrColor: UIColor.ThemeLabel.colorLite, bkColor: UIColor.ThemeView.bg)
        let bgV = UIImageView(image: qrIcon)
        bgV.backgroundColor = UIColor.ThemeView.bg
        return bgV
    }()
    
    ///Scan code prompt
    let qrTipsLabel: UILabel = {
        let label = UILabel(text: "common_share_detail".ex_localized(), font: UIFont.ThemeFont.MinimumRegular, textColor:  UIColor.ThemeLabel.colorMedium, alignment: .left)
        return label
    }()
    
    let qrTipsView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeView.mask
        let imageView = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "contract_share_arrow"))
        let label = UILabel(text: "contract_share_downloadtips".ex_localized(), font: UIFont.ThemeFont.MinimumRegular, textColor:  UIColor.ThemeLabel.white, alignment: .center)
        view.exs_addSubViews([imageView,label])
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(4)
            make.right.bottom.equalToSuperview().offset(-4)
            make.width.equalTo(12)
        }
        label.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(imageView.snp.left)
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        
        self.exs_addSubViews([
                          iconView,
                          bgView,
                          defineLabel,
                          titleLabel,
                          profitRate,
                          directBtn,
                          rateLabel,
                          nameLabel,
                          swapName,
                          midLine1,
                          fairLabel,
                          fairPrice,
                          midLine2,
                          openLabel,
                          openPrice,
                          line,
                          qrView,
                          qrTipsLabel,
                          qrTipsView])
        bgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(240)
        }
       
        defineLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(bgView.snp.bottom).offset(24)
            make.height.equalTo(20)
        }
        
        profitRate.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.top.equalTo(defineLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-self.frame.width * 0.5)
        }
        directBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(profitRate.snp.centerY)
            make.left.equalTo(profitRate.snp.right).offset(6)
            make.width.equalTo(30)
            make.height.equalTo(14)
        }
        rateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profitRate.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(30)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.top.equalTo(rateLabel.snp.bottom).offset(21)
            make.height.equalTo(14)
        }
        midLine1.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(0.5)
            make.centerY.equalTo(nameLabel.snp.bottom)
            make.centerX.equalTo(nameLabel.snp.right)
        }
        fairLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.top.equalTo(rateLabel.snp.bottom).offset(21)
            make.height.equalTo(14)
            make.width.equalTo(nameLabel.snp.width)
        }
        midLine2.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(0.5)
            make.centerY.equalTo(nameLabel.snp.bottom)
            make.centerX.equalTo(fairLabel.snp.right)
        }
        openLabel.snp.makeConstraints { (make) in
            make.left.equalTo(fairLabel.snp.right).offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(rateLabel.snp.bottom).offset(21)
            make.height.equalTo(14)
            make.width.equalTo(nameLabel.snp.width)
        }
        swapName.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.height.equalTo(14)
        }
        fairPrice.snp.makeConstraints { (make) in
            make.left.equalTo(swapName.snp.right).offset(5)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.height.equalTo(14)
            make.width.equalTo(swapName.snp.width)
        }
        openPrice.snp.makeConstraints { (make) in
            make.left.equalTo(fairPrice.snp.right).offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.height.equalTo(14)
            make.width.equalTo(swapName.snp.width)
        }
        line.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-80)
            make.height.equalTo(0.5)
        }
        qrView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        iconView.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(line.snp.bottom).offset(10)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-75)
            make.top.equalTo(iconView.snp.top)
            make.height.equalTo(15)
        }
        qrTipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-75)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(15)
        }
        qrTipsView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(100)
            make.height.equalTo(20)
            make.top.equalTo(iconView.snp.bottom).offset(10)
        }
        qrTipsView.layer.cornerRadius = 10
        qrTipsView.layer.masksToBounds = true
        self.backgroundColor = UIColor.ThemeView.bg
    }
    
    func updateLayout() {
        bgView.image = UIImage.exs_themeImageNamed(imageName: "contract_share_big")
        bgView.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(345)
        }
        profitRate.snp.remakeConstraints { (make) in
            make.height.equalTo(15)
             make.top.equalTo(defineLabel.snp.bottom).offset(26)
             make.left.equalToSuperview().offset(20)
             make.right.equalToSuperview().offset(-EXSCREEN_WIDTH * 0.5)
         }
         directBtn.snp.remakeConstraints { (make) in
             make.centerY.equalTo(profitRate.snp.centerY)
             make.left.equalTo(profitRate.snp.right).offset(6)
             make.width.equalTo(30)
             make.height.equalTo(15)
         }
         rateLabel.snp.remakeConstraints { (make) in
             make.top.equalTo(profitRate.snp.bottom).offset(4)
             make.left.equalToSuperview().offset(20)
             make.right.equalToSuperview().offset(-20)
             make.height.equalTo(30)
         }
         nameLabel.snp.remakeConstraints { (make) in
             make.left.equalToSuperview().offset(5)
             make.top.equalTo(rateLabel.snp.bottom).offset(35)
             make.height.equalTo(14)
         }
         fairLabel.snp.remakeConstraints { (make) in
             make.left.equalTo(nameLabel.snp.right).offset(5)
             make.top.equalTo(rateLabel.snp.bottom).offset(35)
             make.height.equalTo(14)
             make.width.equalTo(nameLabel.snp.width)
         }
         openLabel.snp.remakeConstraints { (make) in
             make.left.equalTo(fairLabel.snp.right).offset(5)
             make.right.equalToSuperview().offset(-5)
             make.top.equalTo(rateLabel.snp.bottom).offset(35)
             make.height.equalTo(14)
             make.width.equalTo(nameLabel.snp.width)
         }
         swapName.snp.remakeConstraints { (make) in
             make.left.equalToSuperview().offset(5)
             make.top.equalTo(nameLabel.snp.bottom).offset(5)
             make.height.equalTo(14)
         }
         fairPrice.snp.remakeConstraints { (make) in
             make.left.equalTo(swapName.snp.right).offset(5)
             make.top.equalTo(nameLabel.snp.bottom).offset(5)
             make.height.equalTo(14)
             make.width.equalTo(swapName.snp.width)
         }
         openPrice.snp.remakeConstraints { (make) in
             make.left.equalTo(fairPrice.snp.right).offset(5)
             make.right.equalToSuperview().offset(-5)
             make.top.equalTo(nameLabel.snp.bottom).offset(5)
             make.height.equalTo(14)
             make.width.equalTo(swapName.snp.width)
         }
         line.snp.remakeConstraints { (make) in
             make.left.equalToSuperview()
             make.right.equalToSuperview()
             make.bottom.equalToSuperview().offset(-120)
             make.height.equalTo(0.5)
         }
         qrView.snp.remakeConstraints { (make) in
             make.right.equalToSuperview().offset(-15)
             make.bottom.equalToSuperview().offset(-15)
             make.width.equalTo(90)
             make.height.equalTo(90)
         }
         iconView.snp.remakeConstraints { (make) in
             make.width.equalTo(40)
             make.height.equalTo(40)
             make.left.equalToSuperview().offset(20)
            make.top.equalTo(line.snp.bottom).offset(23)
         }
         titleLabel.snp.remakeConstraints { (make) in
             make.left.equalTo(iconView.snp.right).offset(10)
             make.right.equalToSuperview().offset(-65)
             make.top.equalTo(iconView.snp.top)
             make.height.equalTo(20)
         }
         qrTipsLabel.snp.remakeConstraints { (make) in
             make.left.equalTo(iconView.snp.right).offset(10)
             make.right.equalToSuperview().offset(-65)
             make.top.equalTo(titleLabel.snp.bottom)
             make.height.equalTo(20)
         }
        qrTipsView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(100)
            make.height.equalTo(23)
            make.top.equalTo(iconView.snp.bottom).offset(10)
        }
    }
}

