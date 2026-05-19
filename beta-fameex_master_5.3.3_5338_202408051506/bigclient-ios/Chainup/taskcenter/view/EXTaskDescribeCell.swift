//
//  EXTaskDescribeCell.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXTaskDescribeCell: EXBaseCell{
    var content: String? {
        didSet{
            
            let message = NSMutableAttributedString(string:content ?? "")
            let para = NSMutableParagraphStyle()
            para.minimumLineHeight = 20
            para.lineSpacing = 0
            let color:UIColor = UIColor.Ex.text2
            message.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: message.length))
            message.addAttribute(.font, value: UIFont.Ex.regular(14), range: NSRange(location: 0, length: message.length))
            message.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: message.length))
            contentLabel.attributedText = message
            contentLabel.textAlignment = .left
            
        }
    }
    
    override func setUpView() {
        self.contentView.addSubview(bgview)
        bgview.addSubview(contentLabel)
        bgview.backgroundColor = .Ex.fill3
        bgview.corneradius = 4
        bgview.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-20)
        }
        contentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    let bgview = UIView()
    ///desc
    lazy var contentLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(14), textColor: .Ex.text2, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.extUseAutoLayout()
        return label
    }()
}
