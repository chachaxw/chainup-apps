//
//  EXSkeletonContractOperate.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

class EXSkeletonContractOperate: EXSkeletonTradingOperate {
    
    lazy var rectangle15: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle16: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle17: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var placeholder8: UIView = {
        let v = UIView()
        return v
    }()
    
    override func setupView() {
        super.setupView()
        removeSubviewsConstraints()
        rectangle1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.469)
            make.height.equalToSuperview().multipliedBy(0.072)
        }
        
        rectangle2.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalTo(rectangle1)
            make.centerY.height.equalTo(rectangle1)
        }
        
        placeholder.snp.makeConstraints { make in
            make.top.equalTo(rectangle1.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.019)
        }
        
        rectangle3.snp.makeConstraints { make in
            make.left.equalTo(rectangle1)
            make.top.equalTo(placeholder.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.260)
            make.height.equalToSuperview().multipliedBy(0.034)
        }
        rectangle4.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalTo(rectangle3)
            make.width.equalToSuperview().multipliedBy(0.521)
        }
        
        ////
        placeholder1.snp.makeConstraints { make in
            make.top.equalTo(rectangle3.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.024)
        }
        rectangle5.snp.makeConstraints { make in
            make.left.equalTo(rectangle1)
            make.top.equalTo(placeholder1.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.353)
        }
        
        ///
        placeholder2.snp.makeConstraints { make in
            make.top.equalTo(rectangle5.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.019)
        }
        rectangle6.snp.makeConstraints { make in
            make.top.equalTo(placeholder2.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.260)
            make.height.equalToSuperview().multipliedBy(0.038)
        }
        rectangle7.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalTo(rectangle6)
            make.width.equalToSuperview().multipliedBy(0.521)
        }
        
        ///
        placeholder3.snp.makeConstraints { make in
            make.top.equalTo(rectangle6.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.019)
        }
        rectangle8.snp.makeConstraints { make in
            make.top.equalTo(placeholder3.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.260)
            make.height.equalToSuperview().multipliedBy(0.029)
        }
        rectangle9.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalTo(rectangle8)
            make.width.equalToSuperview().multipliedBy(0.521)
        }
        
        ///
        placeholder4.snp.makeConstraints { make in
            make.top.equalTo(rectangle8.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.019)
        }
        rectangle10.snp.makeConstraints { make in
            make.top.equalTo(placeholder4.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.height.equalTo(rectangle8)
        }
        rectangle11.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalTo(rectangle10)
            make.width.equalTo(rectangle9)
        }
        
        ///
        placeholder5.snp.makeConstraints { make in
            make.top.equalTo(rectangle10.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.020)
        }
        rectangle12.snp.makeConstraints { make in
            make.top.equalTo(placeholder5.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.096)
        }
        
        ///
        placeholder6.snp.makeConstraints { make in
            make.top.equalTo(rectangle12.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.029)
        }
        rectangle13.snp.makeConstraints { make in
            make.top.equalTo(placeholder6.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.260)
            make.height.equalToSuperview().multipliedBy(0.029)
        }
        rectangle14.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalTo(rectangle13)
            make.width.equalToSuperview().multipliedBy(0.521)
        }
        
        
        ///
        addSubview(rectangle15)
        addSubview(rectangle16)
        placeholder7.snp.makeConstraints { make in
            make.top.equalTo(rectangle13.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.014)
        }
        rectangle15.snp.makeConstraints { make in
            make.top.equalTo(placeholder7.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.260)
            make.height.equalToSuperview().multipliedBy(0.029)
        }
        rectangle16.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalTo(rectangle15)
            make.width.equalToSuperview().multipliedBy(0.521)
        }
        
        ///
        addSubview(placeholder8)
        addSubview(rectangle17)
        placeholder8.snp.makeConstraints { make in
            make.top.equalTo(rectangle15.snp.bottom)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.029)
        }
        rectangle17.snp.makeConstraints { make in
            make.top.equalTo(placeholder8.snp.bottom)
            make.left.right.equalToSuperview()
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


extension EXSkeletonContractOperate {
    private func removeSubviewsConstraints() {
        for v in subviews {
            v.snp.removeConstraints()
        }
    }
}
