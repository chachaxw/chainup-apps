//
//  EXSkeletonHomeAuxBanner.swift
//  EXKit
//
//  Created by youbin on 2023/7/3.
//

import UIKit

class EXSkeletonHomeAuxBanner: UIView {
    
    var isAux2: Bool = false {
        didSet {
            updateLayout(with: isAux2)
        }
    }
    
    private lazy var aux: EXSkeletonHomeBanner = {
        let solidColor: UIColor = EXTheme.isDark ? .Ex.fill5 : .Ex.fill2
        let v = EXSkeletonHomeBanner()
        v.backgroundColor = .Ex.fill3
        v.layer.masksToBounds = true
        v.layer.cornerRadius  = 8
        v.isHidden = false
        v.mode = .aux
        v.rectangle1.skeletonSolid(with: solidColor)
        v.rectangle2.skeletonSolid(with: solidColor)
        v.rectangle3.skeletonSolid(with: solidColor)
        v.circle.skeletonSolid(with: solidColor)
        return v
    }()
    
    private lazy var aux2: EXSkeletonHomeBanner = {
        let solidColor: UIColor = EXTheme.isDark ? .Ex.fill5 : .Ex.fill2
        let v = EXSkeletonHomeBanner()
        v.backgroundColor = .Ex.fill3
        v.layer.masksToBounds = true
        v.layer.cornerRadius  = 8
        v.isHidden = true
        v.mode = .aux
        v.rectangle1.skeletonSolid(with: solidColor)
        v.rectangle2.skeletonSolid(with: solidColor)
        v.rectangle3.skeletonSolid(with: solidColor)
        v.circle.skeletonSolid(with: solidColor)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(aux)
        addSubview(aux2)
        updateLayout(with: false)
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


extension EXSkeletonHomeAuxBanner {
    private func updateLayout(with isAux2: Bool) {
        aux.snp.removeConstraints()
        aux2.snp.removeConstraints()
        aux.mode  = isAux2 ? .aux2 : .aux
        aux2.mode = isAux2 ? .aux2 : .aux
        if isAux2 {
            aux.isHidden  = false
            aux2.isHidden = false
            aux.snp.makeConstraints { make in
                make.left.centerY.height.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.490)
            }
            aux2.snp.makeConstraints { make in
                make.right.centerY.height.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.490)
            }
        } else {
            aux.isHidden  = false
            aux2.isHidden = true
            aux.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
