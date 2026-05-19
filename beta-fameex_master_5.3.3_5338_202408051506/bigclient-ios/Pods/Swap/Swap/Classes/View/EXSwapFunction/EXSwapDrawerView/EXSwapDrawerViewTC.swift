//
//  EXSwapDrawerViewTC.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSwapDrawerViewTC: UITableViewCell {
    
    var entity = EXSwapItemModel()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.ext_UseAutoLayout()
        label.layoutIfNeeded()
        return label
    }()
   
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textAlignment = .right
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "--"
        return label
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var multipleLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textAlignment = .right
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "--"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        contentView.exs_addSubViews([nameLabel,priceLabel,multipleLabel,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(19)
        }
        multipleLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-110)
            make.height.equalTo(14)
            make.centerY.equalTo(nameLabel)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(16)
        }
        lineV.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
            make.left.equalToSuperview().offset(15)
        }
    }
    
    func setCell(_ itemModel : EXSwapItemModel , showMultiple : Bool = false){
        nameLabel.text = itemModel.ex_contractInfo?.showName()
        priceLabel.setUpAndDownText(itemModel.change_rate.toPercentString(2) )
        
        multipleLabel.text = itemModel.last_px
        multipleLabel.textColor = priceLabel.textColor
        nameLabel.textColor = fromKline ? UIColor.ThemekLine.labcolorLite : UIColor.ThemeLabel.colorLite
        self.contentView.backgroundColor = fromKline ? UIColor.ThemekLine.viewBg : UIColor.ThemeView.bg
        lineV.backgroundColor = fromKline ? UIColor.ThemekLine.viewSeperator : UIColor.ThemeView.seperator
        self.entity = itemModel
       
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
