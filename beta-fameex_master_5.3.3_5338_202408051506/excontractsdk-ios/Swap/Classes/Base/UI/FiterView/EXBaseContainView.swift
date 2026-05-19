//
//  EXBaseContainView.swift
//  Chainup
//
//  Created by cwd on 2022/11/6.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit

class EXBaseContainView: EXCOCustomBaseView{
    static let segmentHeight:CGFloat = 46
    var currentIdx:Int = 0
    var names = [String]()
    var segmentIndicatorType:EXCOSegmentIndicatorStyle = .mask {
        didSet{
            if segmentIndicatorType == .line {
                linesegmentedDataSource.titles = names
                self.segmentedView.dataSource = linesegmentedDataSource
                self.segmentedView.indicators = [self.lineIndicatorLienView]
            }
            
        }
    }
    
     //MARK: lifecycle
    override func setSubView() {
        configContents()
    }
    
    //MARK: lazy
    let segmentedView = JXSegmentedView()
    lazy var maskSegmentedDataSource: EKMaskSegmentDatasource = {
        let source = EKMaskSegmentDatasource()
        return source
    }()
    lazy var maskIndicatorLienView: EKMaskSegmentIndicator = {
        let view = EKMaskSegmentIndicator()
        return view
    }()
    
   
    lazy var linesegmentedDataSource: EKContractIndicatorSegmentDatasource = {
        let source = EKContractIndicatorSegmentDatasource()
        return source
    }()
    
    lazy var lineIndicatorLienView: EKIndicatorSegmentIndicator = {
        let view = EKIndicatorSegmentIndicator()
        return view
    }()
    
}


extension EXBaseContainView {
    
    func configContents() {
        names = configTitles()
        if names.count > 0 {
            maskSegmentedDataSource.titles = names
            self.segmentedView.dataSource = maskSegmentedDataSource
            self.segmentedView.indicators = [self.maskIndicatorLienView]
        }
        self.segmentedView.delegate = self
        self.segmentedView.frame = CGRect(x: 4, y:self.frame.minY + 8, width: Device_W - 8, height: EXBaseContainView.segmentHeight)
        self.addSubview(self.segmentedView)
    }
    func segmentIndicatorStyle() -> EXCOSegmentIndicatorStyle{
        return EXCOSegmentIndicatorStyle.mask
    }
}

extension EXBaseContainView:JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if currentIdx != index {
            currentIdx = index
            self.indexDidChanged()
        }
    }
}

extension EXBaseContainView:EXCOBaseContainerVcProtocol{
    @objc func configTitles() -> [String] {
       return [""]
    }
    
    @objc func indexDidChanged(){
        
    }
    
}
