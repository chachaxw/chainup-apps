//
//  EXRefreshHeaderView.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/27.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import MJRefresh
import Lottie

public class EXRefreshHeaderView: MJRefreshHeader {
    
    lazy var container: UIView = {
        let v = UIView()
        v.extUseAutoLayout()
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.font = .Ex.regular(12)
        v.textColor = .Ex.text1
        v.text = EXUIDatasource.shared.refresh_down_Title
        return v
    }()
    
    lazy var animationV: EXRefreshLottieAnimationView = {
        let v = EXRefreshLottieAnimationView()
        v.extUseAutoLayout()
        v.isHeader = true
        return v
    }()
    
    public override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                self.animationV.updateToIdle(isRefreshing: oldValue == .refreshing,
                                             duration: MJRefreshFastAnimationDuration) {
                    self.alpha = 0.0
                } completion: { _ in
                    if self.state != .idle { return }
                    self.alpha = 1.0
                    self.titleLabel.text = EXUIDatasource.shared.refresh_down_Title
                }
                break
            case .pulling:
                self.animationV.updateToPulling()
                self.titleLabel.text = EXUIDatasource.shared.refresh_trigger
                break
            case .refreshing:
                self.animationV.updateToRefreshing()
                self.titleLabel.text =  EXUIDatasource.shared.refresh_refreshing
                break
            case .willRefresh, .noMoreData:
                break
            }
        }
    }
    
    public override func prepare() {
        super.prepare()
        self.mj_h = 64
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(animationV)
        titleLabel.textColor = .Ex.text1
    }
    
//    func animation() -> CABasicAnimation{
//        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
//        animation.fillMode = .forwards
//        animation.toValue = .pi * 2.0
//        animation.duration = 0.5
//        animation.repeatCount = .greatestFiniteMagnitude
//        return animation
//    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        container.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        animationV.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(animationV.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(14.6)
        }
    }
    
    public override func endRefreshing() {
        if !isRefreshing { return }
        self.titleLabel.text = EXUIDatasource.shared.refresh_refresh_complete
        self.animationV.updateToEndRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now()  + MJRefreshSlowAnimationDuration) {
            super.endRefreshing()
        }
    }
    
    public override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]!) {
        super.scrollViewContentOffsetDidChange(change)
    }
    
    public override func scrollViewContentSizeDidChange(_ change: [AnyHashable : Any]!) {
        super.scrollViewContentSizeDidChange(change)
    }
    
    public override func scrollViewPanStateDidChange(_ change: [AnyHashable : Any]!) {
        super.scrollViewPanStateDidChange(change)
    }
    
}
