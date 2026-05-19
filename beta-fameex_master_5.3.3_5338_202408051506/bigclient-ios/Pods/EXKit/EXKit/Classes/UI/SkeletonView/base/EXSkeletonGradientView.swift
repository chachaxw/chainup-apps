//
//  EXSkeletonGradientView.swift
//  EXKit
//
//  Created by youbin on 2023/6/27.
//

import UIKit
import SkeletonView

class EXSkeletonGradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        layer.masksToBounds = true
        layer.cornerRadius  = 2
        isSkeletonable = true
        skeletonGradient(baseColor: .Ex.skeleton.first!, secondaryColor: .Ex.skeleton[1])
        startSkeletonAnimation()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutSkeletonIfNeeded()
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


extension EXSkeletonGradientView {
    
    
    /// 渐变色加载骨架
    /// - Parameters:
    ///   - baseColor: 底色
    ///   - secondaryColor: 浮动色
    func skeletonGradient(baseColor: UIColor, secondaryColor: UIColor) {
        let gradient = SkeletonGradient(baseColor: baseColor , secondaryColor: secondaryColor)
        showGradientSkeleton(usingGradient: gradient, transition: .crossDissolve(0.25))
        updateAnimatedGradientSkeleton(usingGradient: gradient)
    }
    
    
    /// 固定色加载骨架
    /// - Parameter color: 固定底色
    func skeletonSolid(with color: UIColor)  {
        updateSkeleton(usingColor: color)
    }
}
