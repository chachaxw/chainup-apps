//
//  EXSkeletonHomeView.swift
//  EXKit
//
//  Created by youbin on 2023/6/26.
//

import UIKit
import SkeletonView
import SnapKit

open class EXSkeletonHomeView: UIView {
    
    open var isAux2: Bool = false {
        didSet {
            auxHeightConstraint?.update(offset: isAux2 ? 88 : 70)
            associateBannerContainer.isAux2 = isAux2
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var auxHeightConstraint: Constraint?
    
    lazy var searchBarContainer: EXSkeletonHomeShortuct = {
        let v = EXSkeletonHomeShortuct()
        return v
    }()
    
    lazy var topContainer: EXSkeletonHomeBanner = {
        let backgroundColor: UIColor = EXTheme.isDark ? .Ex.fill3 : .Ex.fill2
        let solidColor: UIColor = EXTheme.isDark ? .Ex.fill5 : .Ex.fill3
        let v = EXSkeletonHomeBanner()
        v.mode = .large
        v.backgroundColor = backgroundColor
        v.rectangle1.skeletonSolid(with: solidColor)
        v.rectangle2.skeletonSolid(with: solidColor)
        v.rectangle3.skeletonSolid(with: solidColor)
        v.circle.skeletonSolid(with: solidColor)
        return v
    }()
    
    lazy var bulletinContainer: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        v.backgroundColor = .Ex.fill2
        return v
    }()
    
    lazy var bottomContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill2
        return v
    }()
    
    /////////
    lazy var menuContainer: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .horizontal, itemsCount: 5, columns: 5, minimumLineSpacing: 28.25)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonHomeMenuCell.self)
        return v
    }()
    
    lazy var associateBannerContainer: EXSkeletonHomeAuxBanner = {
        let v = EXSkeletonHomeAuxBanner()
        return v
    }()
    
    lazy var referralsContainer: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .horizontal, itemsCount: 3, columns: 3, minimumLineSpacing: 29)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonHomeReferralsCell.self)
        return v
    }()
    
    lazy var rankTitleContainer: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .horizontal, itemsCount: 4, columns: 6, minimumLineSpacing: 10)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonGradientView.self)
        return v
    }()
    
    lazy var rankFilterContainer: EXSkeletonHomeRankFilter = {
        let v = EXSkeletonHomeRankFilter()
        return v
    }()
    
    lazy var rankContainer: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .vertical, itemsCount: 6, columns: 1, itemHeight: 56)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonHomRankCell.self)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .Ex.fill1
        addSubview(searchBarContainer)
        addSubview(topContainer)
        addSubview(bulletinContainer)
        addSubview(bottomContainer)
        
        searchBarContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(EXSafeStatusHeight)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(44)
        }
        topContainer.snp.makeConstraints { make in
            make.top.equalTo(searchBarContainer.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(topContainer.snp.width).multipliedBy(0.385)
        }
        bulletinContainer.snp.makeConstraints { make in
            make.top.equalTo(topContainer.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(bulletinContainer.snp.width).multipliedBy(0.047)
        }
        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(bulletinContainer.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        //////
        bottomContainer.addSubview(menuContainer)
        menuContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(menuContainer.snp.width).multipliedBy(0.117)
        }
        
        bottomContainer.addSubview(associateBannerContainer)
        associateBannerContainer.snp.makeConstraints { make in
            make.top.equalTo(menuContainer.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            self.auxHeightConstraint = make.height.equalTo(70).constraint
        }
        
        bottomContainer.addSubview(referralsContainer)
        referralsContainer.snp.makeConstraints { make in
            make.top.equalTo(associateBannerContainer.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(58)
        }
        
        bottomContainer.addSubview(rankTitleContainer)
        rankTitleContainer.snp.makeConstraints { make in
            make.top.equalTo(referralsContainer.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(20)
        }
        
        bottomContainer.addSubview(rankFilterContainer)
        rankFilterContainer.snp.makeConstraints { make in
            make.top.equalTo(rankTitleContainer.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(14)
        }
        
        bottomContainer.addSubview(rankContainer)
        rankContainer.snp.makeConstraints { make in
            make.top.equalTo(rankFilterContainer.snp.bottom).offset(8)
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



extension EXSkeletonHomeView {
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.topContainer.roundCorners(corners: .allCorners, radius: 10)
        self.bulletinContainer.roundCorners(corners: .allCorners, radius: 5)
        self.bottomContainer.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
}
