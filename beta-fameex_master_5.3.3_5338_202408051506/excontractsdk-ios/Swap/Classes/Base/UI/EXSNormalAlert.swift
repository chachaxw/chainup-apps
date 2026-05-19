//
//  EXNormalAlert.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

import EXKit

public class EXSNormalAlert: EXSNibBaseView {
    /*
     stack  顶部距离父视图32 English: Stack top distance from parent view 32
     从上往下 English: From top to bottom
    
     标题 English: title
     内容 English: content
     按钮 English: button
     3个容器相联没有间隙 English: Three containers connected without gaps
     间距有各种内部控制 English: There are various internal controls for spacing
     */
    @IBOutlet weak var msgBottomConstant: NSLayoutConstraint!
    @IBOutlet weak var msgtopConstant: NSLayoutConstraint!
    @IBOutlet var titleView: UIView!
    @IBOutlet var messageView: UIView!
    @IBOutlet var btnView: UIView!
    @IBOutlet weak var container: UIStackView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet weak var msgLabel: UITextView!
    @IBOutlet var passiveBtn: EXSButton!
    @IBOutlet var positiveBtn: EXSButton!
    @IBOutlet weak var marginView: UIView!
    @IBOutlet var btnHeight: NSLayoutConstraint!
    typealias AlertCallback = (Int) -> ()
    var alertCallback : AlertCallback?
    
    @IBOutlet weak var btnContainer: UIStackView!
    public override func layoutSubviews() {
        super.layoutSubviews()
        exs_roundCorners(corners: [.allCorners], radius: 12)
    }
    
    public override func onCreate() {
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.container.backgroundColor = UIColor.ThemeView.alertBg
        self.titleView.backgroundColor = UIColor.ThemeView.alertBg
        self.messageView.backgroundColor = UIColor.ThemeView.alertBg
        self.btnContainer.backgroundColor = UIColor.ThemeView.alertBg
        marginView.backgroundColor = UIColor.ThemeView.alertBg
        btnView.backgroundColor = UIColor.ThemeView.alertBg
        titleLabel.headBold()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        msgLabel.textColor = UIColor.ThemeLabel.colorMedium
        msgLabel.isScrollEnabled = false
        msgLabel.backgroundColor = UIColor.ThemeView.alertBg
        msgLabel.isEditable = false
        msgLabel.isSelectable = false
        passiveBtn.clearColors()
        positiveBtn.clearColors()
        passiveBtn.layer.borderWidth = 0.5
        passiveBtn.layer.borderColor = UIColor.ThemeLabel.colorHighlight.cgColor
        passiveBtn.layer.cornerRadius = 4
        passiveBtn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .normal)
        
        positiveBtn.backgroundColor = UIColor.ThemeLabel.colorHighlight
        positiveBtn.setTitleColor(.Ex.text4, for: .normal)
        positiveBtn.layer.cornerRadius = 4
        positiveBtn.layer.masksToBounds = true
       
    }
    
    public func configSigleAlert(title:String?,
                          message:String,
                          sigleBtnTitle:String = "cp_extra_text28".ex_localized(), lineHeight: CGFloat? = nil)
    {
        passiveBtn.isHidden = true
        if let altTitle = title,!altTitle.isEmpty {
            btnHeight.constant = 36
            titleLabel.text = altTitle
        }else {
            titleView.isHidden = true
            btnHeight.constant = 0
        }
        marginView.isHidden = true
        if lineHeight != nil {
            msgLabel.attributedText = message.exs_lineSpacingString(font: msgLabel.font!, color: msgLabel.textColor!, lineSpacing: lineHeight!, textAligment: .left)
        }
        else {
            msgLabel.text = message
        }
        self.msgtopConstant.constant = 0
        self.msgBottomConstant.constant = 32
        positiveBtn.setTitle(sigleBtnTitle, for: .normal)
    }
    
    func configAlert(title:String?,
                     message:String,
                     passiveBtnTitle:String = "cp_overview_text56".ex_localized(),
                     positiveBtnTitle:String="cp_calculator_text16".ex_localized())
    {
        if let altTitle = title,!altTitle.isEmpty {
            btnHeight.constant = 36
            titleLabel.text = altTitle
        }else {
            btnHeight.constant = 0
        }
        if message.isEmpty {
            messageView.isHidden = true
        }
        if passiveBtnTitle.isEmpty {
            passiveBtn.isHidden = true
            marginView.isHidden = true
        }
        msgLabel.text = message
        passiveBtn.setTitle(passiveBtnTitle, for: .normal)
        positiveBtn.setTitle(positiveBtnTitle, for: .normal)
    }
    
    func configAttributeAlert(title:String?,
                              message:NSAttributedString,
                              passiveBtnTitle:String = "cp_overview_text56".ex_localized(),
                              positiveBtnTitle:String="cp_calculator_text16".ex_localized())
    {
        if let altTitle = title,!altTitle.isEmpty {
            btnHeight.constant = 36
            titleLabel.text = altTitle
        }else {
            btnHeight.constant = 0
        }
        if message.string.isEmpty {
            messageView.isHidden = true
        }else{
            configMsgLabel(message: message)
        }
        msgLabel.attributedText = message
        passiveBtn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .normal)
        if passiveBtnTitle.isEmpty {
            passiveBtn.isHidden = true
            marginView.isHidden = true
        }
        
        passiveBtn.setTitle(passiveBtnTitle, for: .normal)
        positiveBtn.setTitle(positiveBtnTitle, for: .normal)
    }
    
    func configMsgLabel(message:NSAttributedString)  {
        let maxH = message.boundingRect(with:CGSize(width: Device_W - 80, height: Device_H), options: .usesLineFragmentOrigin, context: nil)
//        //print("maxH=\(maxH)")
        let hight = Device_H * 0.8 - (38 + 20 * 2 + 44 + 20)
//        //print("hight=\(hight)")
        if maxH.height > hight{
            self.msgLabel.snp_remakeConstraints { make in
                make.height.equalTo(hight)
            }
            self.msgLabel.showsVerticalScrollIndicator = false
            self.msgLabel.isScrollEnabled  = true
        }
    }
    
    @IBAction func positveAction(_ sender: EXSButton) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            self.alertCallback?(0)
        }
        EXAlert.dismiss()
    }
    
    @IBAction func passtiveAction(_ sender: EXSButton) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            self.alertCallback?(1)
        }
        EXAlert.dismiss()
    }
    
}


