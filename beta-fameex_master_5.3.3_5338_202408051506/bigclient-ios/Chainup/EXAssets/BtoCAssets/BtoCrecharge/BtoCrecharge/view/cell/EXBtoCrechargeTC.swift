

//
//  EXBtoCrechargeTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage

import EXKit

class EXBtoCrechargeTC: UITableViewCell , MarkCheckable{
    
    var clickBtoCCellBlock : ClickBtoCCellBlock?
    
    typealias ClickImgVBtnBlock = () -> ()
    var clickImgVBtnBlock : ClickImgVBtnBlock?
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyBold
        return label
    }()
    
    lazy var chooseCoinLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "charge_action_selectCoin".localized()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textAlignment = .right
        return label
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = EXKitBundle.image(named: "public_positions_arrow_right")
        imgV.contentMode = .scaleAspectFit
        return imgV
    }()
    
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    lazy var onelineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadRegular
        return label
    }()
    
    lazy var depositBankV : EXBtoCrechargeAccountDetailView = {
        let view = EXBtoCrechargeAccountDetailView()
        view.extUseAutoLayout()
        view.setLeft("b2c_text_bank".localized())
        view.showNoCopy()
        return view
    }()
    
    lazy var depositBranchBankV : EXBtoCrechargeAccountDetailView = {
        let view = EXBtoCrechargeAccountDetailView()
        view.extUseAutoLayout()
        view.setLeft("otc_text_bankBranchName".localized())
        return view
    }()
    
    lazy var bankNumV : EXBtoCrechargeAccountDetailView = {
        let view = EXBtoCrechargeAccountDetailView()
        view.extUseAutoLayout()
        view.setLeft("b2c_text_bankNo".localized())
        return view
    }()
    
    lazy var receiverV : EXBtoCrechargeAccountDetailView = {
        let view = EXBtoCrechargeAccountDetailView()
        view.extUseAutoLayout()
        view.setLeft("otc_text_payee".localized())
        return view
    }()
    
    lazy var remarkV : EXBtoCrechargeAccountDetailView = {
        let view = EXBtoCrechargeAccountDetailView()
        view.extUseAutoLayout()
        view.setLeft("b2c_text_transferRemark".localized())
        view.setInstructionsStr("b2c_text_transferNote".localized())
        return view
    }()
    
    lazy var twolineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var rechargeTextField : EXTextField = {
        let textField = EXTextField()
        textField.extUseAutoLayout()
        textField.enableTitleModel = true
        textField.input.keyboardType = UIKeyboardType.decimalPad
        textField.setTitle(title: "b2c_text_rechargeAmount".localized())
        textField.setPlaceHolder(placeHolder: "b2c_text_inputRechargeAmount".localized())
        textField.maxLenth = 16
        return textField
    }()
    
    lazy var promptLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeState.warning
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var transferLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "b2c_Transfer_Vouchers".localized()
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var instructionsBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(UIImage.themeImageNamed(imageName: "assets_doubt"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickInstructionsBtn))
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    lazy var chooseImgBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(EXBundle.svgImage(named:"assets_addingpaymentmethod"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickChooseImgBtn))
        return btn
    }()
    
    internal lazy var checkMarkView : CheckMarkView = {
        let check =  CheckMarkView.init(style:.xMark, isChecked:true, presenter:self)
        return check
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([backView,onelineV,titleLabel,depositBankV,depositBranchBankV,bankNumV,receiverV,remarkV,twolineV,rechargeTextField,promptLabel,transferLabel,instructionsBtn,chooseImgBtn])
        chooseImgBtn.addSubViews([checkMarkView])
        backView.addSubViews([nameLabel,chooseCoinLabel,imgV])
        backView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(16)
            make.right.equalTo(chooseCoinLabel.snp.left).offset(-10)
        }
        chooseCoinLabel.snp.makeConstraints { (make) in
            make.right.equalTo(imgV.snp.left).offset(-1)
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(17)
        }
        imgV.snp.makeConstraints { (make) in
            make.height.width.equalTo(8.5)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(nameLabel)
        }
        onelineV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(backView.snp.bottom)
            make.height.equalTo(0.5)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(16)
            make.top.equalTo(onelineV.snp.bottom).offset(15)
        }
        depositBankV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
        }
        depositBranchBankV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
            make.top.equalTo(depositBankV.snp.bottom).offset(13)
        }
        bankNumV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
            make.top.equalTo(depositBranchBankV.snp.bottom).offset(13)
        }
        receiverV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
            make.top.equalTo(bankNumV.snp.bottom).offset(13)
        }
        remarkV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
            make.top.equalTo(receiverV.snp.bottom).offset(13)
        }
        twolineV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(remarkV.snp.bottom).offset(14)
        }
        rechargeTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(twolineV.snp.bottom).offset(15)
            make.height.equalTo(50)
        }
        promptLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(16)
            make.top.equalTo(rechargeTextField.snp.bottom).offset(10)
        }
        transferLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(14)
            make.top.equalTo(promptLabel.snp.bottom).offset(20)
        }
        instructionsBtn.snp.makeConstraints { (make) in
            make.left.equalTo(transferLabel.snp.right).offset(5)
            make.height.width.equalTo(12)
            make.centerY.equalTo(transferLabel)
        }
        chooseImgBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(80)
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(transferLabel.snp.bottom).offset(15)
        }
        checkMarkView.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.height.width.equalTo(30)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickChooseCoin))
        backView.addGestureRecognizer(tap)
    }
    
    //Click on the Select Image button
    @objc func clickChooseImgBtn(){
        if self.entity.imgUrl != ""{//Zoom in with images
            EXAlert.showPhotoBrowser(urls: [self.entity.imgUrl])
        }else{//No image added
            self.clickImgVBtnBlock?()
        }
    }
    
    var entity = EXBtoCrechargeModel()
    
    //set up
    func setCell(_ entity : EXBtoCrechargeModel){
        self.entity = entity
        nameLabel.text = entity.coinSymbol
        titleLabel.text = entity.coinSymbol + "b2c_text_rechargeAccount".localized()
        promptLabel.text = "b2c_text_singleNoLessthan".localized() + entity.depositMin + " \(entity.coinSymbol)"
        checkMarkView.isHidden = entity.imgUrl == ""
        if entity.imgUrl == ""{
            chooseImgBtn.setImage(EXBundle.svgImage(named:"assets_addingpaymentmethod"), for: UIControl.State.normal)
        }else{
            if let url = URL.init(string: entity.imgUrl){
                chooseImgBtn.yy_setImage(with: url, for: UIControl.State.normal, options: YYWebImageOptions.allowBackgroundTask)
            }
        }
    }
    
    //Set up a recharge account
    func setChargeAccount(_ model : EXCompanyBankInfoModel){
        depositBankV.setRight(model.bankName)
        depositBranchBankV.setRight(model.bankSub)
        bankNumV.setRight(model.bankNo)
        receiverV.setRight(model.name)
        remarkV.setRight(model.remark)
    }
    
    func setWithEntity(_ entity : B2CCoinMapItem){
        rechargeTextField.decimal = entity.showPrecision
    }
    
    //Click on the transfer voucher prompt button
    @objc func clickInstructionsBtn(){
        let view = EXNormalAlert()
        view.configSigleAlert(title: "", message: "b2c_text_transferPrompt".localized(), sigleBtnTitle: "alert_common_iknow".localized())
        EXAlert.showAlert(alertView: view)
    }
    
    typealias ClickCheckBlock = () -> ()
    var clickCheckBlock : ClickCheckBlock?
    
    func didTapped(isCheck: Bool) {
        checkMarkView.checked = true
        self.clickCheckBlock?()
//        self.entity.imgUrl = ""
//        (self.yy_viewController as? EXBtoCrechargeVC)?.mainView.tableView.reloadData()
    }
    
    @objc func clickChooseCoin(){
        clickBtoCCellBlock?()
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

class EXBtoCrechargeAccountDetailView : UIView{
    
    private var instructionsStr = ""
    
    lazy var leftLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var rightLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        label.textAlignment = .right
        return label
    }()
    
    //copy
    lazy var copyBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(UIImage.themeImageNamed(imageName: "trade_compared"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickCopyBtn))
        return btn
    }()
    
    //explain
    lazy var instructionsBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.isHidden = true
        btn.setImage(UIImage.themeImageNamed(imageName: "assets_doubt"), for: UIControl.State.normal)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.extSetAddTarget(self, #selector(clickInstructionBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([leftLabel,rightLabel,copyBtn,instructionsBtn])
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(14)
            make.centerY.equalToSuperview()
        }
        instructionsBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(12)
            make.centerY.equalTo(leftLabel)
            make.left.equalTo(leftLabel.snp.right).offset(5)
        }
        rightLabel.snp.makeConstraints { (make) in
            make.left.equalTo(instructionsBtn.snp.right).offset(5)
            make.right.equalTo(copyBtn.snp.left).offset(-5)
            make.height.equalTo(16)
            make.centerY.equalToSuperview()
        }
        copyBtn.snp.makeConstraints { (make) in
            make.height.equalTo(10)
            make.width.equalTo(9)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
    
    func setLeft(_ str : String){
        leftLabel.text = str
    }
    
    func setRight(_ str : String){
        rightLabel.text = str
    }
    
    //Do not display the copy button
    func showNoCopy(){
        copyBtn.isHidden = true
        rightLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(instructionsBtn.snp.right).offset(5)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(16)
            make.centerY.equalToSuperview()
        }
    }
    
    //Set the content displayed in the question mark
    func setInstructionsStr(_ str : String){
        instructionsBtn.isHidden = false
        instructionsStr = str
    }
    
    @objc func clickCopyBtn(){
        if rightLabel.text != ""{
            UIPasteboard.general.string = rightLabel.text
            EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
        }
    }
    
    @objc func clickInstructionBtn(){
        let view = EXNormalAlert()
        view.configSigleAlert(title: "", message:instructionsStr, sigleBtnTitle: "alert_common_iknow".localized())
        EXAlert.showAlert(alertView: view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

