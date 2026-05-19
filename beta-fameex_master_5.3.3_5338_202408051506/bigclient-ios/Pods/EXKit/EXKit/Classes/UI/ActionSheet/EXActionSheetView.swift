//
//  EXActionSheetView.swift
//  Chainup
//
//  Created by liuxuan on 2020/3/8.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YYText
import SnapKit

public class EXActionSheetView: NibBaseView {
    
    let ButtonStyleHeight = 60
    let TextFieldStyleHeight = 87
    
    public typealias ActionCallback = (Int) -> ()
    public typealias formCallback = (Dictionary<String, String>) -> ()
    public typealias CancelCallback = () -> ()
    public typealias BtnCallback = (String,Bool,EXCountField) -> ()

    public var actionIdxCallback : ActionCallback?//选择类型,index回调
    public var actionFormCallback : formCallback?//输入类型,表单回调
    public var actionCancelCallback : CancelCallback?//取消回调
    public var itemBtnCallback : BtnCallback?//取消回调
    public var selectedIdx:Int?
    
    private var models:[EXInputSheetModel] = []
    private var maxHeight = CONTENT_H
    
    @IBOutlet weak var footerCancelButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var actionTitle: UILabel!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet public var contentStacks: UIStackView!
    @IBOutlet var scrollContainer: UIScrollView!
    @IBOutlet var footerView: UIView!
    @IBOutlet var footerCancelBtn: EXButton!
    @IBOutlet var sheetTitleConstraint: NSLayoutConstraint!
    @IBOutlet var sheetFooterHeight: NSLayoutConstraint!
    @IBOutlet var seperator: UIView!
    @IBOutlet public var hintMsgLabel: YYLabel!
    
    private var inputSheetMode :Bool = false
    public var autoDismiss:Bool = true
    public var manualDismiss = false
    
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    
    public override func onCreate() {
        self.backgroundColor = .Ex.fill6
        hintMsgLabel.backgroundColor = .clear
        hintMsgLabel.font = UIFont.ThemeFont.BodyRegular
        hintMsgLabel.numberOfLines = 0
        hintMsgLabel.preferredMaxLayoutWidth = Device_W - 32
        actionTitle.font = UIFont.ThemeFont.HeadBold
        cancelBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        cancelBtn.setEnlargeEdgeWithTop(10, left: 20, bottom: 10, right: 20)
        footerCancelBtn.titleLabel?.font = UIFont.ThemeFont.HeadRegular
        self.inputSheetFooterStyle(inputStyle: false)
    }
    
    func inputSheetFooterStyle(inputStyle:Bool) {
        seperator.isHidden = inputStyle
        if inputStyle {
            sheetFooterHeight.constant = 80
            footerCancelBtn.setTitle("common_text_btnConfirm".localized(), for: .normal)
            footerCancelBtn.color = UIColor.ThemeView.highlight
            footerCancelBtn.setTitleColor(.Ex.text4, for: .normal)
            footerCancelBtn.setTitleColor(.Ex.text2, for: .disabled)
            footerCancelBtn.setBackgroundColor(color: .Ex.fill3, forState: .disabled)
        }else {
            sheetFooterHeight.constant = 60
            footerCancelBtn.color = UIColor.clear
            footerCancelBtn.highlightedColor = UIColor.clear
            footerCancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
            footerCancelBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
            footerCancelBtn.setTitleColor(.Ex.text2, for: .disabled)
            footerCancelBtn.setBackgroundColor(color: .Ex.fill3, forState: .disabled)
        }
    }
    
