//
//  EXKlineCoinBriefCell.swift
//  Chainup
//
//  Created by youbin on 2023/6/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXKlineCoinBriefCell: UITableViewCell {
    
    private var innerBrief: EXIntroduceModel?
    
    lazy var coinNameV: UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.numberOfLines = 0
        v.textColor = UIColor.ThemekLine.labcolorLite
        v.font = UIFont.ThemeFont.HeadBold
        return v
    }()
  
    lazy var timeV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "market_text_publishtime".localized()
        v.subtitleLabel.text = "--"
        return v
    }()
    
    lazy var totalV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "market_text_publishTotal".localized()
        v.subtitleLabel.text = "--"
        return v
    }()
    
    lazy var supportV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "market_text_currentTotal".localized()
        v.subtitleLabel.text = "--"
        return v
    }()
    
    lazy var webV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = .Ex.main1
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.subtitleLabel.numberOfLines = 2
        v.titleLabel.text = "market_text_coinHomepage".localized()
        v.subtitleLabel.text = "--"
        return v
    }()
    
    lazy var explorerV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = .Ex.main1
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.subtitleLabel.numberOfLines = 2
        v.titleLabel.text = "market_text_blockSearch".localized()
        v.subtitleLabel.text = "--"
        
        return v
    }()
    
    lazy var backStackV: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .fillEqually
        v.alignment = .fill
        v.spacing = 0
        v.addArrangedSubviews([coinNameV, timeV, totalV, supportV, webV, explorerV])
        return v
    }()
    
    
    lazy var introductionV: UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.numberOfLines = 0
        v.textColor = UIColor.ThemekLine.labcolorLite
        v.font = UIFont.ThemeFont.HeadBold
        v.text = "market_text_coinInfo".localized()
        return v
    }()
    
    lazy var briefV: UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.numberOfLines = 0
        v.textColor = UIColor.ThemekLine.labcolorMedium
        v.font = UIFont.ThemeFont.BodyMedium
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
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupView() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        contentView.addSubViews([backStackV, introductionV, briefV])
        backStackV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(276)
        }
        introductionV.snp.makeConstraints { make in
            make.top.equalTo(backStackV.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.height.equalTo(46)
        }
        briefV.snp.makeConstraints { make in
            make.top.equalTo(introductionV.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func bindViewModel() {
        
        webV.didClickedCallback = { [weak self] in
            guard let `self` = self else { return }
            guard let _brief = self.innerBrief else { return  }
            if _brief.officialUrl.count > 0 {
                _brief.officialUrl.copyToPasteBoard()
                EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
            }
        }
        explorerV.didClickedCallback = { [weak self] in
            guard let `self` = self else { return }
            guard let _brief = self.innerBrief else { return  }
            if  _brief.blockchainUrl.count > 0 {
                _brief.blockchainUrl.copyToPasteBoard()
                EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
            }
        }
    }
    
    func setCoinBrief(brief: EXIntroduceModel?) {
        self.innerBrief = brief
        guard let _brief = brief else { return  }
        if _brief.symbolName.count > 0 {
            coinNameV.text = _brief.symbolName + "(\(_brief.coinSymbol))"
        } else {
            coinNameV.text = _brief.coinSymbol.aliasName()
        }
        
        if _brief.publishTimeStr.count > 0 {
            timeV.subtitleLabel.text = _brief.publishTimeStr
        } else {
            timeV.subtitleLabel.text = "--"
        }
        
        if _brief.publishAmount.count > 0 {
            totalV.subtitleLabel.text = _brief.publishAmount
        } else {
            totalV.subtitleLabel.text = "--"
        }
        
        if _brief.currencyAmount.count > 0 {
            supportV.subtitleLabel.text = _brief.currencyAmount
        } else {
            supportV.subtitleLabel.text = "--"
        }
        
        if _brief.officialUrl.count > 0 {
            webV.subtitleLabel.text = _brief.officialUrl
        } else {
            webV.subtitleLabel.text = "--"
        }
        
        if _brief.blockchainUrl.count > 0 {
            explorerV.subtitleLabel.text = _brief.blockchainUrl
        } else {
            explorerV.subtitleLabel.text = "--"
        }
        
        if _brief.introduction.count > 0 {
            briefV.attributedText = _brief.introduction.ex_toNSAttributedString(font: .Ex.medium(12), textColor: .Ex.text1).ex_lineHeight()
        } else {
            briefV.attributedText = nil
            introductionV.text = ""
        }
    }
    
    func handleCopyAction(item:EXIntroduceItem) {
        if item.showCopy {
            item.contentLabel.text?.copyToPasteBoard()
            EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
        }
    }
    
    static func getHeightByContent(_ content:String) -> CGFloat {
        let introduceHeight = ceilf(Float(content.textSizeWithFont(UIFont.ThemeFont.HeadBold, width: SCREEN_WIDTH - 32).height))
        return CGFloat(introduceHeight + 276 + 46 + 10 + 10 + 50)
    }
    
}
