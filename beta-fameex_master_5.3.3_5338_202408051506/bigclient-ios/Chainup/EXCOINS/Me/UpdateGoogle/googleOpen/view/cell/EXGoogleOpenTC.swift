//
//  EXGoogleOpenTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXGoogleOpenTC: UITableViewCell {
    
    typealias OnValueChangeCallback = (Bool) -> ()
    var valueChangeCallback : OnValueChangeCallback?
    
    lazy var nameLabel : UILabel = {
        let label = UILabel(font: .Ex.regular(14), textColor: .Ex.text1)
        label.extUseAutoLayout()
        label.text = "common_action_activeGoogle".localized()
        return label
    }()
    
    lazy var switchV : EXSwitchV6 = {
        let view = EXSwitchV6(frame: .zero, style: .large)
        view.extUseAutoLayout()
        view.isOn = true
        view.layoutIfNeeded()
        view.onValueChangeCallback = {[weak self]b in
            self?.valueChangeCallback?(b)
        }
        return view
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = .Ex.fill4
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([nameLabel,switchV,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.right.equalTo(switchV.snp.left).offset(-10)
            make.height.equalTo(20)
        }
        switchV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        lineV.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
