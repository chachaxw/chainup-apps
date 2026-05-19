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

protocol EXCOBaseContainerVcProtocol{
    //标题 English: title
    func configTitles() -> [String]
    func indexDidChanged() ->()
}

enum EXCOSegmentIndicatorStyle{
    case mask
    case line
}

public class EXCOBaseContainerVc: UIViewController{
    static let segmentHeight:CGFloat = 44
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
    let segmentedView = JXSegmentedView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ThemeView.bg
        configContents()
    }
    
    
    func configContents() {
        names = configTitles()
        if names.count > 0 {
            maskSegmentedDataSource.titles = names
            self.segmentedView.dataSource = maskSegmentedDataSource
            self.segmentedView.indicators = [self.maskIndicatorLienView]
        }
        self.segmentedView.delegate = self
        self.segmentedView.frame = CGRect(x: 4, y:self.view.frame.minY + 8, width: Device_W - 8, height: EXCOBaseContainerVc.segmentHeight)
        self.view.addSubview(self.segmentedView)
    }
    func segmentIndicatorStyle() -> EXCOSegmentIndicatorStyle{
        return EXCOSegmentIndicatorStyle.mask
    }
    
    //MARK: lazy
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

extension EXCOBaseContainerVc:JXSegmentedViewDelegate {
    
    public func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if currentIdx != index {
            currentIdx = index
            self.indexDidChanged()
        }
    }
    @objc public func segmentedView(_ segmentedView: JXSegmentedView, didScrollSelectedItemAt index: Int) {
        
    }
    @objc public func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
       
    }

}

extension EXCOBaseContainerVc:EXCOBaseContainerVcProtocol{
    @objc func configTitles() -> [String] {
       return [""]
    }
    
    @objc func indexDidChanged(){
        
    }
    
}

