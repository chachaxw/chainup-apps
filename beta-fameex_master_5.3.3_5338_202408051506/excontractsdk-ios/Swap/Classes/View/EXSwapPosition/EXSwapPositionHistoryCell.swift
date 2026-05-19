//
//  EXSwapPositionHistoryCell.swift
//  Chainup
//
//  Created by ZYJ on 2023/12/18.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import MapKit
//盈亏记录cell English: Profit and loss record cell
class EXSwapPositionHistoryCell: UITableViewCell {
    
    var type: EXSwapTransactionType = .current
    //MARK: lazy
    /// 多-空类型 English: /Multiple empty type
    lazy var dealTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadBold, textColor: nil, alignment: NSTextAlignment.center)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    /// 合约名称 English: /Contract Name
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    /// 创建时间 English: /Creation time
    lazy var timeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    /// 合约类型 English: /Contract type
    lazy var contractTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.colorHighlight, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.backgroundColor = UIColor.Ex.main3
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    
    /// 开仓均价 English: /Average opening price
    lazy var openAverageView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        view.ext_UseAutoLayout()
        view.setLeftText("cp_order_text7".ex_localized())
        return view
    }()
//    /// 平仓均价 English: /Closing average price
//    lazy var closeAverageView: SLSwapHorDetailView = {
//        let view = SLSwapHorDetailView()
//        view.ext_UseAutoLayout()
//        view.setLeftText("cp_content_text25".ex_localized())
//        view.isHidden = true
//        return view
//    }()
    /// 已实现盈亏 English: /Realized profit and loss
    lazy var realizeView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        view.setLeftText("cp_order_text99".ex_localized())
        view.showDashline = true
        view.clickMiddleBtnBlock = { [weak self] in
            let eranView = EXContractEranMoneyAlertView(frame: CGRect.zero, type: .profitAndLoss)
            eranView.configPostionModle(positionModel: self?.positionModel)
            EXAlert.showAlert(alertView: eranView)
        }
        return view
    }()
    
    lazy var volumeView:SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        view.setLeftText("cp_calculator_text38".ex_localized())
        return view
    }()
    /// 底部分隔视图 English: /Bottom Divided View
    lazy var bottomMarginView: UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    var positionModel:EXSwapPositionModel?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        self.backgroundColor = UIColor.ThemeView.card1
        self.contentView.backgroundColor = UIColor.ThemeView.card1
        self.contentView.exs_addSubViews([dealTypeLabel,nameLabel,timeLabel, volumeView,openAverageView,realizeView,contractTypeLabel,bottomMarginView])
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
    private func initLayout() {
        let horMargin = 16
        dealTypeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(horMargin)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dealTypeLabel.snp.right).offset(5)
            make.height.equalTo(20)
            make.centerY.equalTo(dealTypeLabel)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-horMargin)
            make.height.equalTo(12)
            make.centerY.equalTo(nameLabel)
        }
        
        contractTypeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dealTypeLabel)
            make.height.equalTo(16)
            make.width.equalTo(68)
            make.top.equalTo(dealTypeLabel.snp.bottom).offset(5)
        }
        realizeView.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.left.equalToSuperview() //.offset(15)
            make.right.equalToSuperview() //.offset(-15)
            make.top.equalTo(contractTypeLabel.snp.bottom).offset(16)
        }
        openAverageView.snp.makeConstraints { (make) in
            make.top.equalTo(realizeView.snp.bottom).offset(12)
            make.left.right.height.equalTo(realizeView)
        }
        //数量 English: quantity
        volumeView.snp.makeConstraints { (make) in
            make.top.equalTo(openAverageView.snp.bottom).offset(12)
            make.left.right.height.equalTo(realizeView)
        }
//        bottomMarginView.snp.makeConstraints { (make) in
//            make.width.equalTo(realizeView)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
        bottomMarginView.snp.makeConstraints { (make) in
                    make.height.equalTo(0.5)
                    make.bottom.equalToSuperview()
                    make.left.equalToSuperview().offset(16)
                    make.right.equalToSuperview().offset(-16)
                }
    }
    
    func updateCell(model: EXSwapPositionModel) {
        self.positionModel = model
        var info = EXContractsModel()
        if model.ex_contractInfo != nil {
            info = model.ex_contractInfo!
        }
        if type == .profitRecord { //盈亏记录  中有些合约废弃根据id 找不到对应的ex_contractInfo，需要 单独处理 English: Some contracts in the profit and loss records are abandoned, and the corresponding ex cannot be found based on the ID_ ContractInfo, needs to be processed separately
            info.quote_coin = model.quote
            info.margin_coin = model.marginCoin
            info.marginCoin = model.marginCoin
            self.positionModel?.ex_contractInfo  = info
        }
        var color = UIColor.ThemekLine.down
        if model.side == .openMore {
            color = UIColor.ThemekLine.up
            dealTypeLabel.text = "cp_order_text6".ex_localized()
        } else {
            dealTypeLabel.text = "cp_order_text15".ex_localized()
        }
        dealTypeLabel.textColor = color
        nameLabel.text = info.showName()
        var contractType = ""
        if model.position_type  == .allType{
            contractType = "cp_contract_setting_text1".ex_localized()
        } else {
            contractType = "cp_contract_setting_text2".ex_localized()
        }
        contractTypeLabel.text = contractType + "\(model.leverageLevel)X"
        contractTypeLabel.titleResizeSize()
        timeLabel.text = EXSDateTools.strToTimeString(model.mtime)
        openAverageView.setLeftText(String(format:"%@(%@)","cp_order_text7".ex_localized(),info.quote_coin))
        volumeView.setLeftText(String(format: "%@(%@)", "cp_calculator_text38".ex_localized(),info.volumeUnit))
        realizeView.setLeftText(String(format:"%@(%@)","cp_order_text99".ex_localized(),info.margin_coin))
//        if self.type == .profitRecord { //盈亏记录 English: Profit and loss records
            nameLabel.text = model.contractOtherName
            openAverageView.setRightText(model.openEndPrice.toValuePrecision(Precision:model.pricePrecision))
            //已盈亏使用 marginCoinPrecision English: Profit and loss using marginCoinPrecision
            realizeView.rightLabel.setUpAndDownText(model.profitRealizedAmount.toValuePrecision(Precision:model.marginCoinPrecision))
            let vol = info.volumeDisplay(vol: model.cur_qty)
            volumeView.setRightText(vol)
//        }else{
//            openAverageView.setRightText(model.avg_open_px.toPricePrecision(withContractID: model.instrument_id))
//            realizeView.setRightText(model.profitRealizedAmount.toValuePrecision(withContract: model.instrument_id))
//            volumeView.setRightText(model.curQtyVolume)
//        }

    }
}


