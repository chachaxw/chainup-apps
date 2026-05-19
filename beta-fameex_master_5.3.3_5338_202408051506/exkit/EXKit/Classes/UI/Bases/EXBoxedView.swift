//
//  EXBoxedView.swift
//  EXKit
//
//  Created by zq on 2023/4/7.
//

import UIKit
import SnapKit

public protocol EXBasicBoxedViewProtocol {
    var contentInset:UIEdgeInsets { get set }
    var contentView: EXStackView { get }
    var leadingView: EXStackView { get }
    var centerView: EXStackView { get }
    var trailingView: EXStackView { get }
}


open class EXBasicBoxedView: UIView, EXBasicBoxedViewProtocol {
    ///
    open var contentInset:UIEdgeInsets = .zero {
        didSet {
            contentView.snp.remakeConstraints { make in
                make.edges.equalTo(contentInset)
            }
        }
    }
    ///
    public lazy var contentView: EXStackView = {
        let stackView = EXStackView(arrangedSubviews: [centerView])
        stackView.separatorConfiguration = nil
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        return stackView
    }()
    ///
    public lazy var leadingView: EXStackView = {
        let stackView = EXStackView()
        stackView.separatorConfiguration = nil
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentView.insertArrangedSubview(stackView, at: 0)
        return stackView
    }()
    ///
    public lazy var centerView: EXStackView = {
        let stackView = EXStackView()
        stackView.separatorConfiguration = nil
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        return stackView
    }()
    ///
    public lazy var trailingView: EXStackView = {
        let stackView = EXStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentView.addArrangedSubview(stackView)
        return stackView
    }()
    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)
        //
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentInset)
        }
    }
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
