//
//  EXBtoCwithDrawRecordTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXBtoCwithDrawRecordTC: UITableViewCell {
    
    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    lazy var recordLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()
    
    lazy var stateLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        label.textAlignment = .right
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
        contentView.addSubViews([timeLabel,recordLabel,stateLabel,lineV])
        timeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(14)
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        let width = (SCREEN_WIDTH - 188) * 2 / 3
        recordLabel.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.height.equalTo(14)
            make.left.equalTo(timeLabel.snp.right).offset(15)
            make.centerY.equalToSuperview()
        }
        stateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(recordLabel.snp.right).offset(10)
            make.height.equalTo(14)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        lineV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(0.5)
            make.bottom.right.equalToSuperview()
        }
    }
    
    func setCell(_ entity : EXBtoCwithRecordListModel){
        timeLabel.text = DateTools.strToTimeString(entity.createdAtTime)
        recordLabel.text = entity.amount
        stateLabel.text = entity.status_text
    }
    
    func setCell(left:String,middle:String,right:String) {
        timeLabel.text = left
        recordLabel.text = middle
        stateLabel.text = right
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

class EXBtoCwithDrawRecordTV : UIView{
    
    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "charge_text_date".localized()
        return label
    }()
    
    lazy var recordLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var stateLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "charge_text_state".localized()
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubViews([timeLabel,recordLabel,stateLabel])
        timeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(14)
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        let width = (SCREEN_WIDTH - 188) * 2 / 3
        recordLabel.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.height.equalTo(14)
            make.left.equalTo(timeLabel.snp.right).offset(15)
            make.centerY.equalToSuperview()
        }
        stateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(recordLabel.snp.right).offset(10)
            make.height.equalTo(14)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
    
    func setRecordLabel(_ str : String){
        recordLabel.text = str
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
