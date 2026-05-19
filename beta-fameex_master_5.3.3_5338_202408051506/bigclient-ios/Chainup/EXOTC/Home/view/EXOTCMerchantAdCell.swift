//
//  EXOTCMerchantAdCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXOTCMerchantAdCell: UITableViewCell {

    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var holdCoinLabel: UILabel!
    @IBOutlet var tradeLimitRange: UILabel!
    @IBOutlet var unitPriceTitle: UILabel!
    @IBOutlet var unitPrice: UILabel!
    @IBOutlet var payTypeContainer: UIStackView!
    @IBOutlet var confirmBtn: EXFlatBtn!
    
    var tradeType:OTCTradeType = .none
    typealias ActionBtnCallback = () -> ()
    var onConfirmCallback :ActionBtnCallback?

    override func awakeFromNib() {
        super.awakeFromNib()
        symbolLabel.font = self.themeHNMediumFont(size: 14)
        unitPrice.font = UIFont.ThemeFont.HeadBold
        holdCoinLabel.text = "charge_text_volume".localized()
        tradeLimitRange.text = "otc_text_priceLimit".localized()
        unitPriceTitle.text = "otc_text_price".localized()
        confirmBtn.addTarget(self, action: #selector(onConfirmBtnAction), for: .touchUpInside)
    }
    
    @objc func onConfirmBtnAction(){
        onConfirmCallback?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func bindMechantCellData(item:EXAdListItem) {
        //Merchants are all opposite
        if tradeType == .otcbuy {
            confirmBtn.setTitle("otc_action_sell".localized(), for: .normal)
        }else {
            confirmBtn.setTitle("otc_action_buy".localized(), for: .normal)
        }
        symbolLabel.text = item.coin.aliasName()
        
        if item.payments.count > 0 {
            self.payTypeContainer.removeAllArrangedSubviews()
            for item in item.payments {
                let imageView = UIImageView.init()
                imageView.yy_setImage(with: URL.init(string:item.icon), placeholder: nil)
                payTypeContainer.addArrangedSubview(imageView)
                imageView.snp.makeConstraints { (make) in
                    make.width.height.equalTo(16)
                }
            }
        }
        
        holdCoinLabel.text = "charge_text_volume".localized() + " " + item.volume + " " + item.coin.aliasName()
        tradeLimitRange.text = "otc_text_priceLimit".localized() + " " + item.paySymbol + item.fmtMin() + "-" + item.paySymbol + item.fmtMax()
        unitPrice.text = item.fmtPrice()
    }
    
}

