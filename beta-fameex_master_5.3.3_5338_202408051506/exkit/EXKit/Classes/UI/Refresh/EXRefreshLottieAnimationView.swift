//
//  EXRefreshLottieAnimationView.swift
//  EXKit
//
//  Created by bradjohn on 2023/9/1.
//

import UIKit
import Lottie
import MJRefresh

class EXRefreshLottieAnimationView: UIView {
    
    lazy var indicatorV: UIImageView = {
        let v = UIImageView()
        v.extUseAutoLayout()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    lazy var refreshV: LottieAnimationView = {
        let v = LottieAnimationView(name: "loading_dropdown", bundle: EXKitBundle.resource ?? .main)
        v.extUseAutoLayout()
        v.loopMode = .loop
        v.isHidden = true
        return v
    }()
    
    var isHeader: Bool = true {
        didSet {
            dragImage = isHeader ? defaultDragImage : defaultDragImage?.yy_imageByRotate180()
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    private var dragImage: UIImage?
    
    private var defaultDragImage : UIImage? {
        return EXKitBundle.image(named: "ic_loading_dropdown")?.imageWithTintColor(color: .Ex.text1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        addSubview(indicatorV)
        addSubview(refreshV)
        indicatorV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        refreshV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateToRefreshing() {
        self.indicatorV.isHidden = true
        self.refreshV.isHidden = false
        self.refreshV.updateColor(keypaths: ["转动.椭圆 1.描边 1.Color"],
                                  color: .Ex.named(.fill1, color: EXTheme.isDark ? .light : .dark))
        self.refreshV.play()
    }
    
    func updateToEndRefreshing() {
        if self.refreshV.isAnimationPlaying {
            self.refreshV.stop()
        }
        self.refreshV.isHidden   = true
        self.indicatorV.isHidden = false
        self.indicatorV.transform = .identity
        self.indicatorV.image = EXKitBundle.image(named: "ic_loading_loadedsuccessfully")?.imageWithTintColor(color: .Ex.text1)
    }
    
    func updateToIdle(isRefreshing refreshing: Bool, duration duration: TimeInterval, animations: @escaping () -> Void, completion: @escaping((Bool) -> Void)) {
        if refreshing {
            UIView.animate(withDuration: duration, animations: animations) { finished in
                completion(finished)
                self.indicatorV.transform = .identity
                self.indicatorV.image = self.dragImage
            }
        } else {
            UIView.animate(withDuration: duration) {
                self.indicatorV.transform = .identity
            } completion: { _ in
                self.indicatorV.image = self.dragImage
            }
        }
    }
    
    func updateToPulling() {
        if self.refreshV.isAnimationPlaying {
            self.refreshV.stop()
        }
        self.refreshV.isHidden   = true
        self.indicatorV.isHidden = false
        UIView.animate(withDuration: MJRefreshFastAnimationDuration) {
            self.indicatorV.transform = .init(rotationAngle: 0.000001 - M_PI)
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
