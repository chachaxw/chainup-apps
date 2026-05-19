//
//  RecommendCVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//recommendation

import UIKit

class RecommendCVC: UICollectionViewCell {
    
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    lazy var nameLabel : UILabel = {//name
        let label = UILabel()
        label.extUseAutoLayout()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var priceLabel : UILabel = {//price
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "--"
        label.font = UIFont.ThemeFont.H3Medium
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var rmbLabel : UILabel = {//Equivalent to money
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "--"
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    //Increase
    lazy var amplitudeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.text = "--"
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    lazy var titleContainer:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.bg
        return v
    }()
    
    lazy var hlineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        view.isHidden = true
        return view
    }()
    
    lazy var kLine : EXHomeKlineView = {
        let view = EXHomeKlineView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.bg
        view.isHidden = true
        return view
    }()
    
    var wsVm = EXKlineWsVm()
    
    var xdataarr : [CGFloat] = []
    var ydataarr : [CGFloat] = []
    var entity : HomeRecommendedEntity = HomeRecommendedEntity()
    var recommendModel:EXHomeTicker = EXHomeTicker()
    
    func setonewithnormal(){

        backView.addSubViews([titleContainer, priceLabel,rmbLabel,hlineV,kLine])
        titleContainer.addSubViews([nameLabel,amplitudeLabel])
        
        amplitudeLabel.textAlignment = .left
        priceLabel.textAlignment = .left
        rmbLabel.textAlignment = .left
        
        hlineV.snp.makeConstraints { (make) in
            make.centerY.right.equalToSuperview()
            make.height.equalTo(79)
            make.width.equalTo(0.5)
        }
        
        backView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleContainer.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(16)
            make.bottom.equalToSuperview()
        }
        
        amplitudeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.left.equalTo(nameLabel.snp.right)//.offset(2)
            make.right.lessThanOrEqualToSuperview()
            make.centerY.equalTo(nameLabel)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-MARGIN_LEFT)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.height.equalTo(22)
        }
        
        rmbLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-MARGIN_LEFT)
            make.height.equalTo(14)
            make.top.equalTo(priceLabel.snp.bottom).offset(2)
        }
    }
    
    func setonewithmomo(){
        backView.addSubViews([nameLabel,priceLabel,rmbLabel,amplitudeLabel,hlineV,kLine])

        nameLabel.textColor = UIColor.ThemeLabel.colorLite
        nameLabel.textAlignment = .center
        
        priceLabel.textAlignment = .center
        
        amplitudeLabel.textAlignment = .center
        
        rmbLabel.textAlignment = .center
        
        hlineV.isHidden = false
        
        backView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(107)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(14)
        }
        
        amplitudeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.left.equalTo(nameLabel.snp.right)
            make.right.equalToSuperview()
            make.top.equalTo(priceLabel.snp.bottom).offset(5)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.height.equalTo(19)
        }
        
        rmbLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(14)
            make.top.equalTo(amplitudeLabel.snp.bottom).offset(5)
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backView)
        contentView.backgroundColor = UIColor.ThemeView.bg
        backView.backgroundColor = UIColor.ThemeView.bg
        
        if EXHomeViewModel.isUIStatusNormal() {
            
            if EXHomeViewModel.homepageStyle() == .momo {
                setonewithmomo()
            }else {
                setonewithnormal()
            }
            
        }else if EXHomeViewModel.status() == .two{
            setonewithnormal()
        }
    }
    
    func bindCellRecommends(_ model: EXHomeTicker) {
        self.recommendModel = model
        if model.showName == ""{
            nameLabel.text = "--"
            priceLabel.text = "--"
            rmbLabel.text = "--"
            amplitudeLabel.text = "--"
             return
        }
        nameLabel.text = model.showName
        rmbLabel.text = model.rmb
        
        amplitudeLabel.textColor = model.backColor
        amplitudeLabel.text = model.rose
        priceLabel.textColor = model.backColor
        //Small mobile phone, if there is a Decimal separator and the total length is>8 digits, intercept
        if UIScreen.main.bounds.width < 414 {
            if model.close.count > 8,model.close.contains(".") {
                var fixColose = model.close.prefix(8)
                if let last = fixColose.last,last == "." {
                    fixColose.removeLast()
                }
                priceLabel.text = String(fixColose)
            }else {
                priceLabel.text = model.close

            }
        }else {
            priceLabel.text = model.close
        }

//        if EXHomeViewModel.status() == .two{
//            handleWsVM(model.symbol)
//        }
    }
    
    func setCell(_ entity : HomeRecommendedEntity){
        self.entity = entity
        if entity.name.aliasCoinMapName() == ""{
            nameLabel.text = "--"
            priceLabel.text = "--"
            rmbLabel.text = "--"
            amplitudeLabel.text = "--"
            return
        }
        nameLabel.text = entity.name.aliasCoinMapName()
        rmbLabel.text = entity.rmb
        
        amplitudeLabel.textColor = entity.backColor
        amplitudeLabel.text = entity.rose
        if EXHomeViewModel.homepageStyle() == .momo{
            priceLabel.textColor = entity.backColor
        }
        priceLabel.text = entity.close
        
//        if EXHomeViewModel.status() == .two{
//            handleWsVM(entity.symbol)
//        }
        
    }
    
//    func handleWsVM(_ symbol : String){
//        wsVm.kcandleType = "1min"
//        wsVm.entity.symbol = symbol
//        wsVm.disconnectAll()
//        wsVm.connecKlineWs()
//        wsVm.kLineHistroyDatas
//            .subscribe(onNext:{[weak self] (historys,hasPre) in
//                guard let `self` = self else {return}
//                self.xdataarr.removeAll()
//                self.ydataarr.removeAll()
//                var history : [KLineChartItem] = []
//                if historys.count >= 20{
//                    let fromIndex = historys.count - 21
//                    let toIndex = historys.count - 1
//                    history = Array(historys[fromIndex...toIndex])
//                }else{
//                    history = historys
//                }
//                for item in history{
//                    self.xdataarr.append(CGFloat(item.vol))
//                    self.ydataarr.append(CGFloat(item.close))
//                }
//                if self.ydataarr.count > 0 && self.xdataarr.count > 0{
//                    self.kLine.isHidden = false
//                    self.kLine.setView(XDatasArr: self.xdataarr, YDatasArr: self.ydataarr)
//                }else{
//                    self.kLine.isHidden = true
//                }
//            }).disposed(by: self.disposeBag)
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXHomeKlineView : UIView{
    
    lazy var view : XSHLineChartView = {
        let view = XSHLineChartView.init(frame: CGRect.init(x: 0, y: 0, width: 99, height: 36))
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubview(view)
    }
    
    func setColor(_ color : UIColor){
        view.setColor(color)
    }
    
    func setView(XDatasArr:[CGFloat],YDatasArr:[CGFloat]){
        view.creatLineChart(XDatasArr: XDatasArr, YDatasArr: YDatasArr)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

