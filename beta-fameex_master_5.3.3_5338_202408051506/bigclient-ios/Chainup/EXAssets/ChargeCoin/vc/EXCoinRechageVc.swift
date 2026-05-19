//
//  EXCoinRechageVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXCoinRechageVc: BaseVC,StoryBoardLoadable,NavigationPlugin {
    
    @IBOutlet weak var linkNameBackViewTopCon: NSLayoutConstraint!
    @IBOutlet weak var linkNameBackViewHCon: NSLayoutConstraint!
    @IBOutlet weak var linkNameBackView: UIView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var addressStackContainer: UIStackView!
    @IBOutlet var addressView: EXQRAddressView!
    @IBOutlet var tagView: EXQRAddressView!
    @IBOutlet var coinSelector: EXCoinSelectorView!
    @IBOutlet var qrCodeView: EXQRCodeView!
    @IBOutlet var chargeScroll: UIScrollView!
    @IBOutlet var tipTitleLabel: UILabel!
    @IBOutlet var tipContentLabel: UILabel!
    @IBOutlet var tagHeight: NSLayoutConstraint!
    @IBOutlet var addressHeight: NSLayoutConstraint!
    @IBOutlet weak var tagTipsView: UIView!
    var currentBtn = EXTextButton.init(type:.custom)
   
    var symbol:String = ""
    var followCoinName = ""//From chain name
    var mainChainName = ""
    var backLastOne = false
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: chargeScroll, presenter: self)
        nav.isLastNavigationStyle = true
        return nav
    }()
    
    func handleNavigation() {
        self.navigation.setTitle(title: "assets_action_chargeCoin".localized())
       navigation.setdefaultType(type: .list)
        navigation.configRightItems(["charge_action_chargeHistory".localized()],isImageName: false)
        navigation.rightItemCallback = {[weak self] tag in
            self?.handleRechargeHistory()
        }
        
        navigation.customBack = true
        navigation.customBackCallback = {[weak self] in
            self?.handleBack()
        }
    }
    
    
    func handleBack() {
        
        if backLastOne{
            self.navigationController?.popViewController(animated: true)
            return
        }
        if let controllers = self.navigationController?.viewControllers {
            var isPoped = false
            for controller in controllers {
                if controller.isKind(of: EXAssetsVc.self) {
                    isPoped = true
                    self.navigationController?.popToViewController(controller, animated: true)
                }
            }
            if isPoped == false {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func handleRechargeHistory(){
        let chargeHistory = EXChargeHistoryVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        chargeHistory.historyScene = .deposit
        chargeHistory.symbol = self.symbol
        self.navigationController?.pushViewController(chargeHistory, animated: true)
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
    
    func configTips() {
        tipTitleLabel.font = .Ex.regular(14)
        tipTitleLabel.textColor = .Ex.text2
        tipTitleLabel.text = "charge_chargeAlert_title".localized()
//        tipContentLabel.text = "charge_tip_addressWarning".localized()
        tipContentLabel.text = "--"

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        handleNavigation()
        chargeScroll.alwaysBounceVertical = true
        tagView.isHidden = true
        tagTipsView.isHidden = true
        tagTipsView.backgroundColor = UIColor.ThemeView.bg
        configTips()
        coinSelector.coinName.text = self.symbol.aliasName()
        coinSelector.tapCallback = {[weak self] in
            self?.toCoinLists()
        }
        handleLinkName()
        
        qrCodeView.didTapedSaveImage = { [weak self] in
            guard let self = `self` else { return }
            if let image = self.view.screenShot() {
                UIImageWriteToSavedPhotosAlbum(image, self.qrCodeView, #selector(self.qrCodeView.saveImg(image:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = EXAuthenticManagerTool.kycRightPassed(right: .deposit)
    }
    
    
    func toCoinLists() {
        let searchVc = EXCoinSearchListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        searchVc.sourceType = .sourceForDeposit
        searchVc.onEntityCallback = {[weak self] model in
            self?.updateCoinEntity(model)
        }
        searchVc.sourceType = .sourceForDeposit
        self.navigationController?.pushViewController(searchVc, animated: true)
    }
    
    func updateCoinEntity(_ entity:CoinListEntity) {
        self.symbol = entity.name
        coinSelector.coinName.text = self.symbol.aliasName()
        self.handleLinkName()
    }
    
    func getChargeAddress() {
        let right = UserAuthInfo.shared.kycRight?.candeposit ?? true
        if right == false {
            return
        }
        self.handleError()
        appApi.rx.request(.getChargeAddress(symbol: self.followCoinName))
        .MJObjectMap(EXChargeAddressModel.self)
        .autoShowLoadingOnController(context: self)
        .subscribe{[weak self] event in
            switch event {
            case .success(let model):
                self?.handleAddress(model)
                break
            case .failure(_):
                self?.handleError()
                break
            }
        }.disposed(by: self.disposeBag)
    }
    
    func handleError() {
        qrCodeView.qrImage.image = nil
        addressView.addressLabel.text = ""
        tipTitleLabel.isHidden = true
        tipContentLabel.isHidden = true
    }
    
    func updateTagHeight(_ tag:String) {
        let height = tag.textSizeWithFont(UIFont.systemFont(ofSize: 14), width: SCREEN_WIDTH - 30).height + 74
        tagHeight.constant = max(height, 90)
    }
    
    func updateAddressHeight(_ address:String) {
        let height = address.textSizeWithFont(UIFont.systemFont(ofSize: 14), width: SCREEN_WIDTH - 30).height + 74
        addressHeight.constant = max(height, 90)
    }
    
    func handleAddress(_ model:EXChargeAddressModel) {
        if model.tagAddress.count > 0 {
            self.showTagAlert()
            tagView.addressLabel.text = model.tagAddress
            tagView.titleLabel.text = "charge_text_tagAddress".localized()
            tagView.setCopyBtnTitle(title: "charge_action_copyTag".localized())
            self.updateTagHeight(model.tagAddress)
            tagView.isHidden = false
            tagTipsView.isHidden = false
            tagView.showIcon()
        }else {
            tagView.isHidden = true
            tagTipsView.isHidden = true
        }
        
        
        addressView.addressLabel.text =  model.addressStr
        addressView.setCopyBtnTitle(title: "charge_action_copyAddress".localized())

        if model.addressStr.count > 0 {
            let qrIcon = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator", codeString: model.addressStr, size: CGSize(width: 140, height: 140), qrColor: UIColor.ThemeLabel.colorLite, bkColor: UIColor.ThemeView.bg)   
            qrCodeView.qrImage.image = qrIcon
            self.updateTagHeight(model.addressStr)
        }else {
            qrCodeView.qrImage.image = nil
            addressView.addressLabel.text =  "---"
        }
        
        if !model.depositConfirm.isEmpty {
            tipTitleLabel.isHidden = false
            tipContentLabel.isHidden = false
            tipContentLabel.attributedText = String.init(format: "recharge_warning_tips".localized(), tipContentCoinName(), model.depositConfirm).lineSpacingString(font: UIFont.Ex.regular(12), color: UIColor.Ex.text2, lineSpacing: 8, textAligment: .left)
        }
        else {
            tipTitleLabel.isHidden = true
            tipContentLabel.isHidden = true
        }
    }
    
    func tipContentCoinName() -> String {
        if mainChainName.isEmpty {
            return followCoinName
        }
        return mainChainName + "_" + followCoinName
    }
    
    func showTagAlert() {
        let normal = EXNormalAlert()
        normal.configSigleAlert(title: "common_text_tip".localized(), message: "charge_tip_tagWarning".localized())
        EXAlert.showAlert(alertView: normal)
    }
   
    func handleLinkName() {
        for item in self.linkNameBackView.subviews {
            item.removeFromSuperview()
        }
        let followCoinListArr = EXAppMarketManager.sharedInstance.getFollowCoinList(self.symbol,type: .recharge)
        if followCoinListArr.count > 0 {
            let followCoinListView = EXFollowCoinListView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 0), followCoinListArr:followCoinListArr,symbol: self.symbol)
            followCoinListView.selectCoinBlock = {[weak self] (item) in
                guard let mySelf = self else{return}
                mySelf.followCoinName = item.name
                mySelf.mainChainName = item.mainChainName.aliasName()
                mySelf.getChargeAddress()
            }
            self.followCoinName = followCoinListView.selectFollowCoinEntity.name
            self.mainChainName = followCoinListView.selectFollowCoinEntity.mainChainName.aliasName()
            self.getChargeAddress()
            self.linkNameBackView.addSubview(followCoinListView)
            self.linkNameBackViewHCon.constant = followCoinListView.height
            self.linkNameBackViewTopCon.constant = 20
        }else {
            self.linkNameBackViewTopCon.constant = 0
            self.linkNameBackViewHCon.constant = 0
            self.followCoinName = self.symbol
            getChargeAddress()
        }
       
    }
    
    

}

