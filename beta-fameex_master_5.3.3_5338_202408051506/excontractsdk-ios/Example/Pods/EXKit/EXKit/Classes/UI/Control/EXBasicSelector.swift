//
//  EXBasicSelector.swift
//  EXKit
//
//  Created by zq on 2023/4/7.
//

import UIKit
import SnapKit
import RxSwift

public class EXCommonSelector: UIView {
    ///
    public var contentInset:UIEdgeInsets = .zero {
        didSet {
            contentView.snp.remakeConstraints { make in
                make.edges.equalTo(contentInset)
            }
        }
    }
    ///
    public lazy var contentView: EXStackView = {
        let stackView = EXSelectorStackView(arrangedSubviews: [basicSelector])
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
    public lazy var basicSelector: EXBasicSelector = { EXBasicSelector() }()
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

public class EXBasicSelector: UIControl, EXBasicBoxedViewProtocol {
    private var _isOn:Bool = false
    ///
    public var isOn:Bool {
        get { _isOn }
        set { setOn(newValue, animated: false) }
    }
    ///
    public func setOn(_ on: Bool, animated: Bool) {
        guard on != _isOn else { return }
        _isOn = on
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.arrowImageView.transform = on ? CGAffineTransform(rotationAngle: .pi) : .identity
        }
    }
    ///
    open var contentInset:UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8) {
        didSet {
            contentView.snp.remakeConstraints { make in
                make.edges.equalTo(contentInset)
            }
            invalidateIntrinsicContentSize()
        }
    }
    ///
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: titleLabel.intrinsicContentSize.height + contentInset.top + contentInset.bottom)
    }
    ///
    public lazy var contentView: EXStackView = {
        let stackView = EXSelectorStackView(arrangedSubviews: [centerView, trailingView])
        stackView.separatorConfiguration = nil
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        return stackView
    }()
    ///
    public lazy var leadingView: EXStackView = {
        let stackView = EXSelectorStackView()
        stackView.separatorConfiguration = nil
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.isHidden = true
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentView.insertArrangedSubview(stackView, at: 0)
        return stackView
    }()
    ///
    public var title: String? {
        get { titleLabel.text }
        set {
            titleLabel.text = newValue
            invalidateIntrinsicContentSize()
        }
    }
    ///
    public lazy var titleLabel: UILabel = {
        let label = UILabel(text: nil, font: .Ex.medium(14), textColor: .Ex.text1, alignment: .left)
        return label
    }()
    ///
    public lazy var centerView: EXStackView = {
        let stackView = EXSelectorStackView(arrangedSubviews: [titleLabel])
        stackView.separatorConfiguration = nil
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        return stackView
    }()
    
    ///
    public lazy var trailingView: EXStackView = {
        let stackView = EXSelectorStackView(arrangedSubviews: [arrowImageView])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stackView
    }()
    ///
    public lazy var arrowImageView:UIImageView = {
        let icon = UIImageView(image:EXKitBundle.image(named: "public_arrow_down"))
        icon.contentMode = .scaleAspectFit
        icon.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
        return icon
    }()
    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)
        //
        backgroundColor = .Ex.special2
        corneradius = 4
        //
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentInset)
        }
        rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.setOn(!self.isOn, animated: true)
            self.sendActions(for: .valueChanged)
        }).disposed(by: disposeBag)
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view is EXSelectorStackView { return self }
        return view
    }
}

private class EXSelectorStackView: EXStackView {}
