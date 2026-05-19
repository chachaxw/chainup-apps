//
//  EXAppealReasonView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXAppealReasonView: NibBaseView {
    @IBOutlet var stacks: UIStackView!
    @IBOutlet var inputReason: UIView!
    @IBOutlet var titleLabel: UILabel!
    var reasonViews:[EXAppealReasonItem] = []
    @IBOutlet var inputHeight: NSLayoutConstraint!
    @IBOutlet var inputTextView: EXExpandTextView!
    
    typealias ReasonExpandBlock = (Bool)->()
    var expandCallback:ReasonExpandBlock?
    typealias TextheightExpandBlock = (CGFloat)->()
    var textHeightCallback:TextheightExpandBlock?
    
    typealias ReasonDescBlock = (String,Int)->()
    var reasonDescCallback:ReasonDescBlock?
    
    typealias CustomReasonBlock = (String)->()
    var customReasonCallback:CustomReasonBlock?
    
    let MaxCharacterNumbers = 200
    
    override func onCreate() {
        inputHeight.constant = 0
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        titleLabel.font = UIFont.ThemeFont.HeadRegular
        
        let placeHolderAtt = NSMutableAttributedString().add(string: "appeal_tip_reasonOtherPlaceholder".localized(), attrDic: [NSAttributedString.Key.font :UIFont.ThemeFont.BodyRegular , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorDark])
        
        inputTextView.attributedPlaceholder = placeHolderAtt
        
        inputTextView.textColor = UIColor.ThemeLabel.colorMedium
        inputTextView.font = UIFont.ThemeFont.BodyRegular
        inputTextView.delegate = self
        
        inputTextView.rx.text.orEmpty.asObservable()
        .distinctUntilChanged()
        .subscribe(onNext:{[weak self] text in
            self?.customReasonCallback?(text)
        }).disposed(by: self.disposeBag)
    }
    
    func bindReason(reasons:[String],title:String) {
        titleLabel.text = title
        for (idx,reason) in reasons.enumerated() {
            let reasonView = EXAppealReasonItem()
            reasonView.setReason(reason: reason)
            reasonView.reasonCallback = {[weak self] selected in
                self?.reasonDidChange(idx: idx,isSelected: selected)
            }
            stacks.addArrangedSubview(reasonView)
            reasonViews.append(reasonView)
        }
    }
    
    func setDefaultReason(_ atIdx:Int) {
        for (idx,reasonView) in reasonViews.enumerated() {
            if idx == atIdx {
                reasonDescCallback?(reasonView.selectedDesc(),atIdx)
            }
            reasonView.setChecked(checked:(idx == atIdx))
        }
    }
    
    func reasonDidChange(idx:Int,isSelected:Bool) {
        for (itemIdx,itemView) in reasonViews.enumerated() {
            if itemIdx == idx {
                reasonDescCallback?(itemView.selectedDesc(),itemIdx)
                itemView.setChecked(checked: isSelected)
            }else {
                itemView.setChecked(checked: false)
            }
        }
        if idx == 2,isSelected == true {
            expandCallback?(true)
            //Gradually increase the entire View height
            inputHeight.constant = 44
        }else {
            expandCallback?(false)
            inputHeight.constant = 0
        }
    }
    
    func getHeight(expand:Bool,textHeight:CGFloat = 0) -> CGFloat {
        if expand {
            if textHeight == 0 {
                return 148 + 44
            }else {
                return 148 + 22 + textHeight
            }
        }else {
            return 148
        }
    }
}

extension EXAppealReasonView : EXExpandTextViewDelegate,UITextViewDelegate {
    
    func textViewDidChangeHeight(_ textView: EXExpandTextView, height: CGFloat) {
        textHeightCallback?(height)
        inputHeight.constant = 12 + height
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        let textString = textView.text
        if let inputStr = textString {
            if inputStr.count > MaxCharacterNumbers + 1 {
                textView.text = String(inputStr[inputStr.startIndex...inputStr.index(inputStr.startIndex, offsetBy: MaxCharacterNumbers)])
                return
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 200
    }
}



