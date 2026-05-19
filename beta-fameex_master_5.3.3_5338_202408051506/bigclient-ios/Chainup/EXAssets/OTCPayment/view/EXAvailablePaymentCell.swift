//
//  EXAvailablePaymentCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit
class EXAvailablePaymentCell: UITableViewCell {
    
    lazy var paymentIcon: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.clipsToBounds = true
        v.extSetCornerRadius(8)
        return v
    }()
    
    lazy var paymentName: UILabel = {
        let v = UILabel(font: .Ex.medium(16), textColor: .Ex.text1)
        return v
    }()
    
    lazy var userName: UILabel = {
        let v = UILabel(font: .Ex.medium(14), textColor: .Ex.text1)
        return v
    }()
    
    lazy var userAccount: UILabel = {
        let v = UILabel(font: .Ex.medium(14), textColor: .Ex.text1)
        return v
    }()
    
    lazy var activeCheckBox: EXCheckBox = {
        let v = EXCheckBox()
        return v
    }()
    
    lazy var editorBtn: EXButton = {
        let v = EXButton(type: .custom)
        v.selectStyle = .blueTextColor
        v.setTitle("b2c_text_edit".localized(), for: .normal)
        v.addTarget(self, action: #selector(editBtnClick), for: .touchUpInside)
        return v
    }()
    
    lazy var container: UIView = {
        let v = UIView()
        return v
    }()
    

    typealias ChangeActiveCallback = (Bool)->()
    var onChangeActiveCallback:ChangeActiveCallback?
    var paymentModel:EXOTCPaymentListModel = EXOTCPaymentListModel()
    var longCallBack: EXComIntBlock?
    typealias EditorPaymentCallback = (Int) -> ()
    var editorPaymentCallback : EditorPaymentCallback?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extSetCell(.clear, selStyle: .none, isRemoveSelectedBackgroundView: true)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func onCreate() {
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        }
        container.addSubViews([paymentIcon, paymentName, editorBtn, activeCheckBox,
                               userName, userAccount])
        
        paymentIcon.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(16)
            make.width.equalTo(16)
        }
        paymentName.snp.makeConstraints { make in
            make.centerY.equalTo(paymentIcon)
            make.left.equalTo(paymentIcon.snp.right).offset(8)
        }
        editorBtn.snp.makeConstraints { make in
            make.centerY.equalTo(paymentName)
            make.left.greaterThanOrEqualTo(paymentName.snp.right).offset(8)
        }
        activeCheckBox.snp.makeConstraints { make in
            make.left.equalTo(editorBtn.snp.right).offset(16)
            make.right.equalToSuperview()
        }
        paymentName.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        editorBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
        activeCheckBox.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        userName.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.top.equalTo(paymentIcon.snp.bottom).offset(12)
            make.height.equalTo(16)
        }
        userAccount.snp.makeConstraints { make in
            make.top.equalTo(userName.snp.bottom).offset(6)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(16)
        }
        
        
        activeCheckBox.checkCallback = {[weak self] checked in
            self?.convertActive(checked)
        }
        
        let long = UILongPressGestureRecognizer.init(target: self, action: #selector(longCelldelete))
        long.minimumPressDuration = 0.6
        self.contentView.addGestureRecognizer(long)
    }
    
    @objc func longCelldelete(){
        self.contentView.backgroundColor = UIColor.ThemeView.card2
        let v = EXPopMenuView.shared
        let  p = PopMenuItem()
        p.name = "address_action_delete".localized()
        v.pop(fromView: self,acionItem: [p]) {[weak self] item in
            guard let newSelf = self else{
                return
            }
            newSelf.longCallBack?(newSelf.tag)
        }
        v.dismissend = { [weak self] in
            self?.contentView.backgroundColor = UIColor.ThemeView.card1
        }
        return
        
    }
    
    func convertActive(_ checked:Bool) {
        onChangeActiveCallback?(checked)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindPaymentData(_ model:EXOTCPaymentListModel) {
        self.paymentModel = model
        var title = model.title
        if model.payment == OTCPayInfoType.UnionPay.rawValue {
            title = model.bankName
        }
        let icon = model.icon
        paymentIcon.yy_setImage(with: URL.init(string: icon), placeholder: nil)
        paymentName.text = title
        userName.text = model.userName
        if model.payment == OTCPayInfoType.WestUnio.rawValue {
            userAccount.text = model.remittanceInformation
        }else {
            userAccount.text = model.account
        }
        activeCheckBox.checked(check: model.isOpen == "1")
        activeCheckBox.text(content: model.isOpen == "1" ? "payMethod_text_active".localized() : "payMethod_text_inactive".localized())
    }
    
    @objc func editBtnClick(_ sender: UIButton) {
        editorPaymentCallback?(self.tag - 1000)
    }
    
}
