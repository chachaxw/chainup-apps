//
//  EXBaseContainerVc.swift
//  Chainup
//
//  Created by cwd on 2022/7/21.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit

protocol EXBaseContainerVcProtocol{
    //title
    func configTitles() -> [String]
}

class EXBaseContainerVc: BaseVC,EXBaseContainerVcProtocol{
    
    var currentIdx:Int = 0
    var names = [String]()
    
    lazy var marketSkeleton: EXSkeletonMarketView = {
        let v = EXSkeletonMarketView()
        return v
    }()

    let segmentedView = JXSegmentedView()
    lazy var segmentedDataSource: EKMaskSegmentDatasource = {
        let source = EKMaskSegmentDatasource()
        return source
    }()
    lazy var indicatorLienView: EKMaskSegmentIndicator = {
        let view = EKMaskSegmentIndicator()
        return view
    }()
    
    func indexDidChanged(){}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configContents()
    }
    
    func configContents() {
        segmentedDataSource.titles = names
        self.segmentedView.dataSource = segmentedDataSource
        self.segmentedView.indicators = [self.indicatorLienView]
        self.segmentedView.delegate = self
        self.segmentedView.frame = CGRect(x: 4, y:self.view.frame.minY + 8, width: SCREEN_WIDTH - 8, height: segmentHeight)
        self.view.addSubview(self.segmentedView)
    }
    
    func updateTabbars(with titles: [String]) {
        if titles.count > 0 {
            self.removeMarketSketelon { [weak self] in
                guard let self = self else { return  }
                self.names = titles
                self.segmentedDataSource.titles = self.names
                self.segmentedView.dataSource = self.segmentedDataSource
                self.segmentedView.reloadData()
            }
        }
    }
}

extension EXBaseContainerVc:JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if currentIdx != index {
            currentIdx = index
            self.indexDidChanged()
        }
    }
}

extension EXBaseContainerVc{
    @objc func configTitles() -> [String] {
        return ["test"]
    }
}

// MARK: add/remove sketelon
extension EXBaseContainerVc {
    
    func addMarketSketelon() {
        guard marketSkeleton.superview == nil else { return }
        view.addSubview(marketSkeleton)
        view.bringSubviewToFront(marketSkeleton)
        marketSkeleton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func removeMarketSketelon(with completion: (() -> Void)? = nil) {
        guard marketSkeleton.superview != nil else { return }
        UIView.animate(withDuration: 0.25, delay: 0.3) {
            self.marketSkeleton.alpha = 0.0
        } completion: { _ in
            self.marketSkeleton.removeFromSuperview()
            self.marketSkeleton.alpha = 1.0
            completion?()
        }
    }
}
