//
//  EXFlutterKLineChart.swift
//  Chainup
//
//  Created by 尤彬 on 2023/5/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import SnapKit

class EXSContractFlutterKLineChart: EXView {
    
    typealias EXComFloatBlock = (_ number: CGFloat) -> ()
    
    var changeHeightBlock: EXComFloatBlock?
    
    /// fluter kline viewModel
    var viewModel: EXContractFlutterKLineChartViewModel?
    
    /// filter Menu
    lazy var filterMenu: EXContractFlutterKLineChartFilterMenu = {
        let v = EXContractFlutterKLineChartFilterMenu(viewModel: self.viewModel)
        return v
    }()
    
    /// Kline
    lazy var kline: EXContractFlutterKLine = {
        let v = EXContractFlutterKLine(viewModel: self.viewModel)
        return v
    }()
    
    var isExpand: Bool = false {
        didSet {
            self.viewModel?.isExpand = isExpand
            invalidateIntrinsicContentSize()
        }
    }
    
    var isVisible:Bool = true {
        didSet {
            filterMenu.snp.updateConstraints { make in
                make.height.equalTo(isVisible ? getMenuHeight() : 0)
            }
            filterMenu.isHidden = !isVisible
            invalidateIntrinsicContentSize()
        }
    }
    
    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXContractFlutterKLineChartViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        backgroundColor = .Ex.fill9
        addSubview(filterMenu)
        addSubview(kline)
        filterMenu.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(getMenuHeight())
        }
        kline.snp.makeConstraints { make in
            make.top.equalTo(filterMenu.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.filterMenu.openStateBlock = { [weak self] isOpen in
            guard let self = self else { return }
            self.isExpand  = isOpen
            self.invalidateIntrinsicContentSize()
            self.changeHeightBlock?(self.getHeight(with: isOpen))
        }
        
        self.filterMenu.saceKeyValueBlock = {[weak self] value in
            guard let self = self else { return }
            guard let _value = value else { return }
            self.viewModel?.setCandleScale(_value)
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


// MARK: relative height of the view
extension EXSContractFlutterKLineChart {
    
    /// 菜单的高度 English: /The height of the menu
    /// - Returns: height
    internal func getMenuHeight() -> CGFloat {
        return 38
    }
    
    /// K线的高度, 并返回 English: /The height of the K-line and return
    /// - Parameter isExpand: 展开状态 English: /- Parameter isExpand: Expand status
    /// - Returns: height
    internal func getKLineHeight(with isExpand: Bool) -> CGFloat {
        return isExpand ? 167 : 0
    }
    
    /// 整个视图的高度(K线 + 菜单()) English: /The height of the entire view (K-line+menu)
    /// - Parameter isExpand: 展开状态 English: /- Parameter isExpand: Expand status
    /// - Returns: height
    internal func getHeight(with isExpand: Bool) -> CGFloat {
        return getKLineHeight(with: isExpand) + getMenuHeight()
    }
    
    override var intrinsicContentSize: CGSize {
        let height:CGFloat = isVisible ? getHeight(with: isExpand) : 0
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}

extension EXSContractFlutterKLineChart {
    func setBottom(with isBottom: Bool) {
        backgroundColor = isBottom ? .Ex.fill9 : .clear
        self.filterMenu.isBottom = isBottom
        self.kline.isBottom      = isBottom
    }
}