extension EXSNormalAlert{
    //历史委托强制减仓的弹框 English: Pop ups for mandatory reduction of positions through historical commissions
    public class func alertShow(model: EXContractOrderModel, detailType: EXSwapMarketOrderType){
        
        /// 强平明细 /// 显示合并明细 English: /Show merge details
        let title = "cp_extra_text80"
        let content = model.getNewliqPositionMsg()
        let alert = EXCommonAlert()
        alert.configAlert(title: title.ex_localized(), message: content, bottomOnlyOneBtn: true, alertCallBack: {_ in })
        EXAlert.showAlert(alertView: alert)
       
    }
}

class EXNormalNewAlert: EXView{
    typealias AlertCallback = (Int) -> ()
    var alertCallback : AlertCallback?
    
    static let titleTop: CGFloat = 22
    static let messageTop: CGFloat = 14
    static let bottomViewTop: CGFloat = 40
    static let bottomViewBottom: CGFloat = 20
    
    lazy var container: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = UIColor.ThemeView.alertBg
        view.distribution = .fill
        return view
    }()
    ///标题 English: /Title
    lazy var titleContainer = UIView()
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    ///内容 English: /Content
    lazy var contentContainer = UIView()
    lazy var contentLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    ///底部 English: /Bottom
    lazy var bottomContainer = UIView()
    //发送按钮 English: Send button
    lazy var cancelbtn : UIButton = {
        let btn = EXSButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.clearColors()
        btn.backgroundColor = UIColor.ThemeView.card2
        
        btn.setTitle("", for: .normal)
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for:.normal)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.ThemeBtn.highlight.cgColor
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.extSetAddTarget(self, #selector(cancel))
        return btn
    }()
    
    lazy var surebtn:UIButton = {
        let btn = EXSButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.backgroundColor = UIColor.ThemeView.bg
        btn.setTitleColor(UIColor.white, for:.normal)
        btn.setTitle("", for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.extSetAddTarget(self, #selector(sure))
        return btn
    }()
    
    override func setupView() {
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        container.addArrangedSubviews([titleContainer,contentContainer,bottomContainer])
        titleContainer.addSubview(titleLabel)
        contentContainer.addSubview(contentLabel)
        bottomContainer.addSubViews([cancelbtn,surebtn])
        
    }
    override func layoutSubviews(){
        roundCorners(corners: [.allCorners], radius: 12)
    }
    
    @objc func cancel(){
        EXAlert.dismiss()
    }
    
    @objc func sure(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.alertCallback?(0)
        }
        EXAlert.dismiss()
    }
    
    
    
    func configAlert(title:String?,
                     titleFont:UIFont? = UIFont.ThemeFont.HeadBold,
                     message:String?,
                     messageFont:UIFont? = UIFont.ThemeFont.BodyRegular,
                     messageAttributedStr: NSAttributedString? = nil,
                     cancelBtnTitle: String = "cp_overview_text56".ex_localized(),
                     sureBtnTitle: String = "cp_calculator_text16".ex_localized(),
                     titleTop: CGFloat = EXNormalNewAlert.titleTop,
                     messageTop: CGFloat = EXNormalNewAlert.messageTop,
                     bottomTop: CGFloat = EXNormalNewAlert.bottomViewTop,
                     bottomBottom: CGFloat = EXNormalNewAlert.bottomViewBottom)
    {
        
        titleLabel.text = title
        titleLabel.font = titleFont
        contentLabel.text = message
        contentLabel.font = messageFont
        if messageAttributedStr != nil {
            contentLabel.attributedText = messageAttributedStr
        }
        cancelbtn.setTitle(cancelBtnTitle, for: .normal)
        surebtn.setTitle(sureBtnTitle, for: .normal)
        self.layViews(titleTop: titleTop, messageTop: messageTop, bottomTop: bottomTop, bottomBottom: bottomBottom)
        
    }
    func layViews(titleTop: CGFloat,messageTop: CGFloat, bottomTop: CGFloat, bottomBottom: CGFloat){
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(titleTop)
            make.left.equalToSuperview().offset(21)
            make.right.equalToSuperview().offset(-21)
            make.bottom.equalToSuperview()
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(messageTop)
            make.left.equalToSuperview().offset(21)
            make.right.equalToSuperview().offset(-21)
            make.bottom.equalToSuperview()
        }
        surebtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(bottomTop)
            make.left.equalTo(cancelbtn.snp.right).offset(20)
            make.right.equalToSuperview().offset(-21)
            make.width.equalTo(cancelbtn.snp_width)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-bottomBottom)
        }
        cancelbtn.snp.makeConstraints { make in
            make.top.equalTo(surebtn)
            make.left.equalToSuperview().offset(21)
            make.height.equalTo(44)
        }
    }
}


