//
//  EXContractEranMoneyAlertView.swift
//  Chainup
//
//  Created by ZYJ on 2023/12/18.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

enum EXContractEranMoneyAlertType {
    case position
    case profitAndLoss
    
    var introduce:String {
        switch self {
        case .position: //"已结算盈亏"; English: Settled profits and losses;
            return "cp_order_text14".ex_localized()
        default: //"已实现盈亏"; English: Realized profits and losses;
            return "cp_order_text99".ex_localized()
        }
    }
    
    var tips:String {
        switch self {
        case .position:
            return "cp_extra_text115".ex_localized()
        default:
            return "cp_extra_text108".ex_localized()
        }
    }
}

class EXContractEranMoneyAlertView: UIView {
    
    lazy var titles:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadBold
        
        return label
    }()
    
    lazy var detailInfo:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        
        return label
    }()
    lazy var containerView:UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .equalSpacing
        v.spacing = 20
        return v
    }()
    //总盈亏 English: Total profit and loss
    lazy var totalAmountCell:EXContractEranMoneyAlertViewCell = {
       let cell = EXContractEranMoneyAlertViewCell()
        return cell
    }()
    //资金费用 English: Capital expenses
    lazy var moneyFeeCell:EXContractEranMoneyAlertViewCell = {
        
        let cell = EXContractEranMoneyAlertViewCell()
        cell.leftLabel.text = "cp_position_text3".ex_localized()
        return cell
    }()
 
    //手续费 English: Handling fees
    lazy var handFeeCell:EXContractEranMoneyAlertViewCell = {
        let cell = EXContractEranMoneyAlertViewCell()
        cell.leftLabel.text = "cp_position_text2".ex_localized()
       
        return cell
        
    }()
    //平仓盈亏 English: Closing profit and loss
    lazy var earnOrLossCell:EXContractEranMoneyAlertViewCell = {
        let cell = EXContractEranMoneyAlertViewCell()
        cell.leftLabel.text = "cp_position_text4".ex_localized()
      
        return cell
        
    }()
    
    //持仓结算 English: Position settlement
    lazy var settleProfitCell:EXContractEranMoneyAlertViewCell = {
        let cell = EXContractEranMoneyAlertViewCell()
        cell.leftLabel.text = "cp_extra_text138".ex_localized()
       
        return cell
        
    }()
    
    //分摊 English: share
    lazy var shareAmountCell:EXContractEranMoneyAlertViewCell = {
        let cell = EXContractEranMoneyAlertViewCell()
        cell.leftLabel.text = "cp_position_text5".ex_localized()

        return cell
    }()
  
    private lazy var confirmButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_extra_text28".ex_localized(), titleFont: UIFont.ThemeFont.HeadBold, titleColor: UIColor.white)
        button.backgroundColor = UIColor.ThemeBtn.highlight
        button.corneradius = 4
        button.ext_SetAddTarget(self, #selector(clickConfirmButton))
        return button
    }()
    
    init(frame: CGRect,type:EXContractEranMoneyAlertType) {
 
        super.init(frame: frame)
        self.layer.cornerRadius = 12
        self.backgroundColor = UIColor.ThemeView.alertBg
        setUpViews()
        titles.text = "cp_extra_text137".ex_localized()
        totalAmountCell.leftLabel.text = type.introduce
        detailInfo.text = type.tips
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        
        exs_addSubViews([titles,detailInfo,totalAmountCell,confirmButton,containerView, totalAmountCell])
        containerView.addArrangedSubview(handFeeCell)
        containerView.addArrangedSubview(moneyFeeCell)
        containerView.addArrangedSubview(earnOrLossCell)
        containerView.addArrangedSubview(settleProfitCell)
        containerView.addArrangedSubview(shareAmountCell)
        titles.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        detailInfo.snp.makeConstraints { (make) in
            make.top.equalTo(titles.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        totalAmountCell.snp.makeConstraints { (make) in
            make.top.equalTo(detailInfo.snp.bottom).offset(30)
            make.left.right.equalTo(detailInfo)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(totalAmountCell.snp.bottom).offset(20)
            make.left.right.equalTo(detailInfo)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(containerView.snp.bottom).offset(30)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
            make.bottom.equalTo(-20)
        }
        
        
    }
    
    
    func configPostionModle(positionModel : EXSwapPositionModel?) {
        guard let marginCoin = positionModel?.ex_contractInfo?.marginCoin else {
            return
        }

          var text = positionModel?.profitRealizedAmount.toValuePrecision(withContract: positionModel?.instrument_id ?? 0) ?? ""
            text = profit(amout: text, positionModel: positionModel)
            totalAmountCell.rightLabel.setUpAndDownText(text)
            totalAmountCell.valueUnitLabel.text = marginCoin
        if let tagValue = Double((positionModel?.capitalFee ?? "0")) {

            var text = ""
            text = "\((positionModel?.capitalFee ?? "0").toValuePrecision(withContract: positionModel?.instrument_id ?? 0) )"
            text = profit(amout: text, positionModel: positionModel)
            moneyFeeCell.isHidden = tagValue == 0
            moneyFeeCell.rightLabel.text = text + " " + marginCoin
        }
        if let total_feeValue = Double(positionModel?.tradeFee ?? "0"){

            var text = ""
            text = positionModel?.tradeFee.toValuePrecision(withContract: positionModel?.instrument_id ?? 0) ?? ""
            text = profit(amout: text, positionModel: positionModel)

            handFeeCell.isHidden = total_feeValue == 0
            handFeeCell.rightLabel.text = text + " " + marginCoin
        }

        if let erarnOrLossValue = Double(positionModel?.closeProfit ?? "0") {
           var text =  "\(positionModel?.closeProfit.toValuePrecision(withContract: positionModel?.instrument_id ?? 0) ?? "")"
            text = profit(amout: text, positionModel: positionModel)

            earnOrLossCell.isHidden = erarnOrLossValue == 0

            earnOrLossCell.rightLabel.text = text + " " + marginCoin
        }

        if let value = Double(positionModel?.settleProfit ?? "0") {
            var text = ""
            text =  "\(positionModel?.settleProfit.toValuePrecision(withContract: positionModel?.instrument_id ?? 0) ?? "")"
            text = profit(amout: text, positionModel: positionModel)

            settleProfitCell.isHidden = value == 0

            settleProfitCell.rightLabel.text = text + " " + marginCoin
        }

        if let value = Double(positionModel?.shareAmount ?? "0") {
            var text = ""
            text =  "\(positionModel?.shareAmount.toValuePrecision(withContract: positionModel?.instrument_id ?? 0) ?? "")"
            text = profit(amout: text, positionModel: positionModel)
            shareAmountCell.isHidden = value == 0

            shareAmountCell.rightLabel.text = text + " " + marginCoin
        }
    }
    func profit(amout: String, positionModel: EXSwapPositionModel?) -> String{
        var rest = amout
        if let c = positionModel?.marginCoinPrecision, c != "" { //盈亏记录增加的字段 English: Fields added to profit and loss records
            rest = amout.toValuePrecision(Precision: c)
        }
        return rest.upAndDownText()
    }
    
    @objc func clickConfirmButton(){
        
        EXAlert.dismiss()
    }
    
    
    func getDecimalUp(handelStr:String,positionModel : EXSwapPositionModel?) -> String? {
        let unit = getValuetInt(positionModel: positionModel)
        
        if unit == 0 {
            return handelStr
        }
        
        let doubValue = Double(handelStr) ?? 0.0
        
        let roundle = doubValue.roundTo(places: unit)
        
        return String(roundle).exs_formatAmountUseDecimal(String(unit))
        
    }
    
    func getValuetInt(positionModel : EXSwapPositionModel?) -> Int {
        
        let value_unit = positionModel?.ex_contractInfo?.value_unit
        
        if let value_unit = value_unit,value_unit.contains(".") {
            
            let pointRange = (value_unit as NSString).range(of: ".")
            let subSting = (value_unit as NSString).substring(from: pointRange.location)
            
            return subSting.count - 1
            
        }
        return 0
        
    }
    

    
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0,Double(places))
        return (self * divisor).rounded() / divisor
    }
}

class EXContractEranMoneyAlertViewCell:UIView {
    
    lazy var leftLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        return label
        
    }()
    lazy var rightLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        
        return label
    }()
    lazy var valueUnitLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        generateCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func generateCell() {
        
        exs_addSubViews([leftLabel,rightLabel,valueUnitLabel])
        leftLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(valueUnitLabel.snp.left).offset(-3)
            make.centerY.equalTo(leftLabel)
        }
        valueUnitLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalTo(leftLabel)
        }
    }
}

