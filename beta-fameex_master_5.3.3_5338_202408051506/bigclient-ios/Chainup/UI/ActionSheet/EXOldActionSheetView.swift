//
//  EXActionSheetView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

class EXOldActionSheetView: NibBaseView {
    
    let ButtonStyleHeight = 60
    let TextFieldStyleHeight = 87
    typealias ActionCallback = (Int) -> ()
    typealias ActionCallbackModel = (EXOldInputSheetModel) -> ()
    typealias formCallback = (Dictionary<String, String>) -> ()
    typealias CancelCallback = () -> ()
    typealias BtnCallback = (String) -> ()
    var errorTip = false
    var actionIdxCallback : ActionCallback?//Select type, index callback
    var actionFormCallback : formCallback?//Input type, form callback
    var actionCancelCallback : CancelCallback?//Cancel callback
    var itemBtnCallback : BtnCallback?//Cancel callback
    var selectedIdx:Int?
    private var models:[EXOldInputSheetModel] = []
    private var maxHeight = CONTENTVIEW_HEIGHT
    
    //new
    var newItemBtnCallback : ActionCallbackModel?
    var newResultCallBack: CancelCallback?
    
    @IBOutlet var actionTitle: UILabel!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var contentStacks: UIStackView!
    @IBOutlet var scrollContainer: UIScrollView!
    @IBOutlet var footerView: UIView!
    @IBOutlet var footerCancelBtn: EXButton!
    @IBOutlet var sheetTitleConstraint: NSLayoutConstraint!
    @IBOutlet var sheetFooterHeight: NSLayoutConstraint!
    @IBOutlet var seperator: UIView!
    
    private var inputSheetMode :Bool = false
    var autoDismiss:Bool = true
    var manualDismiss = false
    var onlybtn: Bool = true
    
