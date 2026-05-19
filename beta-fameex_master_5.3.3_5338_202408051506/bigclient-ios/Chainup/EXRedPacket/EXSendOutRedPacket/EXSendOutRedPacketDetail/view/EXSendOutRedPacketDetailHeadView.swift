//
//  EXSendOutRedPacketDetailHeadView.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXSendOutRedPacketDetailHeadType {
    case send//Send out details
    case received//Received details
}

class EXSendOutRedPacketDetailHeadView: UIView {
    
    var navtype = NavType.list
    {
        didSet{
            switch navtype {
            case .list:
//                titleLabel.snp.remakeConstraints { (make) in
//                    make.left.equalToSuperview().offset(15)
//                    make.height.equalTo(40)
//                    make.right.equalToSuperview().offset(-15)
//                    make.top.equalTo(popBackBtn.snp.bottom).offset(25)
//                }
//                titleLabel.font = UIFont.ThemeFont.H1Bold
//                titleLabel.textAlignment = .left
                break
            case .listtitle:
//                titleLabel.snp.remakeConstraints { (make) in
//                    make.left.equalTo(popBackBtn.snp.right).offset(15)
//                    make.height.equalTo(22)
//                    make.right.equalTo(shareBtn.snp.left).offset(-15)
//                    make.centerY.equalTo(popBackBtn)
//                }
//                titleLabel.font = UIFont.ThemeFont.HeadBold
//                titleLabel.textAlignment = .center
                break
            default:
                break
            }
        }
    }
    
    var backVheight = 167 * SCREEN_WIDTH / 375
    
//    lazy var popBackBtn : UIButton = {
//        let btn = UIButton()
//        btn.extUseAutoLayout()
//        btn.setImage(UIImage.themeImageNamed(imageName:"return").imageWithTintColor(color: UIColor.white), for: UIControl.State.normal)
//        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
//        btn.extSetAddTarget(self, #selector(clickPopBtn))
//        return btn
//    }()
//
//    lazy var titleLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.textColor = UIColor.white
//        label.font = UIFont.ThemeFont.H1Bold
//Label. text="Red envelope details". localized()
//        return label
//    }()
    
//    lazy var shareBtn : UIButton = {
//        let btn = UIButton()
//        btn.extUseAutoLayout()
//        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
//        btn.setImage(UIImage.themeImageNamed(imageName: "share"), for: UIControl.State.normal)
//        btn.extSetAddTarget(self, #selector(clickShareBtn))
//        return btn
//    }()

    lazy var headImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "headportrait1")
        return imgV
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .center
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var tipLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .center
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()

    lazy var redPacketDetailLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    lazy var topView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeRedPacket.normalRed
        return view
    }()
    
    lazy var backView : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "redbackground")
        return imgV
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([backView,headImgV,nameLabel,tipLabel,redPacketDetailLabel,lineV])
//        popBackBtn.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.top.equalToSuperview().offset(34 + NAV_TOP)
//            make.width.height.equalTo(16)
//        }
//        titleLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.height.equalTo(40)
//            make.right.equalToSuperview().offset(-15)
//            make.top.equalTo(popBackBtn.snp.bottom).offset(25)
//        }
//        shareBtn.snp.makeConstraints { (make) in
//            make.height.equalTo(17)
//            make.width.equalTo(18)
//            make.right.equalToSuperview().offset(-15)
//            make.centerY.equalTo(popBackBtn)
//        }
        headImgV.snp.makeConstraints { (make) in
            make.width.height.equalTo(80)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backView.snp.bottom)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(22)
            make.top.equalTo(headImgV.snp.bottom).offset(10)
        }
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(14)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
        redPacketDetailLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(14)
            make.bottom.equalTo(lineV.snp.top).offset(-15)
        }
        backView.snp.makeConstraints { (make) in
            make.height.equalTo(backVheight)
            make.width.equalTo(SCREEN_WIDTH)
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        lineV.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    //Click on the return button
    @objc func clickPopBtn(){
        self.yy_viewController?.popBack()
    }
    
//    //Click on the share button
//    @objc func clickShareBtn(){
//        let view = EXRedPacketDetailView()
//        view.show()
//    }
    
    func setView(_ entity : EXRedPacketDetailEntity){
        
        nameLabel.text = String.init(format: "redpacket_send_from".localized(), entity.nickName)
        
        tipLabel.text = entity.tip
        
        switch entity.status {
        case "1":
            redPacketDetailLabel.text = String.init(format: "redpacket_sendout_receive".localized(), entity.getCount,entity.count,entity.getAmount,entity.amount,entity.coinSymbol.aliasName())
        case "2":
            redPacketDetailLabel.text = String.init(format: "redpacket_sendout_goneDetail".localized(), entity.count,entity.amount,entity.coinSymbol.aliasName())
        case "3":
            redPacketDetailLabel.text = String.init(format: "redpacket_sendout_overdue".localized(), entity.getCount,entity.count,entity.getAmount,entity.amount,entity.coinSymbol.aliasName())
        default:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

