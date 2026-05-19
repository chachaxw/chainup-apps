//
//  EXOTCHomeCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

/*
Coin: transaction currency
CurrentUserBanlance: Current logged in user's off site account balance
LimitTime: Transaction term unit: minutes
MaxTrade: Maximum transaction amount per transaction (amount)
MinTrade: Minimum transaction amount per transaction (amount)
PayCoin: Payment currency
Payment: Payment method (multiple use, separated) [5.23 Add suggestion: It is recommended to change the returned payment method string separated by parentheses into an array that contains several objects, including: value, title Chinese, icon address, account advertising payment account]
Price: unit price
Side: Advertising type SELL, BUY
Tip: prompt message
CompleteOrders: Number of order transactions (number of transactions)
CreditGrade: Credit rating (positive rating)
ImageUrl: Off site user profile
LoginStatus: Whether the user is online (1 online, 0 offline)
Turnover: Accumulated total transaction amount (historical transactions)
OtcNickName: User nickname
VolumeBalance: Remaining quantity
Status: 1. In Progress 2. In Progress 3. Expired 4. Closed
Status_ Text: Status Description
 */

class EXOTCHomeCell: UITableViewCell {
    
    @IBOutlet var avatarView: EXAvatarView!
    @IBOutlet var tradeCount: UILabel!
    @IBOutlet var tradeRate: UILabel!
    @IBOutlet var holdCoinNumber: UILabel!
    @IBOutlet var tradeLimitRange: UILabel!
    @IBOutlet var unitPriceTitle: UILabel!
    @IBOutlet var unitPrice: UILabel!
    @IBOutlet var confirmBtn: EXButton!
    @IBOutlet var payTypeContainer: UIStackView!
    
    var tradeType:OTCTradeType = .otcbuy
    typealias ActionBtnCallback = () -> ()
    var onConfirmCallback :ActionBtnCallback?
    typealias AvatarBtnCallback = () -> ()
    var avatarCallback :AvatarBtnCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        extSetCell(.Ex.fill2, selStyle: .none)
        unitPrice.font = .Ex.medium(16)
        holdCoinNumber.text = "charge_text_volume".localized()
        tradeLimitRange.text = "otc_text_priceLimit".localized()
        unitPriceTitle.text = "otc_text_price".localized()
        confirmBtn.titleLabel?.font = UIFont.ThemeFont.BodyBold
        confirmBtn.addTarget(self, action: #selector(onConfirmBtnAction), for: .touchUpInside)
    }
    
    @objc func onConfirmBtnAction(){
        onConfirmCallback?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindCellData(item:OTCSearchListItem,symbol:String) {
        
        if tradeType == .otcbuy {
            confirmBtn.setTitle("otc_action_buy".localized(), for: .normal)
        }else {
            confirmBtn.setTitle("otc_action_sell".localized(), for: .normal)
        }
        avatarView.bindAvatarInfo(name: item.otcNickName, avatarImg: item.imageUrl,userOnline: item.loginStatus == "1")
        avatarView.tapBtn.addTarget(self, action: #selector(avatarAction(_:)), for: .touchUpInside)
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
        
        holdCoinNumber.text = "charge_text_volume".localized() + " " + item.fmtVolumeBalance(symbol) + " " +  symbol.aliasName()
        tradeLimitRange.text = "otc_text_priceLimit".localized() + " " + item.paySymbol + item.fmtMin() + "-" + item.paySymbol + item.fmtMax()

        tradeCount.text = item.completeOrders
        tradeRate.text = item.creditGrade
        unitPrice.text = item.fmtPrice()
    }
    
    func bindMechantCellData(item:EXAdListItem) {
        //Merchants are all opposite
        if tradeType == .otcbuy {
            confirmBtn.setTitle("otc_action_sell".localized(), for: .normal)
        }else {
            confirmBtn.setTitle("otc_action_buy".localized(), for: .normal)
        }
        
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
        
        holdCoinNumber.text = "charge_text_volume".localized() + " " + item.volume + " " + item.coin
        tradeLimitRange.text = "otc_text_priceLimit".localized() + " " + item.minTrade + "-" + item.maxTrade
//
//        userName.text = item.otcNickName
//        tradeCount.text = item.completeOrders
//        tradeRate.text = item.creditGrade
        unitPrice.text = item.price
    }
    
    @objc func avatarAction(_ sender: Any) {
        avatarCallback?()
    }
    
    
}