    public func configTextfields(title: String?, itemModels: Array<EXInputSheetModel>,bottomMsg:String = "") {
        if itemModels.count < 0 {
            return
        }
        inputSheetMode = true
        self.inputSheetFooterStyle(inputStyle: true)
        self.footerCancelButtonTopConstraint.constant = 28
        if title != nil {
            actionTitle.text = title!
            cancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
        }else {
            sheetTitleConstraint.constant = 0
        }
        
        var index = 0
        var contentHeight:CGFloat = 0
        var bottomHeight:CGFloat = 0

        var inputsAry:[Observable<String>] = []
        for item in itemModels {
            let textinput = EXInputFieldsSheet.init()
            textinput.sheetTapCallback = {[weak self] (key,useVoice,sender) in
                self?.itemBtnCallback?(key,useVoice,sender)
            }
            /// 调整顺序,先设置才能在config的时候触发
            textinput.configItemModel(model: item)
            contentStacks.addArrangedSubview(textinput)

            if item.title.count > 0 {
                contentHeight += 54 + 20
                textinput.snp.makeConstraints { (make) in
                    make.height.equalTo(74)
                }
            }else {
                contentHeight += 32 + 20
                textinput.snp.makeConstraints { (make) in
                    make.height.equalTo(52)
                }
            }

            textinput.tag = index
            index = index + 1
            if let item = textinput.rxField {
                inputsAry.append(item.rx.text.orEmpty.asObservable())
            }
        }
        
        
        var footerHeight:CGFloat = 28 + 44 + 8
        if bottomMsg.count > 0 {
            //有底部文案,btn不居中
            if let text = hintMsgLabel.text, text == bottomMsg {
                bottomHeight = hintMsgLabel.intrinsicContentSize.height
            }else{
                bottomHeight =  YYTextCGFloatPixelCeil(bottomMsg.textSizeWithFont(UIFont.ThemeFont.BodyRegular, width: hintMsgLabel.preferredMaxLayoutWidth).height) + 10
            }
            footerHeight += 10 + bottomHeight
        }
        sheetFooterHeight.constant = footerHeight
        
        Observable.combineLatest(inputsAry).distinctUntilChanged()
            .map({ strary in
                var count = 0
                for str in strary {
                    if str.count > 0 {
                        count += 1
                    }
                }
                return (count == inputsAry.count)
            })
            .bind(to:footerCancelBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
    
        let totalHeight = contentHeight + sheetFooterHeight.constant + sheetTitleConstraint.constant + CGFloat(itemModels.count - 1) * 10 + (isiPhonexType() ? 34 : 0 )
        
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
    
    public func configButtonTitles(buttons:Array<String>,selectedIdx:Int = -1) {
        self.configButtonTitles(title: nil, buttons: buttons,selectedIdx:selectedIdx)
    }
    
    public func configButtonTitles(title: String?, buttons: Array<String>,selectedIdx:Int = -1) {
        if buttons.count == 0 {
            return
        }
        inputSheetMode = false
        if title != nil {
            actionTitle.text = title!
            cancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
        }else {
            sheetTitleConstraint.constant = 0
        }
        footerCancelBtn.titleLabel?.font = .ThemeFont.BodyMedium
//        footerCancelBtn.setTitleColor(.Ex.text2, for: .normal)
        footerCancelBtn.setTitleColor(.Ex.text2, for: .disabled)
        var index = 0
        let actionItemHeight:CGFloat = 50
        for btnTitle in buttons {
            let item = EXActionSheetButtonItem.init()
            item.actionBtn .setTitle(btnTitle, for: .normal)
            item.actionBtn.snp.updateConstraints { make in
                make.height.equalTo(actionItemHeight - 0.5)//参照xib里面减去线的高度
            }
            item.actionBtn.setBackgroundColor(color: .Ex.fill3, forState: [.highlighted, .selected])
            item.actionBtn.highlightedColor = .Ex.fill3
            item.actionBtn.setTitleColor(.Ex.text1, for: .highlighted)
            item.actionBtn.setTitleColor(.Ex.main1, for: [.highlighted, .selected])
            contentStacks.addArrangedSubview(item)
            item.actionBtn.tag = index
            item.actionBtn.addTarget(self, action: #selector(onClickAction(sender:)), for: UIControl.Event.touchUpInside)
            item.backgroundColor = UIColor.ThemeView.alertBg
            if selectedIdx >= 0, selectedIdx < buttons.count, selectedIdx == index{
                item.actionBtn.isSelected = true
            }
            index = index + 1
        }
        
        if let lastOne = contentStacks.arrangedSubviews.last as? EXActionSheetButtonItem {
            lastOne.lineView.isHidden = true
        }
        
        contentStacks.spacing = 0
        
        let contentHeight = CGFloat(buttons.count) * actionItemHeight
        let totalHeight = contentHeight + sheetFooterHeight.constant + sheetTitleConstraint.constant + (isiPhonexType() ? 34 : 0 )

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
    
    public func configIconBtns(title: String?, buttons: Array<EXSheetIconBtnModel>,selectedIdx:Int = -1) {
        if buttons.count == 0 {
            return
        }
        inputSheetMode = false
        if title != nil {
            actionTitle.text = title!
            cancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
        }else {
            sheetTitleConstraint.constant = 0
        }
        
        var index = 0
        for btnItem in buttons {
            let item = EXTitleIconSheetItem.init()
            item.titleLabel.text = btnItem.title
            item.titleIcon.yy_setImage(with: URL.init(string: btnItem.icon),placeholder: UIImage.themeImageNamed(imageName: "default_logo"))
            contentStacks.addArrangedSubview(item)
            item.snp.makeConstraints { make in
                make.height.equalTo(60)
            }

            item.tapBtn.tag = index
            item.tapBtn.addTarget(self, action: #selector(onClickAction(sender:)), for: UIControl.Event.touchUpInside)
            item.backgroundColor = UIColor.ThemeView.alertBg
            if selectedIdx >= 0, selectedIdx < buttons.count, selectedIdx == index{
                item.tapBtn.isSelected = true
            }
            index = index + 1
        }
        
        if let lastOne = contentStacks.arrangedSubviews.last as? EXTitleIconSheetItem {
            lastOne.lineView.isHidden = true
        }
        
        contentStacks.spacing = 0
        
        let contentHeight = CGFloat(buttons.count * ButtonStyleHeight)
        let totalHeight = contentHeight + sheetFooterHeight.constant + sheetTitleConstraint.constant + (isiPhonexType() ? 34 : 0 )

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
                if itemView.isKind(of: EXInputFieldsSheet.self) {
                    let field = itemView as! EXInputFieldsSheet
                    if let value = field.modelValue, let key = field.modelKey {
                        allItems .updateValue(value, forKey: key)
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                self.actionFormCallback?(allItems)
            }
        }else {
            self.actionCancelCallback?()
        }
        if autoDismiss {
            self.dismiss()
        }
    }
    
    public func dismiss(){
        EXKitAlert.dismiss()
    }
    
}
