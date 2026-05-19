//
//  EXWaringView.swift
//  Chainup
//
//  Created by cwd on 2023/2/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
public class EXNoticeBarView: EXBaseView{
    //内容
    public var content: String = ""{
        didSet{
            tipLabel.text = content
        }
    }
    
    public override func setSubView() {
        configSubView()
    }
    
    func configSubView(){
        self.backgroundColor = UIColor.Ex.warning1.withAlphaComponent(0.1)
        self.addSubview(imageIV)
        self.addSubview(tipLabel)
        corneradius = 4
        imageIV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(10)
            make.centerY.equalToSuperview()
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(imageIV.snp.right).offset(8)
            make.top.equalToSuperview().offset(7)
            make.bottom.equalToSuperview().offset(-7)
            make.right.equalToSuperview().offset(-15)
        }
    }
    lazy var imageIV : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.image = EXKitBundle.image(named: "public_prompt")
        return arrowImmg
    }()
    lazy var tipLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.Ex.Harmony(size: 12, weight: .regular), textColor: UIColor.Ex.warning1, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        return label
    }()
  
}


