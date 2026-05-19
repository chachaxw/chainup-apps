//
//  EXKeyValueView.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/4/1.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
enum EXKeyValueViewStyle{
    case horizontal
    case vertical
}
class EXKeyValueView: EXCustomBaseView {

    var data = ExThreeColumnDataModel(){
        didSet{
            titleLabel.text = data.title
            detailTitleLabel.text = data.content
        }
    }
    
    var style: EXKeyValueViewStyle = .horizontal{
        didSet{
            switch style {
            case .vertical:
                titleLabel.snp.remakeConstraints { make in
                    make.top.left.right.equalToSuperview()
                    make.height.equalTo(15)
                }
                detailTitleLabel.snp.remakeConstraints { make in
                    make.left.right.bottom.equalToSuperview()
                }
            default:
                break
            }
        }
    }
    
    var textAlignment = NSTextAlignment.right{
        didSet{
            titleLabel.textAlignment = textAlignment
            detailTitleLabel.textAlignment = textAlignment
        }
    }
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.numberOfLines = 0
        return label
    }()
    
    lazy var detailTitleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        label.numberOfLines = 0
        return label
    }()
    
    override func setSubView() {
        self.addSubViews([titleLabel,detailTitleLabel])
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        detailTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
}
