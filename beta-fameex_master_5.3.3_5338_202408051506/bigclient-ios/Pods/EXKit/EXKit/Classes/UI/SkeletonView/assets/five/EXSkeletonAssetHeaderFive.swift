//
//  EXSkeletonAssetHeaderFive.swift
//  EXKit
//
//  Created by bradjohn on 2023/8/28.
//

import UIKit


class EXSkeletonAssetHeaderFiveCell : EXSkeletonComponents {
    
    override func setupView() {
        super.setupView()
        let baseColor = UIColor.Ex.skeleton.first!.withAlphaComponent(0.09)
        let secondaryColor = UIColor.Ex.skeleton.last!.withAlphaComponent(0.289)
        rectangle1.skeletonGradient(baseColor: baseColor, secondaryColor: secondaryColor)
        addSubview(rectangle1)
        rectangle1.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

public class EXSkeletonAssetHeaderFive: EXSkeletonComponents {
    
   public lazy var gradient: EXGradientView = {
        let v = EXGradientView()
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
    
    lazy var tabBarsView: EXSkeletonCollectionView = {
        let v = EXSkeletonCollectionView()
        v.configuration = .init(scrollDirection: .horizontal,
                                itemsCount: 4,
                                columns: 4,
                                minimumLineSpacing: 34,
                                minimumInteritemSpacing: 0)
        v.configurateCell = .init(edgeInsets: .zero, cell: EXSkeletonAssetHeaderFiveCell.self)
        return v
    }()
    
    override func setupView() {
        super.setupView()
        
        let baseColor = UIColor.Ex.skeleton.first!.withAlphaComponent(0.09)
        let secondaryColor = UIColor.Ex.skeleton.last!.withAlphaComponent(0.289)
        rectangle1.skeletonGradient(baseColor: baseColor, secondaryColor: secondaryColor)
        rectangle2.skeletonGradient(baseColor: baseColor, secondaryColor: secondaryColor)
        rectangle3.skeletonGradient(baseColor: baseColor, secondaryColor: secondaryColor)
        rectangle4.skeletonGradient(baseColor: baseColor, secondaryColor: secondaryColor)
        
        addSubview(gradient)
        addSubview(rectangle1)
        addSubview(rectangle2)
        addSubview(placeholder)
        addSubview(rectangle3)
        addSubview(placeholder1)
        addSubview(rectangle4)
        addSubview(tabBarsView)
        addSubview(placeholder2)
        
        gradient.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rectangle1.snp.makeConstraints { make in
            make.top.equalTo(navBarHeight() + 24)
            make.left.equalToSuperview().offset(16)
            make.height.equalToSuperview().multipliedBy(0.097)
            make.width.equalToSuperview().multipliedBy(0.213)
        }
        rectangle2.snp.makeConstraints { make in
            make.top.equalTo(navBarHeight() + 12)
            make.right.equalToSuperview().offset(-16)
            make.height.equalToSuperview().multipliedBy(0.109)
            make.width.equalTo(rectangle2.snp.height)
        }
        placeholder.snp.makeConstraints { make in
            make.left.equalTo(rectangle1)
            make.top.equalTo(rectangle1.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.024)
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        rectangle3.snp.makeConstraints { make in
            make.left.equalTo(rectangle1)
            make.top.equalTo(placeholder.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.174)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        placeholder1.snp.makeConstraints { make in
            make.left.equalTo(rectangle3.snp.right)
            make.bottom.equalTo(rectangle3)
            make.height.equalTo(rectangle3).multipliedBy(0.1)
            make.width.equalToSuperview().multipliedBy(0.011)
        }
        rectangle4.snp.makeConstraints { make in
            make.left.equalTo(placeholder1.snp.right)
            make.bottom.equalTo(rectangle3)
            make.height.equalTo(rectangle3).multipliedBy(0.5)
            make.width.equalTo(rectangle3).multipliedBy(0.533)
        }
        
        tabBarsView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalToSuperview().multipliedBy(0.097)
        }
        placeholder2.snp.makeConstraints { make in
            make.top.equalTo(tabBarsView.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalTo(tabBarsView.snp.left)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.079)
        }
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        super.layoutSkeletonIfNeeded()
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
