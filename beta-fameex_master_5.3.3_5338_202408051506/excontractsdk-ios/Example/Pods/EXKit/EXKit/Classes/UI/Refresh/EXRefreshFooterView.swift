//
//  EXRefreshFooterView.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/27.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import MJRefresh
import Lottie

public class EXRefreshFooterView: MJRefreshBackFooter {
    
    lazy var container: UIView = {
        let v = UIView()
        v.extUseAutoLayout()
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.font = .Ex.regular(12)
        v.textColor = .Ex.text1
        v.text = EXUIDatasource.shared.refresh_up_Title
        return v
    }()
    
    lazy var animationV: EXRefreshLottieAnimationView = {
        let v = EXRefreshLottieAnimationView()
        v.extUseAutoLayout()
        v.isHeader = false
        return v
    }()
    
    
    public override var state: MJRefreshState {
        didSet {
//            if state == .idle {
//
//                if oldValue == .refreshing {
//                    self.logo.transform = .identity
//                    UIView.animate(withDuration: MJRefreshFastAnimationDuration) {
//                        self.alpha = 0.0
//                    } completion: { _ in
//                        if self.state != .idle { return }
//                        self.alpha = 1.0
//                        self.logo.stopAnimating()
//                    }
//                } else {
//                    self.logo.stopAnimating()
//                    UIView.animate(withDuration: MJRefreshFastAnimationDuration) {
//                        self.logo.transform = .identity
//                    }
//                }
//
//                self.titleLabel.text = EXUIDatasource.shared.refresh_up_Title
//                self.logo.image = EXKitBundle.image(named: "ic_loading_dropdown")?.imageWithTintColor(color: .Ex.text1).yy_imageByRotate180()
//
//            }else if state == .pulling {
//                self.logo.stopAnimating()
//                self.titleLabel.text = EXUIDatasource.shared.refresh_trigger
//                UIView.animate(withDuration: MJRefreshFastAnimationDuration) {
//                    self.logo.transform = .init(rotationAngle: 0.000001 - M_PI)
//                }
//
//            }else if state == .refreshing {
//
//                self.logo.image = EXKitBundle.image(named: "ic_loading_refresh")?.imageWithTintColor(color: .Ex.text1)
//                self.titleLabel.text = EXUIDatasource.shared.refresh_refreshing
//                self.startAnimating()
//
//            }else if state == .noMoreData {
//                self.titleLabel.text = EXUIDatasource.shared.refresh_noMoreData
//                self.stopAnimating()
//            }
            
            switch state {
            case .idle:
                self.animationV.updateToIdle(isRefreshing: oldValue == .refreshing,
                                             duration: MJRefreshFastAnimationDuration) {
                    self.alpha = 0.0
                } completion: { _ in
                    if self.state != .idle { return }
                    self.alpha = 1.0
                    self.titleLabel.text = EXUIDatasource.shared.refresh_up_Title
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
            animationV.isHidden = state == .noMoreData
        }
    }
    
    public override func prepare() {
        super.prepare()
        self.mj_h = 64
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(animationV)
    }
    
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
