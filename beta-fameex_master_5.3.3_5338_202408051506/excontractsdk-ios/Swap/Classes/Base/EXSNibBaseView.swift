//
//  NibBaseView.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import SnapKit
public class EXSNibBaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.privateOnCreate()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.privateOnCreate()
    }
    var nibView = UIView()
    private func privateOnCreate(){
        
        let name = String(describing:type(of:self))
        nibView = UINib.init(nibName: name, bundle: EXSTools.SwapFrameworkBundle()).instantiate(withOwner: self, options: nil).first as! UIView
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
    public override func layoutSubviews() {
        self.setNeedsDisplay()
    }
    public func onCreate(){
    
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
