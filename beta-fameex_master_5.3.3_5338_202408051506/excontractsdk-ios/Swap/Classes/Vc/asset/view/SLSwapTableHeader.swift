//
//  SLSwapTableHeader.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/1/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Foundation

class SLSwapTableHeader: UIView {
    
    let toolBar: SLAssetToolBar = {
        let tool = SLAssetToolBar()
        return tool
    }()
    
    lazy var assetsInfoView: EXCOAssetsInfoView = {
        let view = EXCOAssetsInfoView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(toolBar)
        
        addSubview(assetsInfoView)
        assetsInfoView.frame = CGRect.init(x: 0, y: 0, width: self.width, height: 72)
        toolBar.frame = CGRect.init(x: 0, y: 72, width: self.width, height: self.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