    var itemModels = [EXOldInputSheetModel]()
    /*
     onlybtn //Button centered
     非onlybtn。//On the side copy, on the right ✅
    */
    func keyboardHeight() -> Observable<CGFloat> {
        return Observable
            .from([
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                    .map { notification -> CGFloat in
                        (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                },
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                    .map { _ -> CGFloat in
                        0
                }
                ])
            .merge()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    
    override func onCreate() {
        actionTitle.font = UIFont.ThemeFont.HeadBold
        actionTitle.textColor = UIColor.ThemeLabel.colorLite
        cancelBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        cancelBtn.setEnlargeEdgeWithTop(10, left: 20, bottom: 10, right: 20)
        footerCancelBtn.titleLabel?.font = UIFont.ThemeFont.HeadRegular
        self.inputSheetFooterStyle(inputStyle: false)
    }
    
    func inputSheetFooterStyle(inputStyle:Bool) {
        seperator.isHidden = inputStyle
        if inputStyle {
            sheetFooterHeight.constant = 104
            footerCancelBtn.setTitle("common_text_btnConfirm".localized(), for: .normal)
            footerCancelBtn.color = UIColor.ThemeView.highlight
            footerCancelBtn.setTitleColor(UIColor.white, for: .normal)
        }else {
            sheetFooterHeight.constant = 60
            footerCancelBtn.color = UIColor.clear
            footerCancelBtn.highlightedColor = UIColor.clear
            footerCancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
            footerCancelBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        }
    }
    
    func configTextfields(title: String?, itemModels: Array<EXOldInputSheetModel>) {
        if itemModels.count < 0 {
            return
        }
        self.itemModels = itemModels
        inputSheetMode = true
        self.inputSheetFooterStyle(inputStyle: true)
        if title != nil {
            actionTitle.text = title!
            cancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
        }else {
            sheetTitleConstraint.constant = 0
        }
        
        var index = 0
        var contentHeight:CGFloat = 0

        var inputsAry:[Observable<String>] = []
        for item in itemModels {
            let textinput = EXOldInputFieldsSheet.init()
            textinput.configItemModel(model: item)
            textinput.sheetTapCallback = {[weak self] key in
                self?.itemBtnCallback?(key)
                self?.newItemBtnCallback?(item)
            }
            contentStacks.addArrangedSubview(textinput)

            var textinputH: CGFloat = 52
            if item.title.count > 0 {
                textinputH += 22
            }
            if item.errorTipShow == true {
                textinputH += 22
            }
            textinput.snp.makeConstraints { (make) in
                make.height.equalTo(textinputH)
            }
            contentHeight += textinputH
            
            textinput.tag = index
            index = index + 1
            if let tf = textinput.rxField {
                inputsAry.append(tf.rx.text.orEmpty.asObservable())
                if item.maxInput > 0{ //Restrict input to maximum characters
                    tf.rx.text.orEmpty.asObservable()
                        .subscribe(onNext: { [weak tf]  str in
                            if str.count > 0 {
                                textinput.inputItem.baseLine.backgroundColor = UIColor.ThemeLabel.colorHighlight
                                textinput.errorTipLabel.isHidden = true
                            }
                            if str.count > item.maxInput {
                                let a = str.prefix(item.maxInput)
                                tf?.text = String(a)
                            }
                        }).disposed(by: self.disposeBag)
                }
            }
        }
        
        Observable.combineLatest(inputsAry).distinctUntilChanged()
            .map({ strary in
                var count = 0
                for (index,str) in strary.enumerated() {
                    let  it:EXOldInputSheetModel = itemModels[index]
                    //If the calibration standard is limited outside
                    if /*it.errorTip.count > 0 && */it.validbtnEnableBlock != nil{
                          let pass = it.validbtnEnableBlock!(str)
                        if pass {
                            count += 1
                        }
                    }else{
                        if str.count > 0 {
                            count += 1
                        }
                    }
                    
                }
                return (count == inputsAry.count)
            })
            .bind(to:footerCancelBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
    
        let totalHeight = contentHeight + sheetFooterHeight.constant + sheetTitleConstraint.constant + CGFloat(itemModels.count - 1) * 10 + (isiPhoneX ? 34 : 0 )
        
        if totalHeight >= maxHeight {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(maxHeight)
            }
        }else{
            self.snp.updateConstraints { (make) in
                make.height.equalTo(totalHeight)
            }
        }
    }
    //Automatically send text messages
    func autoSendMsg(){
        for item in contentStacks.subviews {
            if let v = item as? EXOldInputFieldsSheet{
                v.autoSendMeg()
            }
        }
    }
    
    func updateInputErrorTip(){
        var contentHeight: CGFloat = 0
        for (index,itemModel) in itemModels.enumerated() {
            
            
            var textinputH: CGFloat = 52
            if itemModel.title.count > 0 {
                textinputH += 22
            }
            if itemModel.errorTipShow == true {
                textinputH += 22
            }
            
            contentHeight += textinputH
            if let input = contentStacks.arrangedSubviews[index] as? EXOldInputFieldsSheet{
                input.updateError(model: itemModel)
                input.snp.updateConstraints { make in
                    make.height.equalTo(textinputH)
                }
            }
        }
        
        let totalHeight = contentHeight + sheetFooterHeight.constant + sheetTitleConstraint.constant + CGFloat(itemModels.count - 1) * 10 + (isiPhoneX ? 34 : 0 )
        
        if totalHeight >= maxHeight {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(maxHeight)
            }
        }else{
            self.snp.updateConstraints { (make) in
                make.height.equalTo(totalHeight)
            }
        }
    }
  
    func configButtonTitles(buttons:Array<String>,selectedIdx:Int = -1) {
        self.configButtonTitles(title: nil, buttons: buttons,selectedIdx:selectedIdx)
    }
    
    func configButtonTitles(title: String?, buttons: Array<String>,selectedIdx:Int = -1) {
        if buttons.count == 0 {
            return
        }
//        onlybtn = false
        inputSheetMode = false
        if onlybtn == false {
            footerCancelBtn.isHidden = true
            seperator.isHidden = true
        }
        if title != nil {
            actionTitle.text = title!
            cancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
        }else {
            sheetTitleConstraint.constant = 0
        }
        
        var index = 0
        for btnTitle in buttons {
            let item = EXActionSheetButtonItem.init()
            item.onlyBtn = onlybtn
            if onlybtn{
                item.actionBtn.setTitle(btnTitle, for: .normal)
            }else{
                item.titleLabel.text = btnTitle
            }
            contentStacks.addArrangedSubview(item)
            item.actionBtn.tag = index
            item.actionBtn.addTarget(self, action: #selector(onClickAction(sender:)), for: UIControl.Event.touchUpInside)
            if selectedIdx >= 0, selectedIdx < buttons.count, selectedIdx == index{
                if onlybtn {
                    item.actionBtn.isSelected = true
                }else{
                    item.checkImg.isHidden = false
                }
            }else{
                item.checkImg.isHidden = true
                item.actionBtn.isSelected = false
            }
            if onlybtn {
                if item.actionBtn.isSelected == true{
                    item.actionBtn.titleLabel?.font = UIFont.ThemeFont.HeadMedium
                }else{
                    item.actionBtn.titleLabel?.font = UIFont.ThemeFont.HeadRegular
                }
            }
            index = index + 1
        }
        
        
        contentStacks.spacing = 0
        
        let contentHeight = CGFloat(buttons.count * ButtonStyleHeight)
        let totalHeight = contentHeight + sheetFooterHeight.constant + sheetTitleConstraint.constant + (isiPhoneX ? 34 : 0 )

        if totalHeight >= maxHeight {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(maxHeight)
            }
        }else{
            self.snp.updateConstraints { (make) in
                make.height.equalTo(totalHeight)
            }
        }
    }
    
    @objc func onClickAction(sender: UIButton) {
        if !manualDismiss {
            self.dismiss()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            self.actionIdxCallback?(sender.tag)
        }
    }
    func errorTipShowMsg(errmsg: String) {
        let color = /*suc ? UIColor.ThemeLabel.colorHighlight :*/ UIColor.ThemeState.fail
        if (contentStacks.arrangedSubviews.count > 0){
            if let textinput = contentStacks.arrangedSubviews[0] as? EXOldInputFieldsSheet{
                textinput.errorTipLabel.text = errmsg
                textinput.errorTipLabel.isHidden = false
                textinput.inputItem.baseLine.backgroundColor = color
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        if !manualDismiss {
            self.dismiss()
        }
        self.actionCancelCallback?()
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        if self.inputSheetMode {
            var allItems = [String:String]()
            for itemView in self.contentStacks.arrangedSubviews {
                if itemView.isKind(of: EXOldInputFieldsSheet.self) {
                    let field = itemView as! EXOldInputFieldsSheet
                    if let value = field.modelValue, let key = field.modelKey {
                        allItems.updateValue(value, forKey: key)
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                self.actionFormCallback?(allItems)
                self.newResultCallBack?()
            }
        }else {
            self.actionCancelCallback?()
        }
        if autoDismiss {
            self.dismiss()
        }
    }
    
    func dismiss(){
        EXAlert.dismiss()
    }
    
}

