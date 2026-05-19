//
//  EXBaseView.swift
//  EXKit
//
//  Created by cwd on 2022/7/7.
//

import UIKit

open class EXBaseView: UIView{
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        setSubView()
        setData()
    }
    
    open func setSubView(){
        
    }
    open func setData(){
        
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
}
