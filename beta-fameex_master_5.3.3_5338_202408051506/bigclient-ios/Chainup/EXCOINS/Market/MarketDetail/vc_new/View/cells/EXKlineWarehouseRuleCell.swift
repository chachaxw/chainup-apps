//
//  EXKlineWarehouseRuleCell.swift
//  Chainup
//
//  Created by youbin on 2023/6/9.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXKlineWarehouseRuleCell: UITableViewCell {
    
    lazy var triggerV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .single
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.titleLabel.font = UIFont.ThemeFont.HeadBold
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "etf_notes_lever_next_if".localized()
        return v
    }()
    
    lazy var multipleV: UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.textColor = UIColor.ThemekLine.labcolorLite
        v.font = UIFont.ThemeFont.BodyMedium
        v.numberOfLines = 2
        v.text = String(format: "etf_notes_lever_manual".localized(), "--")
        return v
    }()
    
    lazy var networthV: EXNetworthView = {
        let v = EXNetworthView()
        v.extUseAutoLayout()
        v.extSetCornerRadius(4)
        v.backgroundColor = UIColor.ThemekLine.navBg
        v.valueLabel.textColor = UIColor.ThemekLine.labcolorHighlight
        v.valueLabel.text = "market_tab_etf_leverage_current".localized() + "--"
        return v
    }()
    
    lazy var melodyV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .single
        v.isBottomLine = false
        v.isTopLine    = true
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.titleLabel.font = UIFont.ThemeFont.BodyMedium
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "etf_notes_lever_auto".localized()
        return v
    }()

    lazy var warehouseLabel: UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.numberOfLines = 0
        v.textColor = UIColor.ThemekLine.labcolorLite
        v.font = UIFont.ThemeFont.HeadMedium
        v.text = "etf_notes_manual_lever_tran".localized()
        return v
    }()
    
    lazy var warehouseIntroLabel: UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.numberOfLines = 0
        v.textColor = UIColor.ThemekLine.labcolorMedium
        v.font = UIFont.ThemeFont.BodyMedium
        v.text = "etf_notes_manual_lever_tran_info".localized()
        return v
    }()
    
    lazy var gapView: UIView = {
        let v = UIView()
        v.extUseAutoLayout()
        v.backgroundColor = UIColor.ThemekLine.navBg
        return v
    }()
    
    
    lazy var sectionA: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var sectionB: UIView = {
        let v = UIView()
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
        contentView.addSubViews([sectionA, gapView, sectionB])
        sectionA.addSubViews([triggerV, multipleV, networthV, melodyV])
        sectionB.addSubViews([warehouseLabel, warehouseIntroLabel])
        
        sectionA.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16).priority(750)
            make.right.equalToSuperview().offset(-16).priority(750)
            make.height.equalTo(178)
        }
        gapView.snp.makeConstraints { make in
            make.top.equalTo(sectionA.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(10)
        }
        sectionB.snp.makeConstraints { make in
            make.top.equalTo(gapView.snp.bottom)
            make.left.equalTo(sectionA)
            make.right.equalTo(sectionA)
            make.bottom.equalToSuperview()
        }
        
        //Section A
        triggerV.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        melodyV.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        multipleV.snp.makeConstraints { make in
            make.top.equalTo(triggerV.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        networthV.snp.makeConstraints { make in
            make.top.equalTo(multipleV.snp.bottom)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualTo(melodyV.snp.top)
        }
        
        //Section B
        warehouseLabel.snp.makeConstraints { make in
            make.top.equalTo(gapView.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(22)
        }
        
        warehouseIntroLabel.snp.makeConstraints { make in
            make.top.equalTo(warehouseLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func bindNetworth(_ model: EXETFNetValueModel) {
        multipleV.text = String(format: "etf_notes_lever_manual".localized(), model.maxLeverValue)
        networthV.valueLabel.text = "market_tab_etf_leverage_current".localized() + ":" + model.realLeverValue
    }
    
    static func getHeightByContent(_ content:String) -> CGFloat {
        let introduceHeight = ceilf(Float(content.textSizeWithFont(UIFont.ThemeFont.BodyMedium, width: SCREEN_WIDTH - 36).height)) + 20
        return CGFloat(introduceHeight + 236)
    }
    
}


internal class EXNetworthView: UIView {
    
    lazy var valueLabel: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.ThemekLine.labcolorHighlight
        v.font = UIFont.ThemeFont.SecondaryMedium
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(6)
            make.right.equalToSuperview().offset(-6)
            make.bottom.equalToSuperview().offset(-4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

