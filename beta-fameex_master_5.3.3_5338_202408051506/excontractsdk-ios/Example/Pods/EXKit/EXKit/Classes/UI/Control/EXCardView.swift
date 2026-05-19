//
//  EXCardView.swift
//  EXKit
//
//  Created by zq on 2023/4/10.
//

import UIKit

open class EXCardView: UIControl, EXSelectable {
    open override var isSelected: Bool {
        didSet {
            updateSelectedStyle()
        }
    }
    public var isCheckMarkInline = false {
        didSet {
            normalCheckmarkImageView.isHidden = isCheckMarkInline
            inlineCheckmarkImageView.isHidden = !isCheckMarkInline
            updateContentView()
            updateSelectedStyle()
            invalidateIntrinsicContentSize()
        }
    }
    
    ///
    open var contentInset:UIEdgeInsets = .zero {
        didSet {
            updateContentView()
            invalidateIntrinsicContentSize()
        }
    }
    ///
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 20 + contentInset.top + contentInset.bottom)
    }
    ///
    public lazy var contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .leading
        return stackView
    }()
    private var checkmarkImageView: UIImageView { isCheckMarkInline ? inlineCheckmarkImageView : normalCheckmarkImageView }
    private lazy var normalCheckmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: ""))
        imageView.isHidden = isCheckMarkInline
        return imageView
    }()
    private lazy var inlineCheckmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: ""))
        imageView.isHidden = !isCheckMarkInline
        return imageView
    }()
    ///
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == contentView { return self }
        return view
    }
    func updateContentView() {
        var contentInset = self.contentInset
        if isCheckMarkInline {
            contentInset.right += (6 + 16 + 10)
        }
        contentView.snp.remakeConstraints { make in
            make.edges.equalTo(contentInset)
        }
    }
    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .Ex.special2
        corneradius = 4
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentInset)
        }
        addSubview(checkmarkImageView)
        normalCheckmarkImageView.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        addSubview(inlineCheckmarkImageView)
        inlineCheckmarkImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 16, height: 16))
            make.centerY.equalToSuperview()
            make.right.equalTo(-10)
        }
        //
        selectableUpdater = EXViewStateUpdater(dynamicUpdater: { [weak self] isSelected in
            guard let `self` = self else { return }
            self.normalCheckmarkImageView.image = isSelected ? EXKitBundle.image(named: "public_selected") : nil
            self.inlineCheckmarkImageView.image = isSelected ? EXKitBundle.image(named: "public_checked")  : nil
            self.layer.borderWidth = isSelected ? 2 : 0
            self.layer.borderColor = isSelected ? UIColor.Ex.main1.cgColor : nil
        })
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
