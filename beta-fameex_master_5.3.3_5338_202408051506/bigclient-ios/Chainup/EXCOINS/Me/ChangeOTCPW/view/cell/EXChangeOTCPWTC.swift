//
//  EXChangeOTCPWTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXChangeOTCPWTC: UITableViewCell {
    
    var entity = EXChangeOTCEntity()
    
    typealias TextfieldValueChangeBlock = () -> ()
    var textfieldValueChangeBlock : TextfieldValueChangeBlock?
    var forgetPwdCallBack: EXComVoidBlock?
    lazy var textField : EXTextField = {
        let text = EXTextField()
        text.extUseAutoLayout()
        text.enableTitleModel = true
        text.enablePrivacyModel = true
        text.textfieldValueChangeBlock = {[weak self] str in
            self?.entity.info = str
            self?.textfieldValueChangeBlock?()
        }
        return text
    }()
    
    lazy var forgetBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.isHidden = true
        btn.titleLabel?.font = UIFont.Ex.regular(12)
        btn.setTitleColor(.Ex.main1, for: .normal)
        btn.setTitle(LanguageTools.getString(key: "forgot_password"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(forgetPwd))
        return btn
    }()
    
    @objc func forgetPwd(){
        self.forgetPwdCallBack?()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([textField])
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(57)
            make.bottom.equalToSuperview()
        }
        
        textField.addSubview(forgetBtn)
        forgetBtn.snp.makeConstraints { make in
            make.right.equalToSuperview() //.offset(-16)
            make.width.equalTo(48)
            make.height.equalTo(14)
            make.centerY.equalTo(textField.titleLabel)
        }
        forgetBtn.textSizeFit(imageWidth: 0, space: 0)
    }
    
    func setCell(_ entity : EXChangeOTCEntity){
        forgetBtn.isHidden = !(entity.type == .old)
        textField.setTitle(title: entity.name)
        textField.setPlaceHolder(placeHolder: entity.placeHolder)
        textField.input.text = entity.info
        self.entity = entity
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
