//
//  EXSkeletonTradingView.swift
//  EXKit
//
//  Created by youbin on 2023/6/28.
//

import UIKit

open class EXSkeletonTradingView: UIView {
    
    lazy var coinBulletin: EXSkeletonTradingCoinBulletin = {
        let v = EXSkeletonTradingCoinBulletin()
        return v
    }()
    
    lazy var coinRisk: EXSkeletonTradingCoinRisk = {
        let v = EXSkeletonTradingCoinRisk()
        return v
    }()
    
    lazy var trend: EXSkeletonTradingTrend = {
        let v = EXSkeletonTradingTrend()
        return v
    }()
    
    lazy var operate: EXSkeletonTradingOperate = {
        let v = EXSkeletonTradingOperate()
        return v
    }()
    
    lazy var form: EXSkeletonTradingForm = {
        let v = EXSkeletonTradingForm()
        return v
    }()
    
    lazy var formFilter: EXSkeletonTradingFormFilter = {
        let v = EXSkeletonTradingFormFilter()
        return v
    }()
    
    lazy var formFilterTop: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var formFilterBottom: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    
    lazy var collectionView: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .vertical, itemsCount: 6, columns: 1, minimumLineSpacing: 16, itemHeight: 66)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonTradingCell.self)
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
        backgroundColor = .Ex.fill1
        addSubview(coinBulletin)
        coinBulletin.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(20)
        }
        
        addSubview(backgroudContainer)
        backgroudContainer.snp.makeConstraints { make in
            make.top.equalTo(coinBulletin.snp.bottom).offset(12);
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        backgroudContainer.addSubview(coinRisk)
        coinRisk.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(22)
        }
        
        backgroudContainer.addSubview(trend)
        trend.snp.makeConstraints { make in
            make.top.equalTo(coinRisk.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.equalToSuperview().multipliedBy(0.394)
            make.height.equalTo(374)
        }
        
        backgroudContainer.addSubview(operate)
        operate.snp.makeConstraints { make in
            make.top.equalTo(trend)
            make.right.equalToSuperview().offset(-16)
            make.left.equalTo(trend.snp.right).offset(12)
            make.height.equalTo(384)
        }
        
        backgroudContainer.addSubview(form)
        form.snp.makeConstraints { make in
            make.top.equalTo(operate.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(19)
        }
        
        backgroudContainer.addSubview(formFilterTop)
        formFilterTop.snp.makeConstraints { make in
            make.top.equalTo(form.snp.bottom).offset(9.5)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        backgroudContainer.addSubview(formFilter)
        formFilter.snp.makeConstraints { make in
            make.top.equalTo(form.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(20)
        }
        
        backgroudContainer.addSubview(formFilterBottom)
        formFilterBottom.snp.makeConstraints { make in
            make.top.equalTo(formFilter.snp.bottom).offset(9.5)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        backgroudContainer.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(formFilter.snp.bottom).offset(20)
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
