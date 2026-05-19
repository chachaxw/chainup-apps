//
//  EXPersentageField.swift
//  Chainup
//
//  Created by liuxuan on2020/3/6.
//  Copyright ©2020 zewu wang. All rights reserved.
//

//百分比的输入框,25%/50%/75%/100%.处理最多输入，处理小数点1个

/*
 self.textfieldValueChangeBlock?(value)
 self.textfieldDidBeginBlock?()
 self.textfieldDidEndBlock?()
 */

import UIKit
import RxSwift

public class EXPersentageField: EXBaseField {
    
    public override var decimal: String {
        didSet {
            stepField.decimal = decimal
        }
    }
    public override var shouldBeginEditingBlock: ((UITextField) -> Bool)? {
        didSet {
            stepField.shouldBeginEditingBlock = shouldBeginEditingBlock
        }
    }
    public var input: UITextField { textField }
    public lazy var stepField: EXStepField = {
        let input = EXStepField()
        input.updateBackgroundColor(with: .Ex.special2)
        input.style.normalBorderColor = .clear
        input.corneradius = 4
        input.keyboardType = .decimalPad
        input.layer.borderColor = UIColor.clear.cgColor
        return input
    }()
    public lazy var percentView: EXPercentProgressView = {
        return EXPercentProgressView()
    }()
    
    public var volumeColor = UIColor.ThemekLine.up
    public var maxValue:String = ""
    
    public var highLightColor:UIColor = UIColor.ThemeView.highlight {
        didSet {
            volumeColor = highLightColor
            stepField.highLightColor = highLightColor
            percentView.selectedColor = highLightColor
        }
    }
    
    public override func onCreate() {
        super.onCreate()
        addSubViews([stepField,percentView])
        stepField.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(40)
        }
        percentView.snp.makeConstraints { make in
            make.top.equalTo(stepField.snp.bottom).offset(8)
            make.left.bottom.right.equalToSuperview()
        }
        ///
        stepField.input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] _ in
                self?.emptyPersentage()
            }).disposed(by: disposeBag)
        ///
        percentView.rx.controlEvent(.valueChanged).subscribe(onNext: {[weak self] _ in
            guard let `self` = self else { return }
            guard self.maxValue.count > 0, self.decimal.count > 0 else { return }
            if let percent = self.percentView.percent?.value, let decimal = Int(self.decimal) {
                self.input.text = self.maxValue.stringByMultiplying(multiple: percent, decimal: decimal, holdZero: false)
                self.input.sendActions(for: .valueChanged)
            }
        }).disposed(by: disposeBag)
    }
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        stepField.input.becomeFirstResponder()
    }
    
    public override func setPlaceHolder(placeHolder: String,font : CGFloat = 14) {
        stepField.input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    public override func setText(text: String) {
        stepField.setText(text: text)
    }
    
    public func emptyPersentage() {
        percentView.emptyPersentage()
    }
    
    public func reset() {
        stepField.setText(text: "")
        percentView.emptyPersentage()
        input.sendActions(for: .valueChanged)
    }
}

extension EXPersentageField : EXTextFieldProtocol {
    public var textField: UITextField { stepField.textField }
}

extension EXPersentageField :EXTextFieldPresenterProtocol {
    
    public func textValueChanged(value: String) {
        self.textfieldValueChangeBlock?(value)
    }
    
    public func inputDidBeginEditing() {
        self.hideError(textField)
        self.textfieldDidBeginBlock?()
    }
    
    public func inputDidEndEditing() {
        self.textfieldDidEndBlock?()
    }
}


public class EXPercentStackItemView: UIControl {
    public class DataItem:NSObject {
        let title:String
        let value:String
        init(title: String, value: String? = nil) {
            self.title = title
            self.value = value ?? title
        }
        public static var `default` = [
            DataItem(title: "25%", value: "0.25"),
            DataItem(title: "50%", value: "0.5"),
            DataItem(title: "75%", value: "0.75"),
            DataItem(title: "100%", value: "1")
        ]
    }
    public var selectedColor:UIColor = .Ex.main1 {
        didSet {
            if isSelected { barView.backgroundColor = selectedColor }
        }
    }
    public var normalColor:UIColor = .Ex.special2 {
        didSet {
            if !isSelected { barView.backgroundColor = normalColor }
        }
    }
    //
    public lazy var barView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    public lazy var textLabel: UILabel = {
        let label:UILabel = UILabel()
        label.font = .Ex.regular(12)
        label.textColor = .Ex.text1
        label.textAlignment = .center
        return label
    }()
    public override var isSelected: Bool {
        didSet {
            update()
        }
    }
    
    public var data:DataItem = DataItem(title: "") {
        didSet {
            textLabel.text = data.title
        }
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([barView,textLabel])
        barView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(6)
        }
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(barView.snp.bottom).offset(2)
            make.left.right.bottom.equalToSuperview()
        }
        update()
    }
    
    func update() {
        barView.backgroundColor = isSelected ? selectedColor : normalColor
        textLabel.textColor = isSelected ? .Ex.text1 : .Ex.text2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public class EXPercentProgressView: UIControl {
        
    lazy var contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    public  let items:[EXPercentStackItemView.DataItem]
    private var itemViews:[EXPercentStackItemView] = []
    public var percent: EXPercentStackItemView.DataItem? { selectedItemView?.data }
    private var selectedItemView:EXPercentStackItemView? {
        didSet { updateButtonState() }
    }
    public var selectedColor:UIColor = .Ex.main1 {
        didSet { itemViews.forEach({ $0.selectedColor = selectedColor }) }
    }
    public func emptyPersentage() {
        selectedItemView = nil
        updateButtonState()
    }
    func updateButtonState() {
        var index:Int? = nil
        if let selectedItemView = selectedItemView {
            index = itemViews.firstIndex(of: selectedItemView)
        }
        guard let index = index else {
            itemViews.forEach({ $0.isSelected = false })
            return
        }
        for (idx,itemView) in itemViews.enumerated() {
            if idx <= index {
                itemView.isSelected = true
            }else{
                itemView.isSelected = false
            }
        }
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == contentView { return self }
        return view
    }
    
    public init(frame: CGRect = .zero,items: [EXPercentStackItemView.DataItem] = EXPercentStackItemView.DataItem.default) {
        self.items = items
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        items.forEach { data in
            let itemView = EXPercentStackItemView()
            itemView.selectedColor = selectedColor
            itemView.data = data
            itemView.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] sender in
                guard let `self` = self else { return }
                self.selectedItemView = itemView
                self.sendActions(for: .valueChanged)
                self.selectedItemView = itemView
            }).disposed(by: disposeBag)
            contentView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }
    }
    
}
