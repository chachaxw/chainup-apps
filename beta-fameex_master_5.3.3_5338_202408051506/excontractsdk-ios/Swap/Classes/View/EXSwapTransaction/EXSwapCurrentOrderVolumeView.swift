//
//  EXSwapCurrentOrderVolumeView.swift
//  Chainup
//
//  Created by ZYJ on 2023/5/23.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXSwapCurrentOrderVolumeView: UIView {

    /// 委托数量 English: /Number of Commissions
    lazy var volumeView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.ext_UseAutoLayout()
        view.bottomLabel.snp.remakeConstraints { (make) in
            
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        view.contentAlignment = .right

        return view
    }()
    /// 委托价值 English: /Entrusted value
    lazy var valueView: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.ext_UseAutoLayout()
        view.isHidden = true
        view.bottomLabel.snp.remakeConstraints { (make) in
            
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return view
    }()
    /// 成交数量 English: /Transaction quantity
    lazy var dealVolumeView : SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.ext_UseAutoLayout()
        view.bottomLabel.snp.remakeConstraints { (make) in
            
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return view
    }()
    lazy var slider:UISlider = {
       let slider = UISlider()
        slider.setThumbImage(UIImage(), for: .normal)
        return slider
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        exs_addSubViews([volumeView,valueView,dealVolumeView,slider])
        dealVolumeView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.height.equalTo(43)
        }
        volumeView.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
            make.height.equalTo(dealVolumeView)
        }
        valueView.snp.makeConstraints { (make) in
            make.edges.equalTo(volumeView)
        }
        slider.snp.makeConstraints { (make) in
            make.leading.equalTo(dealVolumeView)
            make.trailing.equalTo(volumeView)
            make.centerY.equalTo(dealVolumeView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

