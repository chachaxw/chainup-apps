//
//  EXQuantSegmentView.swift
//  Chainup
//
//  Created by bradjohn on 2024/1/1.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit

protocol EXQuantSegmentViewDelegate {
    func segmentedView(_ segmentedView: EXQuantSegmentView, didSelectedItemAt index: Int)
    func segmentedView(_ scrollView: EXQuantSegmentView, didTap guideButton: UIButton)
}

extension EXQuantSegmentViewDelegate {
    func segmentedView(_ segmentedView: EXQuantSegmentView, didSelectedItemAt index: Int) {}
    func segmentedView(_ scrollView: EXQuantSegmentView, didTap guideButton: UIButton) {}
}

class EXQuantSegmentView: UIView {
    
    var delegate: EXQuantSegmentViewDelegate?
    
    var contentInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
        }
    }
    
    var separatorInsets: UIEdgeInsets = .zero {
        didSet {
            separatorView.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(separatorInsets.left)
                make.right.equalToSuperview().offset(-separatorInsets.right)
            }
        }
    }
    
    private lazy var dataSource: JXSegmentedTitleDataSource = {
        let v = JXSegmentedTitleDataSource()
        v.titleNormalFont = .Ex.medium(14)
        v.titleSelectedFont = .Ex.medium(14)
        v.titleNormalColor = .Ex.text2
        v.titleSelectedColor = .Ex.text1
        v.titleSelectedZoomScale = 1.0
        v.isItemSpacingAverageEnabled = false
        v.itemWidthIncrement = 8
        v.itemSpacing = 16
        v.titles = ["quant_ai_strategy".localized(), "quant_custom_strategy".localized()]
        return v
    }()
    
    private lazy var segmentView: JXSegmentedView = {
        let v = JXSegmentedView()
        v.delegate = self
        v.dataSource = dataSource
        v.defaultSelectedIndex = 0
        v.contentEdgeInsetLeft = 0
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorColor = .Ex.main1
        indicator.indicatorWidth = 22
        indicator.indicatorHeight = 4
        indicator.indicatorCornerRadius = 0
        v.indicators = [indicator]
        return v
    }()
    
    lazy var button: EXImageButton = {
        let v = EXImageButton(type: .custom)
        v.text = "quant_grid_guide".localized()
        v.textLabel.font = .Ex.medium(12)
        v.textLabel.textColor = .Ex.text2
        v.image = EXKitBundle.image(named: "gridtrading_guide")
        v.addTarget(self, action: #selector(guideAlert), for: .touchUpInside)
        return v
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    private lazy var separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill4
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        addSubview(contentView)
        contentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(contentInsets)}
        contentView.addSubViews([segmentView, button, separatorView])
        segmentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        button.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(segmentView.snp.right)
            make.centerY.height.equalTo(segmentView)
        }
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom).offset(0.5)
            make.left.equalToSuperview().offset(-contentInsets.left)
            make.right.equalToSuperview().offset(contentInsets.right)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

extension EXQuantSegmentView {
    
    @objc private func guideAlert() {
        delegate?.segmentedView(self, didTap: self.button)
    }
    
}

extension EXQuantSegmentView: JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        delegate?.segmentedView(self, didSelectedItemAt: index)
    }
}
