//
//  EXSkeletonAssetsView.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

open class EXSkeletonAssetsView: UIView {
    
    lazy var assetsForm: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .horizontal, itemsCount: 6, columns: 5, minimumLineSpacing: 24, minimumInteritemSpacing: 20)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonAssetsAccountCell.self)
        return v
    }()
    
    lazy var balance: EXSkeletonAssetsBalance = {
        let v = EXSkeletonAssetsBalance()
        return v
    }()
    
    lazy var separator: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill1
        return v
    }()
    
    lazy var menu: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var coin1List: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .vertical, itemsCount: 3, columns: 1, minimumLineSpacing: 24, minimumInteritemSpacing: 24, itemHeight: 38)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonAssetsCoin1Cell.self)
        return v
    }()
    
    lazy var coin2List: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .vertical, itemsCount: 4, columns: 1, minimumLineSpacing: 24, minimumInteritemSpacing: 24, itemHeight: 20)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonAssetsCoin2Cell.self)
        return v
    }()
    
    lazy var backgroudContainer: UIView  = {
        let v = UIView()
        v.backgroundColor = .Ex.fill2
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        addSubview(assetsForm)
        assetsForm.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.equalToSuperview()
            make.height.equalTo(20)
        }
        
        addSubview(backgroudContainer)
        backgroudContainer.snp.makeConstraints { make in
            make.top.equalTo(assetsForm.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        backgroudContainer.addSubview(balance)
        balance.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(34)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(53)
        }
        
        backgroudContainer.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(balance.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
            make.height.equalTo(4)
        }
        
        backgroudContainer.addSubview(menu)
        menu.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(32)
        }
        
        backgroudContainer.addSubview(coin1List)
        coin1List.snp.makeConstraints { make in
            make.top.equalTo(menu.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(162)
        }
        
        backgroudContainer.addSubview(coin2List)
        coin2List.snp.makeConstraints { make in
            make.top.equalTo(coin1List.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
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
