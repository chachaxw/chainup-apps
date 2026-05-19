//
//  EXSkeletonMarketView.swift
//  EXKit
//
//  Created by youbin on 2023/6/28.
//

import UIKit

open class EXSkeletonMarketView: UIView {
    
    lazy var form: EXSkeletonMarketForm = {
        let v = EXSkeletonMarketForm()
        return v
    }()
    
    lazy var fiter: EXSkeletonMarketFilter = {
        let v = EXSkeletonMarketFilter()
        return v
    }()
    
    lazy var collectionView: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .vertical, itemsCount: 20, columns: 1, minimumLineSpacing: 24, itemHeight: 32)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonMarketCell.self)
        return v
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView()  {
        backgroundColor = .Ex.fill2
        layer.masksToBounds = true
        layer.cornerRadius  = 15
        addSubview(form)
        form.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(20)
        }
        
        addSubview(fiter)
        fiter.snp.makeConstraints { make in
            make.top.equalTo(form.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(16)
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(fiter.snp.bottom).offset(24)
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
