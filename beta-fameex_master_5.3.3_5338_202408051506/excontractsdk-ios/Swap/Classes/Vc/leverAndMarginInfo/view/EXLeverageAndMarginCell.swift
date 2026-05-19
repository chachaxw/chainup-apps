//
//  EXLeverageAndMarginCell.swift
//  Swap
//
//  Created by cwd on 2023/3/31.
//

import UIKit
import EXKit
class EXLeverageAndMarginCell: EXBaseTableViewCell{
    var coin = ""
    var item = EXLeverMarginItem(){
        didSet{
            let v = String(format: "PositionBraket".ex_localized(), self.coin)
            positionNominalValueTitleLabel.text = v
            positionNominalValueVlaueLabel.text = item.minPositionValue.showInComma() + " - " + item.maxPositionValue.showInComma()
            maxLeverageValueLabel.text = item.maxLever
            maintainMarginRatioVlaueLabel.text = item.minMarginRate
            levelLabel.text = item.level
        }
    }
    override func setUpView() {
        self.contentView.addSubview(container)
        container.addSubViews([
            positionNominalValueTitleLabel,
            line0,
            positionNominalValueVlaueLabel,
            maxLeverageLabel,
            line1,
            maxLeverageValueLabel,
            maintainMarginRatio,
            line2,
            maintainMarginRatioVlaueLabel,
            markImg,
            levelLabel
        ])
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview() //.offset(-16)

        }
        positionNominalValueTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(15)
        }
        
        positionNominalValueVlaueLabel.snp.makeConstraints { make in
            make.top.equalTo(positionNominalValueTitleLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(23)
        }
        
        maxLeverageLabel.snp.makeConstraints { make in
            make.top.equalTo(positionNominalValueVlaueLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(15)
        }
    
        maxLeverageValueLabel.snp.makeConstraints { make in
            make.top.equalTo(maxLeverageLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(23)
        }
        maintainMarginRatio.snp.makeConstraints { make in
            make.top.equalTo(maxLeverageValueLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(15)
        }
       
        maintainMarginRatioVlaueLabel.snp.makeConstraints { make in
            make.top.equalTo(maintainMarginRatio.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(23)
        }
        
        markImg.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(43)
            make.height.equalTo(37.5)
        }
        
        levelLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4.5)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(18)
        }
        
        
        let t1 =  String(format: "PositionBraket".ex_localized(),"usdt")
        let w1 = t1.textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width: EXSCREEN_WIDTH).width + 1
        
        let t2 = "MaxLeverage".ex_localized()
        let w2 = t2.textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width: EXSCREEN_WIDTH).width
        
        let t3 = "MtncMgRt".ex_localized()
        let w3 = t3.textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width: EXSCREEN_WIDTH).width
        line0.frame = CGRect(x: 12, y: 32, width: w1, height: 1)
        line1.frame = CGRect(x: 12, y: 100, width: w2, height: 1)
        line2.frame = CGRect(x: 12, y: 164, width: w3, height: 1)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        line0.drawDashLine()
        line1.drawDashLine()
        line2.drawDashLine()
        
    }
    //MARK: lazy
    lazy var container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.newbg
        v.layer.cornerRadius = 10
        v.layer.masksToBounds = true
        return v
    }()
    
    ///持仓（USDT名义价值） English: /Position (USDT nominal value)
    lazy var positionNominalValueTitleLabel: UILabel = {
        let label = UILabel(text:"PositionBraket".ex_localized(), font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        let tap = UITapGestureRecognizer.init(target: self, action:#selector(click(tap:)))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        label.tag = 0
        return label
    }()
    
   
    lazy var positionNominalValueVlaueLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.H3Medium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    ///最大杠杆倍数 English: /Maximum leverage ratio
    lazy var maxLeverageLabel: UILabel = {
        let label = UILabel(text:"MaxLeverage".ex_localized(), font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        let tap = UITapGestureRecognizer.init(target: self, action:#selector(click(tap:)))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        label.tag = 1
        return label
         
        
    }()
   
    lazy var maxLeverageValueLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.H3Medium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    /// 维持保证金率 English: /Maintain margin ratio
    lazy var maintainMarginRatio: UILabel = {
        let label = UILabel(text:"MtncMgRt".ex_localized(), font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        let tap = UITapGestureRecognizer.init(target: self, action:#selector(click(tap:)))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        label.tag = 2
        return label
    }()
   
    lazy var maintainMarginRatioVlaueLabel: UILabel = {
        let label = UILabel(text:"5%", font: UIFont.ThemeFont.H3Medium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    
    lazy var markImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.svg_themeImageNamed(imageName: "mark")
        return arrowImmg
    }()
    
    
    lazy var levelLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyBold, textColor: UIColor.white, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var line0: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var line1: UIView = {
        let v = UIView()
        return v
    }()
    lazy var line2: UIView = {
        let v = UIView()
        return v
    }()
    
    
    @objc func click(tap:UITapGestureRecognizer){
        let tagIndex = tap.view!.tag
        let tititeArr = [String(format: "PositionBraket".ex_localized(), self.coin),"MaxLeverage","MtncMgRt"]
        let infoArr = ["PBtips","MLtips","MMRtips"]
        
        let alert = EXCommonAlert()
        alert.configAlert(title: tititeArr[tagIndex].ex_localized(), message: infoArr[tagIndex].ex_localized(),bottomOnlyOneBtn: true) { _ in
            EXAlert.dismiss()
        }
        EXAlert.showAlert(alertView: alert)
        
    }
}


class EXLeverageAndMarginFooter: EXCOCustomBaseView{
    var dataModel = EXLeverMarginData() {
        didSet{
            let time = Double(dataModel.mTime) ?? 0
            self.titleLabel.text = "RulesLastUpdateT".ex_localized() + ":" + EXSDateTools.timeStampToString(time/1000) + " (GMT+08:00)"
        }
    }
    
    override func setSubView() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(33)
            make.right.equalToSuperview().offset(-33)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(15)
        }
    }
    
    ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"RulesLastUpdateT".ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        return label
    }()
}

