//
//  EXHistoryCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXHistoryCell: EXBaseCell {

    
//    @IBOutlet weak var iconWidth: NSLayoutConstraint!
//    @IBOutlet weak var coinName: UILabel! //18
//    @IBOutlet weak var status: UILabel! //12
//    @IBOutlet weak var timeLabel: UILabel! //12
//    @IBOutlet weak var timeDetail: UILabel! //14
//    @IBOutlet weak var loackNumberTitle: UILabel!
//    @IBOutlet weak var lockNumber: UILabel!
//    @IBOutlet weak var willIncomeTitle: UILabel!
//    @IBOutlet weak var gainRate: UILabel!
//    @IBOutlet weak var currentTitle: UILabel!
//    @IBOutlet weak var currentIncome: UILabel!
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        configSubView()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//       // super.init(coder: coder)
////        configSubView()
//    }
    
    
    override func setUpView(){
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        self.contentView.addSubViews([
        coinName,status,
        timeLabel,timeDetail,
        loackNumberTitle,lockNumber,
        willIncomeTitle,gainRate,
        currentTitle,currentIncome,arrow
        ])
        let lr:CGFloat = 10
        coinName.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(lr)
            make.top.equalToSuperview().offset(15)
        }
        status.snp.makeConstraints { make in
            make.centerY.equalTo(coinName)
            make.right.equalToSuperview().offset(-lr)
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(lr)
            make.top.equalTo(coinName.snp.bottom).offset(10)
        }
        timeDetail.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.right.equalToSuperview().offset(-lr)
        }
        
        loackNumberTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(lr)
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
        }
        lockNumber.snp.makeConstraints { make in
            make.centerY.equalTo(loackNumberTitle)
            make.right.equalToSuperview().offset(-lr)
        }
        willIncomeTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(lr)
            make.top.equalTo(loackNumberTitle.snp.bottom).offset(10)
        }
        gainRate.snp.makeConstraints { make in
            make.centerY.equalTo(willIncomeTitle)
            make.right.equalToSuperview().offset(-lr)
        }
        currentTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(lr)
            make.top.equalTo(willIncomeTitle.snp.bottom).offset(10)
          //  make.bottom.equalToSuperview().offset(-15)
        }
        currentIncome.snp.makeConstraints { make in
            make.centerY.equalTo(currentTitle)
            make.right.equalToSuperview().offset(-lr)
        }
        
        arrow.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-lr)
            make.centerY.equalTo(currentTitle)
            make.height.equalTo(10)
            make.width.equalTo(15)
        }
        
    }
    
    lazy var coinName: UILabel = {
        let label = UILabel(text:"x", font: UIFont.ThemeFont.H3Bold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var status: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel(text:"pos_string_lockBeginTime".localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var timeDetail: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var loackNumberTitle: UILabel = {
        let label = UILabel(text:"pos_string_lockNumber".localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var lockNumber: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var willIncomeTitle: UILabel = {
        let label = UILabel(text:"pos_string_interestRate".localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var gainRate: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()

    lazy var currentTitle: UILabel = {
        let label = UILabel(text:"pos_string_currentEran".localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var currentIncome: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var arrow : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.themeImageNamed(imageName: "home_enter")
        arrowImmg.isHidden = true
        return arrowImmg
    }()
    
    func setProtocolCellData(enity:EXPosHistoryItem){
//        self.iconWidth.constant = 15.0
        self.arrow.isHidden = false
        self.currentIncome.snp.updateConstraints { make in
            make.right.equalToSuperview().offset(-(10 + 15))
        }
        self.coinName.text = enity.baseCoin
        self.status.text = getStateString(state: enity.projectStatus)
        self.timeLabel.text = "pos_string_lockBeginTime".localized()
        self.timeDetail.text = enity.ltimetimeShow
        self.loackNumberTitle.text = "pos_string_lockNumber".localized() //Number of locked warehouses
        self.lockNumber.text = enity.totalAmount
        self.willIncomeTitle.text = "pos_string_interestRate".localized() //Annualized income
        self.gainRate.text = "\(enity.gainRate.decimalNumberWithDouble())\("%")"
        self.currentTitle.text = "pos_string_currentEran".localized() + (enity.gainCoin.isEmpty ? "" : "(\(enity.gainCoin))") //Current lockdown
        self.currentIncome.text = enity.totalUserGainAmount.decimalNumberWithDouble()
    }
    func setPostionCellData(enity:EXPosPositionHistoryItem)  {
        self.arrow.isHidden = true
        self.arrow.snp.updateConstraints { make in
            make.width.equalTo(0)
        }
//        self.iconWidth.constant = 0.0
        self.coinName.text = enity.baseCoin
        self.status.text  = nil
        self.timeLabel.text = "pos_string_dateEran".localized()
        self.loackNumberTitle.text = "pos_string_principal".localized()
        self.willIncomeTitle.text = "pos_string_interestRate".localized()
        self.currentTitle.text = "pos_string_earnNumber".localized() + (enity.gainCoin.isEmpty ? "" : "(\(enity.gainCoin))")
        self.timeDetail.text = enity.timeShow
        self.lockNumber.text = enity.baseAmount
        self.gainRate.text = "\(enity.gainRate.decimalNumberWithDouble())\("%")"
        self.currentIncome.text = enity.gainAmount.decimalNumberWithDouble()
        
    }
    
    
    func getStateString(state:String) -> String {
//0: Pending Start 1: Locked in Warehouse 2: Pending Interest 3: Interest In Progress 4: Interest End“
        if let iState = Int(state) {
            switch iState {
            case 0:
                return "pos_state_start".localized()
            case 1:
                return "pos_state_buying".localized()
            case 2:
                return "pos_state_waitInterest".localized()
            case 3:
                return "pos_state_InterestIng".localized()
            case 4:
                return "pos_state_InterestEnd".localized()
//5: Principal release 6: Full amount
            case 5:
                return "pos_state_release".localized()
            case 6:
                return "pos_state_fulled".localized()
                
            default:
                return ""
            }
        }
        return ""
        
        
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

