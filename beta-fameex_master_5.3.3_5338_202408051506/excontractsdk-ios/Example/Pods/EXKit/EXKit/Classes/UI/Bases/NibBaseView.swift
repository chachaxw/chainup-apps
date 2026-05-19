//
//  NibBaseView.swift
//  Chainup
//
//  Created by liuxuan on 2019/1/10.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

open class NibBaseView: UIView {
    /// bundle of xib
    open class func xibBundle() -> Bundle? { nil }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.privateOnCreate()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.privateOnCreate()
    }
    public var nibView = UIView()
    private func privateOnCreate(){
        
        var name = String(describing:type(of:self))
        if name == "EXSmallKlineView" {
            name = ""
        }
        nibView = UINib.init(nibName: name, bundle: Bundle(for: type(of: self))).instantiate(withOwner: self).first as! UIView
//        self.backgroundColor = UIColor.ThemeView.bg 
//        nibView.translatesAutoresizingMaskIntoConstraints = false
        self .addSubview(nibView)
        nibView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.onCreate()
    }
    public override var backgroundColor: UIColor? {
        didSet {
            nibView.backgroundColor = backgroundColor
        }
        
    }
    open override func layoutSubviews() {
        self.setNeedsDisplay()
    }
    open func onCreate(){
    
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
