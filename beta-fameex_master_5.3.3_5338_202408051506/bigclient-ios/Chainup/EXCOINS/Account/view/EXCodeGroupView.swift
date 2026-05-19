//
//  EXCodeGroupView.swift
//  Chainup
//
//  Created by wangdong on 2020/9/17.
//  Copyright © 2020 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

class EXCodeGroupView: NibBaseView {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var inputTextField: UITextField!
    
    /// 输入框光标
    @IBOutlet var blinkViewArray: [UIView]!
    /// 输入框显示内容
    @IBOutlet var labelArray: [UILabel]!
    /// 输入框边框
    @IBOutlet var lineViewArray: [UIView]!
    
    var focusLineColor: UIColor?
    var errorLineColor: UIColor?
    var normalLineColor: UIColor?
    var labelFont: UIFont?
    
    var lock = false
    
    let inputDone = BehaviorRelay<(Bool, String)>(value: (false, ""))
    
    var security = false
        
    func setupStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16.0
    }
    
    
    override func onCreate() {
        
        
        
        inputTextField.delegate = self
        inputTextField
            .rx
            .text
            .orEmpty
            .asDriver()
            .flatMap({ text in
                return Observable.just(text.count).asDriver(onErrorJustReturn: 0)
            })
            .drive(hitCount)
            .disposed(by: disposeBag)
        
        for view in blinkViewArray {
            view.backgroundColor = .Ex.main4
            view.layer.add(blinkAnimation(), forKey: nil)
        }
        
        inputTextField.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [weak self] in
            self?.onLoseFocus()
        }).disposed(by: self.disposeBag)
    }
    
    func onLoseFocus() {
        for view in blinkViewArray {
            view.isHidden = true
        }
        
        for line in lineViewArray {
            line.backgroundColor = .Ex.fill3
            line.extSetCornerRadius(4)
            if let sublayers = line.layer.sublayers{
                for subLayer in sublayers{
                    if subLayer.isKind(of: CAShapeLayer.self){
                        subLayer.removeFromSuperlayer()
                    }
                }
            }
            
//            line.extSetBorderWidth(0.5, color: .clear)
        }
    }
    
    func restore() {
        inputDone.accept((false, ""))
        for view in lineViewArray {
            view.backgroundColor = .Ex.fill3
        }
        
        for textField in labelArray {
            textField.text = ""
        }
        
        for view in blinkViewArray {
            view.isHidden = true
        }
    }
    
    func beginInput() {
        inputTextField.becomeFirstResponder()
    }
    
    func endInput () {
        inputTextField.resignFirstResponder()
    }
    
    func isInput() -> Bool {
        return inputTextField.isFirstResponder
    }
    
    func clear() {
        lock = false
        inputTextField.text = ""
        restore()
        blinkViewArray.first?.isHidden = false
    }
    
    func error() {
        
//        for lineView in lineViewArray {
//            lineView.extSetCornerRadius(4)
////            lineView.extSetBorderWidth(0.5, color: .Ex.fall1)
////            lineView.backgroundColor = UIColor.red
//            lineView.setborderLayerHight(corneradius: 4, borderWidth: 0.5, borderColor: .Ex.fall1)
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.clear()
            self.endInput()
            self.onLoseFocus()
        }
    }
    
    func hit(count: Int) {
        
        if lock {
            return
        }
        
        if count > stackView.arrangedSubviews.count {
            return
        }
        restore()
        
        if count == 0 {
            blinkViewArray.first?.isHidden = false
            lineViewArray.first?.extSetCornerRadius(4)
//            lineViewArray.first?.extSetBorderWidth(0.5, color: .Ex.main4)
            _ =  lineViewArray.first?.setborderLayerHight()
        }
        
        for i in 0..<count {

            let label = labelArray[i]
            let text = ((inputTextField.text ?? "") as NSString).substring(with: NSRange(location: i, length: 1)) as String
            
            //             label.text = "*"
            label.text = text
            
            if i == count - 1 {
                if i < 5 {
                    let view = blinkViewArray[i + 1]
                    view.isHidden = false
                    
                    let line = lineViewArray[i + 1]
                    line.extSetCornerRadius(4)
                   _ = line.setborderLayerHight()
//                    line.extSetBorderWidth(0.5, color: .Ex.main1)
//                    line.backgroundColor = .red //.Ex.main4
                }
            }
        }
        
        if (count == 6 && lock == false) {
            lock = true
            inputDone.accept((true, inputTextField.text!))
        }
    }
    
    func blinkAnimation() -> CABasicAnimation {
        let blink = CABasicAnimation.init(keyPath: "opacity")
        blink.fromValue = 1.0
        blink.toValue = 0.0
        blink.autoreverses = true
        blink.duration = 0.3
        blink.repeatCount = Float(Int.max)
        blink.isRemovedOnCompletion = false
        blink.fillMode = CAMediaTimingFillMode.forwards
        blink.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        return blink
    }
    
    func set(value: String) {
        inputTextField.text = value
        inputTextField.sendActions(for: .editingChanged)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputTextField.becomeFirstResponder()
        hit(count: inputTextField.text?.count ?? 0)
    }
}

extension EXCodeGroupView {
    public var hitCount: Binder<Int> {
        return Binder(self) { view, hitCount in
            view.hit(count: hitCount)
        }
    }
    
}

extension EXCodeGroupView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location <= 5
    }
}
