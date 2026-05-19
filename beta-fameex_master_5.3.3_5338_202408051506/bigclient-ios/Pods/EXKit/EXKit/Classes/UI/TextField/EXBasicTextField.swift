//
//  EXBasicTextField.swift
//  EXKit
//
//  Created by zq on 2023/4/4.
//

import UIKit
import SnapKit
import RxSwift

public class EXCommonTextField: UIView, EXTextFieldProtocol {
    ///
    public var contentInset:UIEdgeInsets = .zero {
        didSet {
            contentView.snp.remakeConstraints { make in
                make.edges.equalTo(contentInset)
            }
        }
    }
    ///
    public var textField: UITextField { basicTextField.textField }
    ///
    public let basicTextField: EXBasicTextField = EXBasicTextField()
    ///
    public lazy var contentView: EXStackView = {
        let stackView = EXStackView(arrangedSubviews: [basicTextField])
        stackView.separatorConfiguration = nil
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.corneradius = 4
        return stackView
    }()
    ///
    public lazy var topLabel: UILabel = {
        let label = UILabel(text: nil, font: .Ex.medium(12), textColor: .Ex.text2, alignment: .left)
        contentView.insertArrangedSubview(label, at: 0)
        return label
    }()
    ///
    public lazy var bottomLabel: UILabel = {
        let label = UILabel(text: nil, font: .Ex.medium(12), textColor: .Ex.text2, alignment: .left)
        contentView.addArrangedSubview(label)
        return label
    }()
    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentInset)
        }
    }
    ///
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


open class EXBasicTextField: EXBasicBoxedView, EXTextFieldProtocol, UITextFieldDelegate {
    open var borderLayer: CAShapeLayer?
    ///精度
    open var decimal:String = ""
    ///最大长度
    open var maxLength:Int = .max
    ///
    public lazy var textField: UITextField = {
        let textField = UITextField()
        textField.tintColor = .Ex.main1
        textField.setModifyClearButton()
        textField.font = .Ex.medium(14)
        textField.textColor = .Ex.text1
        textField.delegate = self
        return textField
    }()
    //
    public var highlightColor:UIColor? {
        didSet {
            isHighlightable = highlightColor != nil
        }
    }
    //
    public var preferedContentSize:CGSize? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    //
    open override var intrinsicContentSize: CGSize {
        return preferedContentSize ?? super.intrinsicContentSize
    }
    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .Ex.special2
        corneradius = 4
        contentView.spacing = 15
        centerView.addArrangedSubview(textField)
        contentInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 12)
        highlightableUpdater = EXViewStateUpdater(dynamicUpdater: { [weak self] isHighlighted in
            guard let self = self else { return }
            guard let highlightColor = self.highlightColor else { return }
            if isHighlighted {
                self.borderLayer = self.setborderLayerHight(corneradius: 4, borderWidth: 0.5,borderColor: highlightColor)
            }else{
                self.borderLayer?.removeFromSuperlayer()
            }
        })
    }
    ///
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///
    @objc open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        if newLength > maxLength { return false }
        if keyboardType == .numberPad || keyboardType == .decimalPad {
            if decimal.isEmpty { return true }
            if let decimal = Int(decimal), decimal >= 0, var text = textField.text, let range = Range(range, in: text) {
                text.replaceSubrange(range, with: string)
                return text.isValidInputAmount(decimal: decimal)
            }
        }
        return true
    }
    
    open func hideError(_ textField:UITextField) {
        self.borderLayer?.removeFromSuperlayer()
        if let placeHolder = textField.placeholder {
            textField.setPlaceHolderAtt(placeHolder)
        }
    }
    open func showBorderLayerError() {
        self.borderLayer?.removeFromSuperlayer()
        self.borderLayer = setborderLayerHight(borderColor: .Ex.fall1)
    }
    
}


//extension EXBasicTextField: EXTextFieldPresenterProtocol {
//    public func textValueChanged(value: String) {
//        self.textfieldValueChangeBlock?(value)
//    }
//    
//    public func inputDidBeginEditing() {
//        self.hideError(textField)
//        self.textfieldDidBeginBlock?()
//    }
//    
//    public func inputDidEndEditing() {
//        self.textfieldDidEndBlock?()
//    }
//}

extension EXBasicTextField: EXTextFieldConfigurable {
    
    public var baseField: UITextField {
        return self.textField
    }
    
    public var baseHighlight: UIView {
        return self
    }
}


public class EXSecureTextField: EXBasicTextField {
    public override var maxLength: Int { get { 32 }
        set {    }
    }
    private let secureOffImage = EXKitBundle.image(named: "login_eyeoff")
    private let secureOnImage = EXKitBundle.image(named: "login_eyeon")
    ///
    private lazy var secureButton: UIButton = {
        let button = UIButton()
        button.setImage(secureOffImage, for: .normal)
        button.setImage(secureOffImage, for: .highlighted)
        button.setImage(secureOnImage, for: .selected)
        button.setImage(secureOnImage, for: [.selected, .highlighted])
        button.rx.tap.subscribe(onNext: {[weak self] _ in
            self?.secureButton.isSelected.toggle()
            self?.isSecureTextEntry.toggle()
        }).disposed(by: disposeBag)
        return button
    }()
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.spacing = 13
        contentInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        trailingView.addArrangedSubview(secureButton)
        trailingView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        isSecureTextEntry = true
    }
    ///
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public class EXCoinTextField: EXCommonTextField {
    ///精度
    public var decimal:String {
        get { basicTextField.decimal }
        set { basicTextField.decimal = newValue }
    }
    ///
    public var unit: String? {
        get { unitLabl.text }
        set { unitLabl.text = newValue }
    }
    ///
    public var maxValue:String?
    ///
    public var maxButtonAction:((EXCoinTextField)->Void)?
    ///
    public lazy var allButton: UIButton = {
        let button = UIButton(title: "common_action_sendall".localized(), titleFont: .Ex.medium(12), titleColor: .Ex.main4)
        button.enlargeInteractionEdge(with: 10)
        button.rx.tap.subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            if let maxButtonAction = self.maxButtonAction {
                return maxButtonAction(self)
            }
            if let maxValue = self.maxValue {
                self.text = maxValue
                self.textField.sendActions(for: .valueChanged)
            }
        }).disposed(by: disposeBag)
        return button
    }()
    ///
    public lazy var unitLabl: UILabel = {
        let label = UILabel(font: .Ex.medium(12), textColor: .Ex.text3)
        basicTextField.trailingView.insertArrangedSubview(label, at: 0)
        return label
    }()
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        keyboardType = .decimalPad
        basicTextField.contentView.spacing = 2
        basicTextField.trailingView.spacing = 24
        basicTextField.trailingView.addArrangedSubview(allButton)
        basicTextField.trailingView.separatorConfiguration = .init(color: .Ex.fill5, height: 12, cornerRadius: 0)
        basicTextField.preferedContentSize = CGSize(width: UIView.noIntrinsicMetric, height: 44)
        basicTextField.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    ///
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



public extension UIView{
    //borderWidth 小于1 边框显示有问题
    func setborderLayerHight(corneradius: CGFloat = 4,borderWidth: CGFloat = 0.5,borderColor: UIColor = .Ex.main1) -> CAShapeLayer{
        let borderLayer = CAShapeLayer()
        borderLayer.frame = self.bounds
        borderLayer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: corneradius, height: corneradius)).cgPath
        borderLayer.path = borderLayer.path // Reuse the Bezier path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = self.bounds
        self.layer.addSublayer(borderLayer)
        return borderLayer
    }
}
