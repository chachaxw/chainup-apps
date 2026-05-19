//
//  EXSkeletonAssetsViewFive.swift
//  EXKit
//
//  Created by bradjohn on 2023/8/28.
//

import UIKit


open class EXSkeletonAssetsViewFive: UIView {
    
   open lazy var header: EXSkeletonAssetHeaderFive = {
        let v = EXSkeletonAssetHeaderFive()
        return v
    }()
    
    lazy var menuView: EXSkeletonAssetMenuViewFive = {
        let v = EXSkeletonAssetMenuViewFive()
        return v
    }()
    
    lazy var assetList: EXSkeletonAssetListFive = {
        let v = EXSkeletonAssetListFive()
        return v
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(165)
        }
        
        addSubview(menuView)
        menuView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(menuView.snp.width).multipliedBy(0.541)
        }
        
        addSubview(assetList)
        assetList.snp.makeConstraints { make in
            make.top.equalTo(menuView.snp.bottom)
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
