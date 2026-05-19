//
//  EXSkeletonAssetListFive.swift
//  EXKit
//
//  Created by bradjohn on 2023/8/29.
//

import UIKit


class EXSkeletonAssetListCellFive: EXSkeletonComponents {
    
    lazy var line: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
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
    
    override func setupView() {
        super.setupView()
        addSubViews([line, rectangle1, rectangle2,
                     rectangle3, rectangle4, rectangle5, rectangle6,
                     rectangle7, rectangle8, rectangle9])
        line.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        rectangle1.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.height.equalToSuperview().multipliedBy(0.12)
            make.width.equalToSuperview().multipliedBy(0.293)
        }
        
        rectangle2.snp.makeConstraints { make in
            make.top.equalTo(rectangle1.snp.bottom).offset(14)
            make.left.equalTo(rectangle1)
            make.width.equalToSuperview().multipliedBy(0.112)
            make.height.equalToSuperview().multipliedBy(0.08)
        }
        rectangle3.snp.makeConstraints { make in
            make.top.equalTo(rectangle2.snp.bottom).offset(8)
            make.left.equalTo(rectangle2)
            make.width.equalToSuperview().multipliedBy(0.267)
            make.height.equalToSuperview().multipliedBy(0.107)
        }
        rectangle4.snp.makeConstraints { make in
            make.top.equalTo(rectangle3.snp.bottom).offset(14)
            make.left.equalTo(rectangle3)
            make.width.equalTo(rectangle2)
            make.height.equalTo(rectangle2)
        }
        rectangle5.snp.makeConstraints { make in
            make.top.equalTo(rectangle4.snp.bottom).offset(8)
            make.left.equalTo(rectangle4)
            make.width.equalTo(rectangle3)
            make.height.equalTo(rectangle3)
        }
        /////////////////////////////////////////////////////
        rectangle6.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.height.width.equalTo(rectangle2)
        }
        
        rectangle7.snp.makeConstraints { make in
            make.right.equalTo(rectangle6)
            make.centerY.height.width.equalTo(rectangle3)
        }
        
        rectangle8.snp.makeConstraints { make in
            make.right.equalTo(rectangle6)
            make.centerY.height.width.equalTo(rectangle4)
        }
        
        rectangle9.snp.makeConstraints { make in
            make.right.equalTo(rectangle6)
            make.centerY.height.width.equalTo(rectangle5)
        }
    }
    
}

class EXSkeletonAssetListFive: EXSkeletonComponents {
    
    lazy var assetList: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .vertical, itemsCount: 4, columns: 1, minimumLineSpacing: 0, minimumInteritemSpacing: 0, itemHeight: 150)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonAssetListCellFive.self)
        return v
    }()
    
    override func setupView() {
        super.setupView()
        backgroundColor = .Ex.fill2
        
        addSubViews([placeholder, rectangle1, rectangle2, assetList])
        placeholder.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(placeholder.superview!.snp.width).multipliedBy(0.043)
        }
        rectangle1.snp.makeConstraints { make in
            make.top.equalTo(placeholder.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(18)
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        rectangle2.snp.makeConstraints { make in
            make.centerY.width.height.equalTo(rectangle1)
            make.right.equalToSuperview().offset(-16)
        }
        
        assetList.snp.makeConstraints { make in
            make.top.equalTo(rectangle1.snp.bottom).offset(16)
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
