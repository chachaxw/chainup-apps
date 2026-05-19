//
//  EXSkeletonHomeBanner.swift
//  EXKit
//
//  Created by youbin on 2023/6/26.
//

import UIKit

class EXSkeletonHomeBanner: EXSkeletonComponents {
    
    enum EXSkeletonBannerMode {
        case large
        case aux
        case aux2
    }
    
    var mode: EXSkeletonBannerMode = .large {
        didSet {
            updateLayout(with: mode)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        clipsToBounds = true
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(rectangle3)
        addSubview(circle)
        updateLayout(with: .large)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.circle.roundCorners(corners: .allCorners, radius: CGRectGetHeight(self.circle.frame))
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

// MARK: update Layout
extension EXSkeletonHomeBanner {
    
   private func updateLayout(with mode: EXSkeletonBannerMode) {
       switch mode {
       case .large:
           _largeLayout()
       case .aux:
           _auxLayout()
       case .aux2:
           _aux2Layout()
       }
    }
    
    
   private func _largeLayout() {
        rectangle1.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(35)
            make.width.equalToSuperview().multipliedBy(0.324)
            make.height.equalTo(rectangle1.snp.width).multipliedBy(0.180)
        }
        
        rectangle2.snp.remakeConstraints { make in
            make.top.equalTo(rectangle1.snp.bottom).offset(14)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.437)
            make.height.equalTo(rectangle2.snp.width).multipliedBy(0.067)
        }
        
        rectangle3.snp.remakeConstraints { make in
            make.top.equalTo(rectangle2.snp.bottom).offset(10)
            make.left.equalTo(rectangle2)
            make.width.equalToSuperview().multipliedBy(0.230)
            make.height.equalTo(rectangle3.snp.width).multipliedBy(0.127)
        }
        
        circle.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-28)
            make.height.equalToSuperview().multipliedBy(0.606)
            make.width.equalTo(circle.snp.height)
        }
    }
    
   private func _auxLayout() {
       rectangle1.snp.remakeConstraints { make in
           make.left.equalToSuperview().offset(16)
           make.centerY.equalToSuperview()
           make.height.equalToSuperview().multipliedBy(0.543)
           make.width.equalTo(rectangle1.snp.height).multipliedBy(1.053)
       }
       rectangle2.snp.remakeConstraints { make in
           make.top.equalTo(rectangle1).offset(5)
           make.left.equalTo(rectangle1.snp.right).offset(12)
           make.width.equalToSuperview().multipliedBy(0.469)
           make.height.equalTo(rectangle2.snp.width).multipliedBy(0.075)
       }
       rectangle3.snp.remakeConstraints { make in
           make.bottom.equalTo(rectangle1).offset(-6)
           make.left.equalTo(rectangle2)
           make.width.equalToSuperview().multipliedBy(0.192)
           make.height.equalTo(rectangle3.snp.width).multipliedBy(0.152)
       }
       circle.snp.remakeConstraints { make in
           make.right.equalToSuperview().offset(-16)
           make.centerY.equalToSuperview()
           make.height.equalToSuperview().multipliedBy(0.286)
           make.width.equalTo(circle.snp.height)
       }
    }
    
    private func _aux2Layout() {
        rectangle1.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.equalToSuperview().multipliedBy(0.819)
            make.height.equalToSuperview().multipliedBy(0.110)
        }
        rectangle2.snp.remakeConstraints { make in
            make.top.equalTo(rectangle1.snp.bottom).offset(8)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.476)
            make.height.equalToSuperview().multipliedBy(0.110)
        }
        rectangle3.snp.remakeConstraints { make in
            make.left.equalTo(rectangle2)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalToSuperview().multipliedBy(0.295)
            make.height.equalToSuperview().multipliedBy(0.261)
        }
        circle.snp.remakeConstraints { make in
            make.bottom.equalTo(rectangle3)
            make.right.equalToSuperview().offset(-12)
            make.height.equalToSuperview().multipliedBy(0.182)
            make.width.equalTo(circle.snp.height)
        }
    }
    
}
