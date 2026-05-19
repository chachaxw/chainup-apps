//
//  EXTaskSIgnMainView.swift
//  Chainup
//
//  Created by cwd on 2023/7/24.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXTaskSIgnMainView: UIView {
    var otcVm = EXOTCVm()
    
    var doSignCallBack: EXComVoidBlock?// ((EXSignShowInfo, Int) -> ())?
    var signModel : EXSignInInfo? {
        didSet{
            guard let signModel = signModel else { return }
            let title = String(format: "rewardCenter_text2".localized(), signModel.seriateSignInNum)
            let content = String(format: "rewardCenter_text3".localized(), EXAppConfigManager.sharedInstance.configVm.cfgModel.timeZone)
            let signEnable = isSignEnable(with: signModel)
            let btnTitle = signEnable ? "rewardCenter_text12".localized() : "rewardCenter_text11".localized()
            titleLabel.text = title
            contentLabel.text = content
          
            self.signBtn.setTitle(btnTitle, for: .normal)
            self.signBtn.isEnabled = signEnable
            self.signList.signListModel = signModel.getSignShowList()
            self.signBtn.textSizeFit()
            
            
        }
    }
    
    var signSuccessIndex: Int = -1 {
        didSet{
            if signSuccessIndex < 0 {
                return
            }
            if let list = self.signList.signListModel{
                let item = list[signSuccessIndex]
                item.hasSigned = true
                self.signList.signListModel = list
            }
            self.signBtn.isEnabled = false
            self.signBtn.setTitle("rewardCenter_text11".localized(), for: .normal)
            self.signBtn.textSizeFit()
        }
    }
    
    static func getViewHeight() -> CGFloat {
       
        let title = String(format: "rewardCenter_text2".localized(), "7")
        let content = String(format: "rewardCenter_text3".localized(),"8")
        var titleH = title.textSizeWithFont( .Ex.medium(18), width: SCREEN_WIDTH - 24 * 2).height
        titleH = max(titleH, 21)
        var  contentH = content.textSizeWithFont( .Ex.medium(10), width: 200).height
        contentH = max(contentH, 24)
        let total = 24 + titleH + 8 + contentH + 24 + EXTaskSIngDaylistView.itemHeight + 27 + 36 + 19
        return max(total, 237)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setSubView()
    }
    

    //MARK: UI
    func setSubView() {
        self.backgroundColor = .Ex.fill3
        self.corneradius = 4
        self.addSubViews([titleLabel,contentLabel,signList,signBtn])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(21)
            make.width.lessThanOrEqualTo(SCREEN_WIDTH - 24 * 2)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
        }
        let w = EXTaskSIngDaylistView.getSize().width
        signList.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(24)
//            make.left.equalToSuperview().offset(16)
//            make.right.equalToSuperview().offset(-16)
            make.centerX.equalToSuperview()
            make.width.equalTo(w)
            make.height.equalTo(EXTaskSIngDaylistView.itemHeight)
        }
        signBtn.snp.makeConstraints { make in
            make.top.equalTo(signList.snp.bottom).offset(27)
            make.centerX.equalToSuperview()
            make.width.equalTo(124)
            make.height.equalTo(36)
        }
    }
    
    
    //MARK: lazy
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(18), textColor: .Ex.text1, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    lazy var contentLabel: UILabel = {
        let label = UILabel(text:"", font:.Ex.medium(10), textColor: .Ex.text3, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var signList: EXTaskSIngDaylistView = {
        let v = EXTaskSIngDaylistView()
        return v
    }()
    
    lazy var signBtn: EXButton = {
       let b = EXButton()
        b.selectStyle = .blueColor
        b.setFont(.Ex.medium(14))
        b.addTarget(self, action: #selector(doSign), for: .touchUpInside)
       return b
    }()
}
extension EXTaskSIgnMainView{
 
    func passed() -> Bool{
        var isAllPass = true
        var array = [SafetyTypes]()
        if self.signModel?.isKyc == 1 {
            array.append(.reaName)
            if UserInfoEntity.sharedInstance().authLevel != "1" {
               isAllPass = false
            }
        }
        if self.signModel?.isTwoCheck == 1 {
            array.append(.bindGoogle)
            if UserInfoEntity.sharedInstance().googleStatus != "1" {
                isAllPass = false
            }
        }
        if (isAllPass) {
            return isAllPass
        }
        otcVm.taskSign(self.yy_viewController ?? UIViewController(), types: array)
        return isAllPass
    }
}

extension EXTaskSIgnMainView{
    @objc func doSign(){
        if XUserDefault.getToken() == nil{
            BusinessTools.modalLoginVC()
            return
        }
        if passed() == false {
            return
        }
        self.doSignCallBack?()
    }
    
    func isSignEnable(with signModel:EXSignInInfo) -> Bool {
        if XUserDefault.getToken() == nil{
            return true
        }
       return signModel.isSignIn == "0"
    }
}

