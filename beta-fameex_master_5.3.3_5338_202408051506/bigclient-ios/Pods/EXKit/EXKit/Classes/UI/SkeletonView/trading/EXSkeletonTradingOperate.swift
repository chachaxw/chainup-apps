//
//  EXSkeletonTradingOperate.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

class EXSkeletonTradingOperate: EXSkeletonTradingTrend {
    
    
    lazy var rectangle11: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle12: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle13: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle14: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var placeholder5: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var placeholder6: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var placeholder7: UIView = {
        let v = UIView()
        return v
    }()
    
    
    override func setupView() {
        super.setupView()
        removeSubviewsConstraints()
        rectangle1.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.063)
        }
        placeholder.snp.makeConstraints { make in
            make.top.equalTo(rectangle1.snp.bottom)
            make.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.031)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        rectangle2.snp.makeConstraints { make in
            make.top.equalTo(placeholder.snp.bottom)
            make.left.equalTo(rectangle1)
            make.height.equalToSuperview().multipliedBy(0.078)
            make.width.equalToSuperview().multipliedBy(0.469)
        }
        rectangle3.snp.makeConstraints { make in
            make.top.equalTo(rectangle2)
            make.right.equalToSuperview()
            make.height.width.equalTo(rectangle2)
        }
    
        ///
        placeholder1.snp.makeConstraints { make in
            make.top.equalTo(rectangle2.snp.bottom)
            make.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.031)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        rectangle4.snp.makeConstraints { make in
            make.top.equalTo(placeholder1.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.292)
        }
        
        ///
        placeholder2.snp.makeConstraints { make in
            make.top.equalTo(rectangle4.snp.bottom)
            make.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.010)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        rectangle5.snp.makeConstraints { make in
            make.top.equalTo(placeholder2.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.234)
            make.height.equalToSuperview().multipliedBy(0.057)
        }
        placeholder3.snp.makeConstraints { make in
            make.top.equalTo(placeholder2.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.021)
            make.height.equalToSuperview().multipliedBy(0.057)
        }
        rectangle6.snp.makeConstraints { make in
            make.right.equalTo(placeholder3.snp.left)
            make.centerY.height.width.equalTo(rectangle5)
        }
        rectangle7.snp.makeConstraints { make in
            make.left.equalTo(placeholder3.snp.right)
            make.centerY.height.width.equalTo(rectangle5)
        }
        rectangle8.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(rectangle5)
            make.width.height.equalTo(rectangle5)
        }
        
        ///
        placeholder4.snp.makeConstraints { make in
            make.top.equalTo(rectangle5.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.031)
        }
        rectangle9.snp.makeConstraints { make in
            make.top.equalTo(placeholder4.snp.bottom)
            make.left.right.equalTo(rectangle1)
            make.height.equalToSuperview().multipliedBy(0.141)
        }
        ///
        
        addSubview(placeholder5)
        addSubview(rectangle11)
        placeholder5.snp.makeConstraints { make in
            make.top.equalTo(rectangle9.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.031)
        }
        rectangle10.snp.makeConstraints { make in
            make.top.equalTo(placeholder5.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.260)
            make.height.equalToSuperview().multipliedBy(0.047)
        }
        rectangle11.snp.makeConstraints { make in
            make.top.equalTo(rectangle10)
            make.centerY.height.equalTo(rectangle10)
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.521)
        }
        
        ///
        addSubview(placeholder6)
        addSubview(rectangle12)
        addSubview(rectangle13)
        placeholder6.snp.makeConstraints { make in
            make.top.equalTo(rectangle10.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.031)
        }
        rectangle12.snp.makeConstraints { make in
            make.top.equalTo(placeholder6.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.height.equalTo(rectangle10)
        }
        rectangle13.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalTo(rectangle12)
            make.width.equalTo(rectangle11)
        }
        
        ///
        addSubview(placeholder7)
        addSubview(rectangle14)
        placeholder7.snp.makeConstraints { make in
            make.top.equalTo(rectangle12.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.031)
        }
        rectangle14.snp.makeConstraints { make in
            make.top.equalTo(placeholder7.snp.bottom)
            make.left.right.equalTo(rectangle1)
            make.bottom.equalToSuperview()
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

extension EXSkeletonTradingOperate {
   private func removeSubviewsConstraints() {
       for v in subviews {
           v.snp.removeConstraints()
       }
    }
}
