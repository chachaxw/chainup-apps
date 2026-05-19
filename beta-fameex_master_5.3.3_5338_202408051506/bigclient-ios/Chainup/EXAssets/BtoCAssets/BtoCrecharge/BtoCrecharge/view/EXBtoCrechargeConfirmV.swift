//
//  EXBtoCrechargeConfirmV.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage

class EXBtoCrechargeConfirmV: UIView {
    
    typealias ClickBtnBlock = () -> ()
    var clickBtnBlock : ClickBtnBlock?
    
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadBold
        label.text = "b2c_text_rechargeConfirm".localized()
        return label
    }()
    
    lazy var messageLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeState.warning
        label.font = UIFont.ThemeFont.BodyRegular
        label.text = "b2c_text_rechargeNote".localized()
        label.numberOfLines = 0
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var leftOneLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "redpacket_payment_amount".localized()
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var rightOneLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "b2c_Transfer_Vouchers".localized()
        return label
    }()
    
    lazy var leftTwoLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    lazy var rightTwoImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        return imgV
    }()
    
    lazy var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.layoutIfNeeded()
        btn.setTitle("b2c_text_confirmRecharge".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.extSetAddTarget(self, #selector(clickBtn))
        return btn
    }()
    
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.layoutIfNeeded()
        btn.setTitle("common_text_btnCancel".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.extSetAddTarget(self, #selector(clickBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addSubViews([backView])
        backView.addSubViews([titleLabel,messageLabel,leftOneLabel,rightOneLabel,leftTwoLabel,rightTwoImgV,confirmBtn,cancelBtn])
        backView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(titleLabel.snp.top).offset(-20)
            make.bottom.equalTo(confirmBtn.snp.bottom).offset(20)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(22)
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        messageLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
        leftOneLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(messageLabel.snp.bottom).offset(21)
            make.height.equalTo(14)
        }
        rightOneLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(leftOneLabel.snp.bottom).offset(12)
            make.height.equalTo(14)
            make.right.equalTo(rightTwoImgV.snp.left).offset(-10)

        }
        leftTwoLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leftOneLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(16)
            make.centerY.equalTo(leftOneLabel)
        }
        rightTwoImgV.snp.makeConstraints { (make) in
            make.height.width.equalTo(80)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(rightOneLabel)
        }
        confirmBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
            make.top.equalTo(rightTwoImgV.snp.bottom).offset(21)
        }
        cancelBtn.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.centerY.equalTo(confirmBtn)
            make.right.equalTo(confirmBtn.snp.left).offset(-30)
        }
    }
    
    func setView(_ payNum : String ,payCredentials : String){
        leftTwoLabel.text = payNum
        if let url = URL.init(string: payCredentials){
            rightTwoImgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
        }
    }
    
    @objc func clickBtn(_ btn : UIButton){
        if btn == self.cancelBtn{
            self.removeFromSuperview()
        }else{
            self.clickBtnBlock?()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
