//
//  EXMEInfoView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXMEInfoView: UIView {

    
    var item: EXCurrentAuthResult? {
        didSet{
            authenticationImgV.item = item
        }
    }
    //first line
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont().themeHNBoldFont(size: 22)
        label.isUserInteractionEnabled = false
        return label
    }()
    
   
    
   let bag = DisposeBag()
    
    ///Second row
    //uid
    lazy var uidLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont().themeHNFont(size: 14)
        return label
    }()
    lazy var copybtn: UIButton = {
        let btn = UIButton(buttonType: .custom, image:UIImage.themeImageNamed(imageName: "assets_copy"))
        btn.rx.tap
            .subscribe(onNext: { [weak self] in
                let past = UIPasteboard.general
                past.string = UserInfoEntity.sharedInstance().uid
                EXAlert.showSuccess(msg: "personal_Center_text2".localized())
            }).disposed(by:bag)
        return btn
    }()

    //Real name authentication
    lazy var authenticationImgV : AuthenticationView = {
        let imgV = AuthenticationView()
        imgV.extUseAutoLayout()
        imgV.extSetCornerRadius(8)
        imgV.layoutIfNeeded()
        return imgV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeNav.bg
        addSubViews([nameLabel,uidLabel,copybtn,authenticationImgV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(28)
            make.right.lessThanOrEqualToSuperview()
            make.top.equalToSuperview().offset(16)
        }
       
        uidLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(nameLabel.snp_bottom).offset(5)
            make.height.equalTo(18)
        }
        copybtn.snp.makeConstraints { make in
            make.left.equalTo(uidLabel.snp_right).offset(8)
            make.width.height.equalTo(15)
            make.centerY.equalTo(uidLabel)
        }
        authenticationImgV.snp.makeConstraints { (make) in
            make.height.equalTo(18)
            make.width.equalTo(30)
            make.left.equalTo(copybtn.snp_right).offset(8)
            make.centerY.equalTo(uidLabel)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapSelf))
        self.addGestureRecognizer(tap)
    }
    
    func reloadView(){
        if XUserDefault.getToken() == nil{//Not logged in
            nameLabel.text = LanguageTools.getString(key: "personal_Center_text1")
            uidLabel.isHidden = true
            copybtn.isHidden = true
            authenticationImgV.isHidden = true
            authenticationImgV.auth("2")
        }else{//Logged in
            nameLabel.text = UserInfoEntity.sharedInstance().nickName
            uidLabel.text = UserInfoEntity.sharedInstance().uid
            uidLabel.isHidden = false
            copybtn.isHidden = false
            authenticationImgV.isHidden = false
            authenticationImgV.auth(UserInfoEntity.sharedInstance().authLevel)
        }
        
    }
    
    @objc func tapSelf(){
        if XUserDefault.getToken() == nil{//Not logged in
            BusinessTools.modalLoginVC()
            return
        }
        let vc = EXMyInfoVC()
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AuthenticationView : UIView {
    
    var type = ""
    static let imageW: CGFloat = 10
    static let LRSpace: CGFloat = 6
    static let spaceBetween: CGFloat = 3
    
    
    static func getWidth(item: EXCurrentAuthResult?) -> CGFloat{
        let content = item?.showName ?? ""
        let textW = content.getTextWidth(font: 10)
        let total = imageW + spaceBetween + textW + LRSpace * 2
        return total
    }
    
    
    var item: EXCurrentAuthResult? {
        didSet{
            guard item != nil else {
                return
            }
            if item!.isPass {
                setView("personal_certified", name: item!.showName)
                self.extSetBorderWidth(1, color: UIColor.Ex.main1)
                self.label.textColor = UIColor.Ex.main1
            }else{
                setView("personal_notcertified", name: item!.showName)
                self.extSetBorderWidth(1, color: UIColor.Ex.text3)
                self.label.textColor = UIColor.Ex.text3
            }
            
            let toalW = AuthenticationView.getWidth(item: item!)
            
            self.snp.updateConstraints { make in
                make.width.equalTo(toalW)
            }
        }
    }
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        return imgV
    }()
    
    lazy var label : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.font = UIFont.ThemeFont.MinimumRegular
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([imgV,label])
        imgV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(AuthenticationView.LRSpace)
            make.height.equalTo(8)
            make.width.equalTo(AuthenticationView.imageW)
            make.centerY.equalToSuperview().offset(0.8)
        }
        label.snp.makeConstraints { (make) in
            make.left.equalTo(imgV.snp.right).offset(AuthenticationView.spaceBetween)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-AuthenticationView.LRSpace)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickV))
        self.addGestureRecognizer(tap)
    }
    
    func setView(_ imgStr : String , name : String){
        imgV.image = UIImage.themeImageNamed(imageName: imgStr)
        label.text = name
    }
    
    func auth(_ type : String){

    }
    
    //click
    @objc func clickV(){
        if XUserDefault.getToken() != nil{
            let kyc = EXIDAuthenticViewController()
            self.yy_viewController?.navigationController?.pushViewController(kyc, animated: true)
            return
//            let vv = EXJsApiMethodSwift()
//            vv.exchangeRouter("{\"routerName\":\"kyccomplete\"}") { (string, b) in
//
//            }
//            return
//            switch type {
//            case "0":
//                let vc = EXRealNameThreeVC()
//                EXAlert.showVc(controller: vc,ratio: 0.9)
////                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
//            case "1":
//                break
//            case "2" , "3":
//                let vc = EXRealNameCertificationChooseVC()
//                self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
//            default:
//                break
//            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


