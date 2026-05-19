//
//  EXSkeletonTradingTrend.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

class EXSkeletonTradingTrend: EXSkeletonComponents {
    
    lazy var rectangle5: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle6: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle7: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle8: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle9: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle10: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var placeholder1: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var placeholder2: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var placeholder3: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var placeholder4: UIView = {
        let v = UIView()
        return v
    }()
    
    override func setupView() {
        super.setupView()
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(placeholder)
        addSubview(rectangle3)
        addSubview(rectangle4)
    
        rectangle1.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalToSuperview().multipliedBy(0.032)
        }
        rectangle2.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.height.width.equalTo(rectangle1)
        }
        placeholder.snp.makeConstraints { make in
            make.top.equalTo(rectangle1.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.021)
        }
        rectangle3.snp.makeConstraints { make in
            make.top.equalTo(placeholder.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.378)
            make.height.equalToSuperview().multipliedBy(0.374)
        }
        rectangle4.snp.makeConstraints { make in
            make.top.equalTo(rectangle3)
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.570)
            make.height.equalTo(rectangle3)
        }
        
        addSubview(placeholder1)
        addSubview(rectangle5)
        addSubview(placeholder2)
        addSubview(rectangle6)
        
        placeholder1.snp.makeConstraints { make in
            make.top.equalTo(rectangle3.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.021)
        }
        rectangle5.snp.makeConstraints { make in
            make.top.equalTo(placeholder1.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.526)
            make.height.equalToSuperview().multipliedBy(0.037)
        }
        placeholder2.snp.makeConstraints { make in
            make.top.equalTo(rectangle5.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.021)
        }
        rectangle6.snp.makeConstraints { make in
            make.top.equalTo(placeholder2.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.637)
            make.height.equalToSuperview().multipliedBy(0.032)
        }
        
        addSubview(placeholder3)
        addSubview(rectangle7)
        addSubview(rectangle8)
        placeholder3.snp.makeConstraints { make in
            make.top.equalTo(rectangle6.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.021)
        }
        rectangle7.snp.makeConstraints { make in
            make.top.equalTo(placeholder3.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.378)
            make.height.equalToSuperview().multipliedBy(0.374)
        }
        rectangle8.snp.makeConstraints { make in
            make.top.equalTo(rectangle7)
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.570)
            make.height.equalTo(rectangle7)
        }
        
        addSubview(placeholder4)
        addSubview(rectangle9)
        addSubview(rectangle10)
        placeholder4.snp.makeConstraints { make in
            make.top.equalTo(rectangle7.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.021)
        }
        rectangle9.snp.makeConstraints { make in
            make.top.equalTo(placeholder4.snp.bottom)
            make.left.equalTo(rectangle1)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.733)
        }
        rectangle10.snp.makeConstraints { make in
            make.top.equalTo(rectangle9)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.207)
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
