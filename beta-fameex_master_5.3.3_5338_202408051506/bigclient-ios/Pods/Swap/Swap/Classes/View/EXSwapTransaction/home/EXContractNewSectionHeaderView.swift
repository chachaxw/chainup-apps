//
//  EXContractNewSectionHeaderView.swift
//  Chainup
//
//  Created by cwd on 2022/10/9.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView
//顶部 English: Top
class EXContractNewSectionHeaderView: UIView {
    
    /// 跳转至全部委托 VC English: /Jump to all delegated VC
    var clickAllTransactionCallback: (() -> ())?
    lazy var bgView:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.card1
        return v
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        let v = JXSegmentedView() 
        v.contentEdgeInsetLeft = 10
        v.indicators = [self.lineIndicatorLienView]
        return v
    }()
    lazy var lineIndicatorLienView: EKIndicatorSegmentIndicator = {
        let view = EKIndicatorSegmentIndicator()
        return view
    }()
    /// 全部 English: /All
    lazy var allTransactionButton: UIButton = {
        let ctl = UIButton(type: .custom)
        let img = UIImage.exs_themeImageNamed(imageName: "public_icon_order")
        ctl.setImage(img, for: .normal)
        ctl.setImage(img, for: .selected)
        ctl.addTarget(self, action: #selector(clickAllTransactionButton), for: .touchUpInside)
        ctl.exs_setEnlargeEdgeWithTop(10, left: 20, bottom: 10, right: 20)
        return ctl
    }()
    lazy var lineView:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ThemeView.card1
        self.insertSubview(bgView, at: 0)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        exs_addSubViews([segmentedView,allTransactionButton,lineView])
        self.initLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.exs_roundCorners(corners: [.topLeft,.topRight], radius: 15)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        let horMargin = 15
        self.segmentedView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalTo(floor(Device_W - 40))
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-1)
        }
        self.allTransactionButton.snp.makeConstraints { (make) in
            make.right.equalTo(-horMargin)
            make.top.height.equalTo(self.segmentedView)
        }
        self.lineView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    @objc func clickAllTransactionButton() {
       
        self.clickAllTransactionCallback?()
    }
}


