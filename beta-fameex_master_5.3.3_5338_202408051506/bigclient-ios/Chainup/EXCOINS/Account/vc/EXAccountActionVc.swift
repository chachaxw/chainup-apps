//
//  EXAccountActionVc.swift
//  Chainup
//
//  Created by wangdong on 2023/9/17.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView
class EXAccountActionVc: UIViewController {
        
    var showSignup:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubVc()
        configUI()
        if showSignup{
            configDefaultRegister()
        }
    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if EXThemeManager.isNight() == true{
            return .lightContent
        }else{
            return .default
        }
    }
    
    lazy var segmentedDataSource: EKIndicatorSegmentDatasource = {
        let source = EKIndicatorSegmentDatasource()
        source.titles = ["",""]
        return source
    }()
    
    
    var vcData:[UIViewController] = []
    let navBar = EXAccountNavigationBar()
    let segmentedView = JXSegmentedView()
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    
    lazy var signInVc:EXAccountSignInVc = {
        return EXAccountSignInVc()
    }()
    
    lazy var signUpVc:EXAccountSignUpVc = {
        return EXAccountSignUpVc()
    }()
}


extension EXAccountActionVc{
    
    func configUI(){
        self.view.addSubview(navBar)
        self.view.addSubview(self.segmentedView)
        self.view.addSubview(self.listContainerView)
        self.listContainerView.scrollView.isScrollEnabled = false
        self.segmentedView.dataSource = segmentedDataSource
        self.segmentedView.backgroundColor = .clear
        segmentedView.listContainer = self.listContainerView
        navBar.setRightClose()
        navBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(GH_NavStatusBarHeight)
        }
        segmentedView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        listContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
    }
    
    func configSubVc(){
        self.view.backgroundColor = .Ex.fill2
        let signInTips = "login_action_register".localized().ex_toNSAttributedString(font: .Ex.medium(12), textColor: .Ex.main1).ex_setYYTapAction { [weak self] in
                guard let self = `self` else { return }
                //register
                self.startRegister()
        }
        
        let signUpTips = "register_tip_exsitUser".localized().ex_toNSAttributedString(font: .Ex.regular(12), textColor: .Ex.text1).append(" ")
        signUpTips.append("login_action_login".localized().ex_toNSAttributedString(font: .Ex.medium(12), textColor: .Ex.main1).ex_setYYTapAction { [weak self] in
                guard let self = `self` else { return }
                self.pageOne()
        })
        
        signInVc.tipsLabel.attributedText = signInTips
        signUpVc.tipsLabel.attributedText = signUpTips
        
    }
    
    
    func configRegister() {
        self.pageTwo()
        if EXHomeViewModel.appdCompanyID() == "1490" {
            self.webRegister()
        }else {
            self.startRegister()
        }
    }
    
    func configDefaultRegister(){
        self.segmentedView.defaultSelectedIndex = 1
        if EXHomeViewModel.appdCompanyID() == "1490" {
            self.webRegister()
        }else {
            self.startRegister()
        }
    }
    func webRegister() {
        //Centurioninvest 1490 merchant ID uses a special registration method for registration
        if let url = URL(string: "https://centurioninvest.com/en/register") {
            UIApplication.shared.open(url, options: [:],
                                                  completionHandler: {(success) in
                                                    print(success)
                        })
        }
    }
    func pageOne() {
        self.segmentedView.selectItemAt(index: 0)
    }
    
    func pageTwo() {
        self.segmentedView.selectItemAt(index: 1)
    }
    
    func startRegister() {
        ///Phase II
        if EXAppConfigManager.sharedInstance.getBlacklistedCountry().count > 0 {
            self.pageTwo()
            return
        }
        
        ///Phase I
        let eftLimit = XUserDefault.getVauleForKey(key: "eftLimitKey") as! String
    
        if EXAppConfigManager.sharedInstance.isOpenETFAreaLimit(), eftLimit != "NotLimit" {
            let normalAlert = EXNormalAlert()
            normalAlert.configAlert(title:"register_countryLimit_title".localized(), message: "register_countryLimit_content".localized(),passiveBtnTitle: "register_countryLimit_agree".localized(),positiveBtnTitle: "register_countryLimit_disagree".localized())
            
            normalAlert.alertCallback = {[weak self] idx in
                if idx == 0 {
                    ///Not within the restricted ETF area
                    self?.pageTwo()
                    XUserDefault.setValueForKey("NotLimit", key: "eftLimitKey")
                }else {
                    ///Belongs to restricted ETF area
                    self?.pageOne()
                }
            }
            EXAlert.showAlert(alertView: normalAlert)
        }else {
            self.pageTwo()
        }
 
    }
}
 



extension EXAccountActionVc: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return 2
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        
        if index == 0 {
            vcData.append(signInVc)
            return signInVc
            
        }else{
            vcData.append(signUpVc)
            return signUpVc
        }
    }
}


