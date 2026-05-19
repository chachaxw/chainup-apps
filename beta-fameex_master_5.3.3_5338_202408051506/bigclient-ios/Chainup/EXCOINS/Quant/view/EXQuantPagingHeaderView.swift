//
//  EXQuantPagingHeaderView.swift
//  Chainup
//
//  Created by bradjohn on 2024/1/1.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXQuantPagingHeaderView: UIView {
    
    var heightCallBack: ((CGFloat) -> Void)?
    
    var contentInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 0, right: 16) {
        didSet {
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
            updateLayout()
        }
    }
    
    private lazy var contentView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .fill
        return v
    }()
    
    lazy var topView: UIView = {
        let v = UIView()
        v.extUseAutoLayout()
        return v
    }()
    
    private lazy var priceLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(18), textColor: .Ex.kLine.fall1)
        return v
    }()
    
    private lazy var fiatLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(12), textColor: .Ex.text2)
        return v
    }()
    
    private lazy var highLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(12), textColor: .Ex.text2)
        return v
    }()
    
    
    private lazy var lowLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(12), textColor: .Ex.text2)
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate()  {
        addSubview(contentView)
        contentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
        contentView.addArrangedSubviews([topView])
        topView.addSubViews([priceLabel, fiatLabel, highLabel, lowLabel])
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(21)
        }
        fiatLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(2)
            make.left.equalTo(priceLabel)
            make.bottom.equalToSuperview()
            make.height.equalTo(16)
        }
        highLabel.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.right.equalToSuperview()
            make.left.greaterThanOrEqualTo(priceLabel.snp.right).offset(8)
            make.height.equalTo(priceLabel)
        }
        lowLabel.snp.makeConstraints { make in
            make.centerY.height.equalTo(fiatLabel)
            make.right.equalToSuperview()
            make.left.greaterThanOrEqualTo(fiatLabel.snp.right).offset(8)
        }
        highLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        lowLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        updateLayout()
    }
    
    
    private func updateLayout() {
        layoutIfNeeded()
        var height: CGFloat = 0
        height += contentInsets.top
        height += contentInsets.bottom
        height += CGRectGetHeight(topView.frame)
        heightCallBack?(height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


extension EXQuantPagingHeaderView {
    
    func updateTict(tict: EXKlineTictModel?, entity: CoinMapEntity?) {
        if let tict = tict, let tick = tict.tick, let entity = entity {
            
            priceLabel.textColor = tick.roseTxtColor
            priceLabel.text = tick.close.formatAmountUseDecimal(entity.price)
            
            lowLabel.text = LanguageTools.getString(key: "kline_text_low".localized()) + "  " +  tick.low.formatAmountUseDecimal(entity.price)
            highLabel.text = LanguageTools.getString(key: "kline_text_high".localized()) + "  " +  tick.high.formatAmountUseDecimal(entity.price)

            let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(entity.marketName)
            if let rst = NSString.init(string:tick.close).multiplyingBy1(t.1, decimals: t.2){
                fiatLabel.text = "≈\(t.0)" + rst
            }
        } else {
            
        }
    }
}
