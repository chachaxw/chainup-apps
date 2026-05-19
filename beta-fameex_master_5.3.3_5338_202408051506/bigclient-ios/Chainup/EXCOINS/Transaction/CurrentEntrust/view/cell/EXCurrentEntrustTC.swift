//
//  EXCurrentEntrustTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXCurrentEntrustTC: UITableViewCell {
    
    private enum exResueIdentifier:String {
        case `default` = "EXCurrentEntrustTC"
        case tpsl = "EXCurrentEntrustTC_TPSL"
    }
    
    var positionType:EXLeverPositionType?
    
    typealias CancelBlock = (EXCurrentEntrustEntity) -> ()
    var cancelBlock : CancelBlock?
    
    var entity = EXCurrentEntrustEntity()
    
    lazy var typeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadRegular
        return label
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont().themeHNBoldFont(size: 16)
        return label
    }()
    
    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()

    lazy var cancelBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.layer.cornerRadius = 4
        btn.extUseAutoLayout()
        btn.backgroundColor = UIColor.ThemeView.bgTab
        btn.setTitle(LanguageTools.getString(key: "contract_action_cancle"), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickCancelBtn))
        btn.titleLabel?.font = UIFont.ThemeFont.BodyBold
        return btn
    }()
    
    lazy var priceView : EXCurrentEntrustDetailView = {
        let view = EXCurrentEntrustDetailView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var volumView : EXCurrentEntrustDetailView = {
        let view = EXCurrentEntrustDetailView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var actualView : EXCurrentEntrustDetailView = {
        let view = EXCurrentEntrustDetailView()
        view.extUseAutoLayout()
        view.titleLabel.textAlignment = .right
        view.volumLabel.textAlignment = .right
        return view
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
        let width = (SCREEN_WIDTH - 30) / 3
        contentView.addSubViews([typeLabel,nameLabel,timeLabel,priceView,volumView,actualView,cancelBtn,lineV])
        typeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(15)
            make.width.lessThanOrEqualTo(100)
            make.height.equalTo(18)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(typeLabel.snp.right).offset(5)
            make.height.equalTo(19)
            make.centerY.equalTo(typeLabel)
            make.right.equalTo(timeLabel.snp.left).offset(-10)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(12)
            make.centerY.equalTo(typeLabel)
            make.right.lessThanOrEqualTo(cancelBtn.snp.left).offset(-10)
//            make.right.equalTo(cancelBtn.snp.left).offset(-10)
        }
        priceView.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(35)
            make.top.equalTo(typeLabel.snp.bottom).offset(22)
        }
        volumView.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.centerX.equalToSuperview()
            make.height.equalTo(35)
            make.top.equalTo(typeLabel.snp.bottom).offset(22)
        }
        actualView.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(35)
            make.top.equalTo(typeLabel.snp.bottom).offset(22)
        }
        cancelBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(32)
            make.width.equalTo(72)
            make.centerY.equalTo(typeLabel)
        }
        lineV.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(0.5)
        }
    }
    
    func setCell(_ entity : EXCurrentEntrustEntity){
        let symbol = entity.baseCoin.lowercased()+entity.countCoin.lowercased()
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(symbol)
        if entity.status == "0" || entity.status == "1" || entity.status == "3"{
            if entity.type == "2"{//If it is a market price order, there is no cancellation button
                cancelBtn.isHidden = true
            }else{
                //Close Order List Cancel Order Button 1 Yes 0 No
                if entity.isCloseCancelOrder == "1"{
                    cancelBtn.isHidden = true
                }else{
                    cancelBtn.isHidden = false
                }
            }
            
            cancelBtn.isEnabled = true
            cancelBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
            cancelBtn.backgroundColor = UIColor.ThemeView.card2 // UIColor.ThemeView.bgGap
            
//            if entity.source == EXCurrentEntrustSourceType.quantGrid.rawValue {
//                cancelBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
//            }
            cancelBtn.setTitle("contract_action_cancle".localized(), for: UIControl.State.normal)
        }else{
            cancelBtn.backgroundColor = UIColor.clear
            cancelBtn.setTitle(entity.status_text, for: UIControl.State.normal)
            cancelBtn.isEnabled = false
        }
        typeLabel.textColor = entity.side == "SELL" ? UIColor.ThemekLine.down : UIColor.ThemekLine.up
        typeLabel.text = entity.side == "SELL" ? LanguageTools.getString(key: "otc_text_tradeObjectSell") : LanguageTools.getString(key: "otc_text_tradeObjectBuy")
        nameLabel.text = entity.getShowName()
        
        priceView.setView(LanguageTools.getString(key: "contract_text_price")+"(\(entity.countCoin.aliasName()))", volum: entity.price.formatAmountUseDecimal(coinmap.price))
        volumView.setView(LanguageTools.getString(key: "charge_text_volume")+"(\(entity.baseCoin.aliasName()))", volum: entity.volume.formatAmountUseDecimal(coinmap.volume))
        actualView.setView(LanguageTools.getString(key: "contract_text_dealDone")+"(\(entity.baseCoin.aliasName()))", volum: entity.deal_volume.formatAmountUseDecimal(coinmap.volume))
//        timeLabel.text = entity.created_at        
        timeLabel.text = DateTools.strToTimeString(entity.time_long,dateFormat: "MM/dd HH:mm:ss")
        self.entity = entity
    }

    //Cancel Order
    @objc func clickCancelBtn(){
        if entity.source == EXCurrentEntrustSourceType.quantGrid.rawValue {
            let normal = EXNormalAlert.init()
            normal.configSigleAlert(title: "",
                                    message: "quant_entrustCancel_error".localized(),
                                    sigleBtnTitle: "alert_common_i_understand".localized())
            EXAlert.showAlert(alertView: normal)
        }else {
            self.cancelBlock?(entity)
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


extension EXCurrentEntrustTC {
    class func registerAllTypes(in tableView:UITableView) {
        tableView.register(self.classForCoder(), forCellReuseIdentifier: exResueIdentifier.default.rawValue)
        tableView.register(self.classForCoder(), forCellReuseIdentifier: exResueIdentifier.tpsl.rawValue)
    }
    class func reuseIdentifier(for model:EXCurrentEntrustEntity) -> String {
        return (model.type == "3" ? exResueIdentifier.tpsl : exResueIdentifier.default).rawValue
    }
    class func rowHeight(for model:EXCurrentEntrustEntity, in tableView:UITableView) -> CGFloat {
        return model.type == "3" ? 126 : 104
    }
}

class EXCurrentEntrustDetailView : UIView{
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.MinimumRegular
        return label
    }()
    
    lazy var volumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyMedium
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([titleLabel,volumLabel])
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(12)
        }
        //+9
        volumLabel.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    func setView(_ title : String , volum : String){
        titleLabel.text = title
        volumLabel.text = volum
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

