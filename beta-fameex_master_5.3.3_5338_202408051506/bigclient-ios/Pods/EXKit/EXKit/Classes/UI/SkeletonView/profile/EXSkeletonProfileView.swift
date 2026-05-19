//
//  EXSkeletonProfileView.swift
//  EXKit
//
//  Created by youbin on 2023/6/29.
//

import UIKit

open class EXSkeletonProfileView: UIView {
    
    lazy var shortuct: EXSkeletonProfileShortuct = {
        let v = EXSkeletonProfileShortuct()
        return v
    }()
    
    lazy var personal: EXSkeletonProfilePersonal = {
        let v = EXSkeletonProfilePersonal()
        return v
    }()
    
    lazy var metaTag: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
        return v
    }()
    
    lazy var banner: EXSkeletonProfileBanner = {
        let v = EXSkeletonProfileBanner()
        return v
    }()
    
    lazy var menuList: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .vertical, itemsCount: 8, columns: 1, minimumLineSpacing: 32, itemHeight: 19)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonProfileCell.self)
        return v
    }()
    
    lazy var footer: EXSkeletonGradientView = {
        let v = EXSkeletonGradientView()
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
        addSubview(shortuct)
        addSubview(personal)
        addSubview(metaTag)
        addSubview(banner)
        addSubview(menuList)
        addSubview(footer)
        
        shortuct.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(shortuct.snp.width).multipliedBy(0.058)
        }
        personal.snp.makeConstraints { make in
            make.top.equalTo(shortuct.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(personal.snp.width).multipliedBy(0.146)
        }
        metaTag.snp.makeConstraints { make in
            make.centerY.equalTo(personal)
            make.right.equalToSuperview()
            make.height.equalTo(personal).multipliedBy(0.640)
            make.width.equalToSuperview().multipliedBy(0.293)
        }
        
        ///
        banner.snp.makeConstraints { make in
            make.top.equalTo(personal.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(44)
        }
        menuList.snp.makeConstraints { make in
            make.top.equalTo(banner.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(416)
        }
        footer.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-45)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(44)
        }
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.metaTag.roundCorners(corners: [.topLeft, .bottomLeft], radius: 100)
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
