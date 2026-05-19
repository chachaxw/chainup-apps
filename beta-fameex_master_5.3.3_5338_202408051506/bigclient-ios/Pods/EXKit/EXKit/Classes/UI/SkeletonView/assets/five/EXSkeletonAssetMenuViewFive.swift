//
//  EXSkeletonAssetMenuViewFive.swift
//  EXKit
//
//  Created by bradjohn on 2023/8/28.
//

import UIKit

class EXSkeletonAssetMenuFiveCell: EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        addSubViews([rectangle1, rectangle2])
        rectangle1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.46)
            make.height.equalToSuperview().multipliedBy(0.521)
        }
        rectangle2.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.304)
        }
    }
    
}


class EXSkeletonAssetMenuViewFive: EXSkeletonComponents {
    
    lazy var topContainer: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var middleContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill2
        return v
    }()
    
    lazy var bottomContainer: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var rectangle5: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var rectangle6: EXSkeletonGradientView = {
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
    
    lazy var hLine: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var menu: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .horizontal, itemsCount: 4, columns: 4, minimumLineSpacing: 34, minimumInteritemSpacing: 0)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonAssetMenuFiveCell.self)
        return v
    }()
    
    override func setupView() {
        super.setupView()
        
        backgroundColor = .Ex.fill1
        
        addSubview(topContainer)
        addSubview(middleContainer)
        addSubview(bottomContainer)
        topContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.197)
        }
        middleContainer.snp.makeConstraints { make in
            make.top.equalTo(topContainer.snp.bottom)
            make.left.right.equalToSuperview()
        }
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(middleContainer.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.049)
        }
        
        topContainer.addSubViews([rectangle1, rectangle2])
        rectangle1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.35)
            make.width.equalToSuperview().multipliedBy(0.267)
        }
        rectangle2.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(rectangle1)
        }
        
        /////////////////////////////////////////////////////////////////
        middleContainer.addSubViews([placeholder, rectangle3, placeholder1,
                                     rectangle4, placeholder2, rectangle5, rectangle6])
        placeholder.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.105)
        }
        rectangle3.snp.makeConstraints { make in
            make.top.equalTo(placeholder.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.height.equalToSuperview().multipliedBy(0.092)
            make.width.equalToSuperview().multipliedBy(0.293)
        }
        placeholder1.snp.makeConstraints { make in
            make.left.equalTo(rectangle3)
            make.top.equalTo(rectangle3.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.039)
        }
        rectangle4.snp.makeConstraints { make in
            make.top.equalTo(placeholder1.snp.bottom)
            make.left.equalTo(rectangle3)
            make.width.equalToSuperview().multipliedBy(0.339)
            make.height.equalToSuperview().multipliedBy(0.131)
        }
        placeholder2.snp.makeConstraints { make in
            make.left.equalTo(rectangle4.snp.right)
            make.bottom.equalTo(rectangle4)
            make.width.equalToSuperview().multipliedBy(0.016)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        rectangle5.snp.makeConstraints { make in
            make.bottom.equalTo(rectangle4)
            make.left.equalTo(placeholder2.snp.right)
            make.height.equalToSuperview().multipliedBy(0.092)
            make.width.equalToSuperview().multipliedBy(0.213)
        }
        rectangle6.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(rectangle4.snp.top)
            make.height.equalToSuperview().multipliedBy(0.183)
            make.width.equalTo(rectangle6.snp.height)
        }
        
        middleContainer.addSubViews([placeholder3, hLine, placeholder4, menu])
        placeholder3.snp.makeConstraints { make in
            make.top.equalTo(rectangle4.snp.bottom)
            make.left.equalTo(rectangle4)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.104)
        }
        hLine.snp.makeConstraints { make in
            make.top.equalTo(placeholder3.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        placeholder4.snp.makeConstraints { make in
            make.top.equalTo(hLine.snp.bottom)
            make.left.equalTo(rectangle3)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.118)
        }
        menu.snp.makeConstraints { make in
            make.top.equalTo(placeholder4.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalToSuperview().multipliedBy(0.301)
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
