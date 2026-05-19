//
//  EXAppMailTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXAppMailTC: UITableViewCell {
    
    var mailEntity:EXAppMailEntity?
    let pasteboard = UIPasteboard.general
    lazy var pointLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
//        label.font = UIFont.ThemeFont.BodyBold
//        label.textColor = UIColor.ThemeLabel.colorLite
        label.backgroundColor = UIColor.ThemeView.highlight
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.numberOfLines = 0
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .right
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    lazy var contentLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        label.numberOfLines = 0
        return label
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.contentView .addGestureRecognizer(longTap)
        contentView.addSubViews([pointLabel,titleLabel,timeLabel,contentLabel,lineV])
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(13)
            make.width.lessThanOrEqualToSuperview()
            make.height.greaterThanOrEqualTo(20)
        }
        pointLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(titleLabel)
            make.height.width.equalTo(6)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(2)
            make.height.equalTo(17)
            make.left.equalTo(titleLabel)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(timeLabel.snp.bottom).offset(12)
        }
        lineV.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp_bottom).offset(10)
            make.bottom.equalToSuperview().offset(-5)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(titleLabel)
            make.height.equalTo(0.5)
        }
    }
    
    @objc func longPress(sender:UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            
            if let content = self.mailEntity?.messageContent {
                //            common_tip_copySuccess
                self.pasteboard.string = content
                EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
            }
            
        }
    }
    func setCell(_ entity : EXAppMailEntity){
        self.mailEntity = entity
        pointLabel.isHidden = entity.status == "2"
        var color = UIColor.ThemeLabel.colorLite
        if entity.status == "2" {
            color = UIColor.ThemeLabel.colorMedium
        }
        titleLabel.textColor = color
        contentLabel.textColor = color
        titleLabel.text = entity.messageTitle
        timeLabel.text = entity.ctime
        contentLabel.text = entity.messageContent
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
