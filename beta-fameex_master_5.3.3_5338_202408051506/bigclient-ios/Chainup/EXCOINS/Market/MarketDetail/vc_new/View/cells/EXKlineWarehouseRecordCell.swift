//
//  EXKlineWarehouseRecordCell.swift
//  Chainup
//
//  Created by youbin on 2023/6/9.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXKlineWarehouseRecordCell: UITableViewCell {
    
    lazy var adjustmentV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .single
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "--"
        return v
    }()
    
    lazy var frontV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.isHidden = true
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "market_tab_etf_tran_old".localized()
        return v
    }()
    
    lazy var backV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.isHidden = true
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "market_tab_etf_tran_new".localized()
        return v
    }()
    
    lazy var networthV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "market_tab_etf_tran".localized()
        return v
    }()
    
    lazy var leverBeforeV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.subtitleLabel.numberOfLines = 2
        v.titleLabel.text = "market_tab_etf_before".localized()
        return v
    }()
    
    lazy var leverAfterV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.subtitleLabel.numberOfLines = 2
        v.titleLabel.text = "market_tab_etf_after".localized()
        return v
    }()
    
    
    lazy var stackV: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .fillEqually
        v.alignment = .fill
        v.spacing = 0
        v.addArrangedSubviews([adjustmentV, frontV, backV, networthV, leverBeforeV, leverAfterV])
        return v
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.ThemekLine.viewBg
        contentView.backgroundColor = UIColor.ThemekLine.viewBg
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        contentView.addSubViews([stackV])
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        stackV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    func bindRecordModel(_ model: EXETFRecordListItem) {
        var adjustment: String = "--"
        if model.type.count > 0 {
            if model.type == "0" {
                adjustment = "market_tab_etf_type_auto_no".localized()
            } else {
                adjustment = "market_tab_etf_type_auto".localized()
            }
        }
        
        adjustmentV.titleLabel.text = model.adjustDate + " " + adjustment
//        frontV.subtitleLabel.text = model.beforeLever + " " + model.quote
//        backV.subtitleLabel.text = model.afterLever + " " + model.quote
        networthV.subtitleLabel.text = model.netValue + " " + model.quote
        leverBeforeV.subtitleLabel.text = model.beforeLever
        leverAfterV.subtitleLabel.text  = model.afterLever
        
    }
}
