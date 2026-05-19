//
//  EXOTCHomeTitleView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
protocol OTCPageTitleDelegate {
    func pageTitle(pageTitleView:EXOTCHomeTitleView,selectedIdx:Int)
}


class EXOTCHomeTitleView: UIView {
    
    
    lazy var titleBar: EXSelectionTitleBar = {
        let v = EXSelectionTitleBar()
        v.hideSeperator()
        return v
    }()
    
    var menus:[EXKLineScaleView] = []
    
    var isHavebottomBorder: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var bottomBorderColor: UIColor = .Ex.fill4 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var bottomBorderHeight: CGFloat = 1.0 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    var delegate:OTCPageTitleDelegate? = nil
    var selectedIndex:Int = 0 {
        didSet {
            titleBar.setSelected(atIdx: selectedIndex)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        addSubViews([titleBar])
        titleBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-bottomBorderHeight)
        }
    }
    
    func configTitles(titles:[String]) {
        titleBar.bindTitleBar(with: titles,indicatorColors:[.Ex.main1, .Ex.main1])
        titleBar.titleBarCallback = {[weak self] tag in
            guard let mySelf = self else {return}
            mySelf.delegate?.pageTitle(pageTitleView: mySelf, selectedIdx: tag)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext(), isHavebottomBorder, rect.size.height > 0, rect.height > 0 {
            context.setStrokeColor(bottomBorderColor.cgColor)
            context.setLineWidth(bottomBorderHeight)
            context.move(to: CGPoint(x: 0, y: rect.height - bottomBorderHeight))
            context.addLine(to: CGPoint(x: rect.width, y: rect.height - bottomBorderHeight))
            context.strokePath()
        }
    }
}
