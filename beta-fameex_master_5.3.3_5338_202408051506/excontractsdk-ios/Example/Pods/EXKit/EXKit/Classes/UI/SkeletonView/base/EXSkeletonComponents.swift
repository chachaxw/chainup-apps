//
//  EXSkeletonComponents.swift
//  EXKit
//
//  Created by youbin on 2023/6/28.
//

import UIKit

class EXSkeletonComponents: UIView {
    
    lazy var rectangle1: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle2: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle3: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle4: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var circle: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        v.layer.masksToBounds = true
        return v
    }()
    
    lazy var placeholder: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 配置view布局
    func setupView() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.circle.isHidden != true {
            self.circle.layer.cornerRadius = CGRectGetWidth(self.circle.frame) * 0.5
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
