//
//  EXBaseView.swift
//  EXKit
//
//  Created by cwd on 2022/7/7.
//

import UIKit

open class EXBaseView: UIView{
    
    open var contentInsets: UIEdgeInsets = .zero {
        didSet {
            guard contentView.superview != nil else { return }
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
        }
    }
    
    open lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setSubView()
        setData()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setSubView(){
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentInsets)
        }
        
    }
    open func setData(){
        
    }
    
}
