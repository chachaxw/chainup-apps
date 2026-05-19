////
////  EXHomeTC.swift
////  Chainup
////
////  Created by zewu wang on 2023/3/6.
////  Copyright © 2023 zewu wang. All rights reserved.
////
//
//import UIKit
//import EXKit
//class EXHomeTC: EXHomeBaseCell {
//    
////    lazy var tagView :EXTagView = {
////        let view = EXTagView.commonTagView()
////        view.isHidden = true
////        return view
////    }()
//    
//    //Ranking
//    lazy var rankLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.textColor = UIColor.ThemekLine.up
//        label.font = UIFont().themeHNBoldItalicFont(size: 14)
//        label.textAlignment = .center
//        return label
//    }()
//    
//    //name
//    lazy var nameLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        return label
//    }()
//    
//    //24-hour transaction
//    lazy var volumeLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.secondaryRegular()
//        label.textColor = UIColor.ThemeLabel.colorMedium
//        return label
//    }()
//    
//    //price
//    lazy var priceLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.headBold()
//        label.textColor = UIColor.ThemeLabel.colorLite
//        return label
//    }()
//    
//    //Conversion
//    lazy var rmbLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.font = UIFont().themeHNFont(size: 12)
//        label.textColor = UIColor.ThemeLabel.colorMedium
//        return label
//    }()
//    
//    //Fluctuation range
//    lazy var amplitudeLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.font = UIFont().themeHNBoldFont(size: 14)
//        label.textColor = UIColor.white
//        label.textAlignment = .center
//        label.extSetCornerRadius(4)
//        return label
//    }()
//    
//    //Bottom line
//    lazy var lineV : UIView = {
//        let view = UIView()
//        view.extUseAutoLayout()
//        view.backgroundColor = UIColor.ThemeView.seperator
//        return view
//    }()
//    
//    lazy var kLine : EXHomeKlineView = {
//        let view = EXHomeKlineView()
//        view.view.frame = CGRect.init(x: 0, y: 0, width: 76, height: 20)
//        view.view.setLayerFrame()
//        view.extUseAutoLayout()
//        view.backgroundColor = UIColor.ThemeView.bg
//        view.isHidden = true
//        return view
//    }()
//    
//    var wsVm = EXKlineWsVm()
//    
//    var xdataarr : [CGFloat] = []
//    var ydataarr : [CGFloat] = []
//    
//    func itemWidth() -> CGFloat {
//        let width = (SCREEN_WIDTH - 36 - 15 - 20 - 10) / 3
//        return width
//    }
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.extSetCell()
//        let width = self.itemWidth()
//        contentView.addSubViews([rankLabel,nameLabel,volumeLabel,priceLabel,rmbLabel,amplitudeLabel,lineV,kLine])
//        rankLabel.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalToSuperview().offset(15)
//            make.height.equalTo(17)
//            make.width.lessThanOrEqualTo(20)
//        }
//        nameLabel.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(10)
//            make.height.equalTo(19)
//            make.left.equalToSuperview().offset(36)
//            make.width.equalTo(width)
//        }
//        
//        volumeLabel.snp.makeConstraints { (make) in
//            make.left.right.equalTo(nameLabel)
//            make.top.equalTo(nameLabel.snp.bottom).offset(2)
//            make.height.equalTo(17)
//        }
//        priceLabel.snp.makeConstraints { (make) in
//            make.height.equalTo(19)
//            make.top.equalTo(nameLabel)
//            make.right.equalTo(amplitudeLabel.snp.left).offset(-10)
//            make.left.equalTo(nameLabel.snp.right).offset(10)
//        }
//        rmbLabel.snp.makeConstraints { (make) in
//            make.left.right.equalTo(priceLabel)
//            make.height.equalTo(14)
//            make.top.equalTo(priceLabel.snp.bottom).offset(4)
//        }
//        amplitudeLabel.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-15)
//            make.height.equalTo(32)
//            make.width.equalTo(76)
//            make.centerY.equalToSuperview()
//        }
//        
//        kLine.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(15)
//            make.right.equalToSuperview().offset(-15)
//            make.height.equalTo(20)
//            make.width.equalTo(76)
//        }
//        
//        lineV.snp.makeConstraints { (make) in
//            make.height.equalTo(0.5)
//            make.left.equalToSuperview().offset(15)
//            make.bottom.right.equalToSuperview()
//        }
////
////        tagView.snp.remakeConstraints { (make) in
////            make.left.equalTo(nameLabel.snp.right)
////            make.right.lessThanOrEqualTo(priceLabel.snp.left)
////            make.top.equalTo(5)
////            make.width.equalTo(5)
////        }
//        setType()
//    }
//    
//    //Setting Type
//    func setType(){
//        if EXHomeViewModel.status() == .one{
//            
//        }else if EXHomeViewModel.status() == .two{
//            
//        }else if EXHomeViewModel.status() == .three{
//            rankLabel.isHidden = true
//            kLine.isHidden = false
//            volumeLabel.isHidden = true
//            lineV.isHidden = true
//            rmbLabel.isHidden = true
////            tagView.isHidden = true
//            amplitudeLabel.font = UIFont.ThemeFont.SecondaryMedium
//            let width = self.itemWidth()
//            
//            nameLabel.snp.remakeConstraints { (make) in
//                make.centerY.equalToSuperview()
//                make.height.equalTo(19)
//                make.left.equalToSuperview().offset(15)
//                make.width.equalTo(width)
//            }
//            
//            priceLabel.snp.remakeConstraints { (make) in
//                make.height.equalTo(19)
//                make.centerY.equalToSuperview()
//                make.right.equalTo(amplitudeLabel.snp.left).offset(-10)
//                make.left.equalTo(nameLabel.snp.right).offset(10)
//            }
//            
//            amplitudeLabel.snp.remakeConstraints { (make) in
//                make.top.equalTo(kLine.snp.bottom).offset(5)
//                make.height.equalTo(14)
//                make.width.equalTo(76)
//                make.right.equalToSuperview().offset(-15)
//            }
//        }
//    }
//    
//    var entity = HomeListEntity()
//    var itemModel = EXHomeTicker()
//    func setTag(){
//        rankLabel.text = "\(self.tag - 999)"
//        if self.tag - 1000 < 3{
//            rankLabel.textColor = UIColor.ThemekLine.up
//        }else{
//            rankLabel.textColor = UIColor.ThemeLabel.colorDark
//        }
//    }
//    
//    func bindCell(_ item:EXHomeTicker) {
//        self.itemModel = item
//        if item.app_serial_number > 0 {
//            rankLabel.text = "\(item.app_serial_number)"
//            if entity.app_serial_number < 4 {
//                rankLabel.textColor = UIColor.ThemekLine.up
//            }else {
//                rankLabel.textColor = UIColor.ThemeLabel.colorDark
//            }
//        }else {
//            setTag()
//        }
//        nameLabel.setCoinMap(item.name.aliasCoinMapName(),leftFont:UIFont().themeHNBoldFont(size: 16))
//        volumeLabel.text = LanguageTools.getString(key: "common_text_dayVolume") + " \(item.vol)"
//        rmbLabel.text = item.rmb
//        if EXHomeViewModel.status() == .one{
//            amplitudeLabel.backgroundColor = item.backColor
//        }else if EXHomeViewModel.status() == .two{
//            amplitudeLabel.backgroundColor = item.backColor
//        }else if EXHomeViewModel.status() == .three{
//            amplitudeLabel.textColor = item.backColor
//            handleWsVM(entity)
//        }
//        amplitudeLabel.text = item.rose
//        priceLabel.text = item.close
//    }
//    
//    func setCell(_ entity : HomeListEntity){
//        self.entity = entity
//        if entity.app_serial_number > 0 {
//            rankLabel.text = "\(entity.app_serial_number)"
//            if entity.app_serial_number < 4 {
//                rankLabel.textColor = UIColor.ThemekLine.up
//            }else {
//                rankLabel.textColor = UIColor.ThemeLabel.colorDark
//            }
//        }else {
//            setTag()
//        }
//        nameLabel.setCoinMap(entity.name.aliasCoinMapName(),leftFont:UIFont().themeHNBoldFont(size: 16))
//        volumeLabel.text = LanguageTools.getString(key: "common_text_dayVolume") + " \(entity.vol)"
//        rmbLabel.text = entity.rmb
//        if EXHomeViewModel.status() == .one{
//            amplitudeLabel.backgroundColor = entity.backColor
//
////            let symbol = PublicInfoManager.sharedInstance.getCoinMapLeft(entity.name)
////            let marketTag = PublicInfoManager.sharedInstance.getCoinMarketTag(symbol)
////            if marketTag.isEmpty {
////                tagView.isHidden = true
////            }else {
////                tagView.isHidden = false
////                tagView.setTitle(marketTag, for: .normal)
////                var tagWidth = tagView.commonTagWidth(titleStr: marketTag)
////                let savedWidth = self.itemWidth() - (entity.nameAttrWidth - 36) - 5
////                if savedWidth < tagWidth {
////                    tagWidth = savedWidth
////                }
////                tagView.snp.remakeConstraints { (make) in
////                    make.left.equalTo(entity.nameAttrWidth + 5)
////                    make.top.equalTo(5)
////                    make.width.equalTo(tagWidth)
////                }
////            }
//         
//        }else if EXHomeViewModel.status() == .two{
//            amplitudeLabel.backgroundColor = entity.backColor
//        }else if EXHomeViewModel.status() == .three{
//            amplitudeLabel.textColor = entity.backColor
//            handleWsVM(entity)
//        }
//        amplitudeLabel.text = entity.rose
//        priceLabel.text = entity.close
//        
//    }
//    
//    func handleWsVM(_ entity : HomeListEntity){
//        wsVm.kcandleType = "1min"
//        wsVm.entity.symbol = entity.symbol
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
//                    self.kLine.setColor(self.entity.backColor)
//                }else{
//                    self.kLine.isHidden = true
//                }
//            }).disposed(by: self.disposeBag)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//}
//
//class EXHomeDealListTC : EXHomeBaseCell {
//    
////    lazy var tagView :EXTagView = {
////        let view = EXTagView.commonTagView()
////        view.isHidden = true
////        return view
////    }()
//    
//    //Ranking
//    lazy var rankLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.textColor = UIColor.ThemekLine.up
//        label.font = UIFont().themeHNBoldItalicFont(size:14)
//        label.textAlignment = .center
//        return label
//    }()
//    
//    lazy var nameLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.font = UIFont.ThemeFont.HeadBold
//        label.textColor = UIColor.ThemeLabel.colorLite
//        return label
//    }()
//    
//    lazy var priceLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.font = UIFont.ThemeFont.HeadBold
//        label.textColor = UIColor.ThemeLabel.colorLite
//        return label
//    }()
//    
//    lazy var turnoverLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.textAlignment = .center
//        label.backgroundColor = UIColor.ThemeTab.bg
//        label.textColor = UIColor.ThemeLabel.colorHighlight
//        label.extSetCornerRadius(4)
//        label.font = UIFont.ThemeFont.BodyBold
//        return label
//    }()
//    
//    //Bottom line
//    lazy var lineV : UIView = {
//        let view = UIView()
//        view.extUseAutoLayout()
//        view.backgroundColor = UIColor.ThemeView.seperator
//        return view
//    }()
//    
//    func itemWidth() -> CGFloat {
//        let width = (SCREEN_WIDTH - 36 - 15 - 20 - 10) / 3
//        return width
//    }
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.backgroundColor = UIColor.ThemeView.bg
//        contentView.backgroundColor = UIColor.ThemeView.bg
//        self.extSetCell()
//        let width = self.itemWidth()
//        contentView.addSubViews([rankLabel,nameLabel,priceLabel,turnoverLabel,lineV])
//        rankLabel.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalToSuperview().offset(15)
//            make.height.equalTo(17)
//            make.width.lessThanOrEqualTo(20)
//        }
//        
//        nameLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(36)
//            make.centerY.equalToSuperview()
//            make.height.equalTo(17)
//            make.width.equalTo(width)
//        }
//        if EXHomeViewModel.status() == .three{
//            rankLabel.isHidden = true
//            nameLabel.snp.remakeConstraints { (make) in
//                make.left.equalToSuperview().offset(15)
//                make.centerY.equalToSuperview()
//                make.height.equalTo(17)
//                make.width.equalTo(width)
//            }
//        }
//        priceLabel.snp.makeConstraints { (make) in
//            make.right.equalTo(turnoverLabel.snp.left).offset(-10)
//            make.left.equalTo(nameLabel.snp.right).offset(10)
//            make.centerY.equalToSuperview()
//            make.height.equalTo(17)
//        }
//        turnoverLabel.snp.makeConstraints { (make) in
//            make.width.equalTo(76)
//            make.centerY.equalToSuperview()
//            make.height.equalTo(32)
//            make.right.equalToSuperview().offset(-15)
//        }
//        lineV.snp.makeConstraints { (make) in
//            make.height.equalTo(0.5)
//            make.left.equalToSuperview().offset(15)
//            make.bottom.right.equalToSuperview()
//        }
//        
////        tagView.snp.remakeConstraints { (make) in
////            make.left.equalTo(nameLabel.snp.right)
////            make.right.lessThanOrEqualTo(priceLabel.snp.left)
////            make.top.equalTo(5)
////            make.width.equalTo(5)
////        }
//    }
//    
//    //
//    func setCell(_ entity : HomeListEntity){
//        nameLabel.text = entity.symbol.aliasName()
//        let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(entity.symbol)
//        if entity.symbol.isEmpty {
//            priceLabel.text = "--"
//        }else {
//            priceLabel.text = NSString.init(string: t.1).decimalString1(t.2)
//        }
//        turnoverLabel.text = entity.volume
//        setTag()
////        if EXHomeViewModel.status() == .one{
////            let symbol = PublicInfoManager.sharedInstance.getCoinMapLeft(entity.name)
////            let marketTag = PublicInfoManager.sharedInstance.getCoinMarketTag(symbol)
////            if marketTag.isEmpty {
////                tagView.isHidden = true
////            }else {
////                tagView.isHidden = false
////                tagView.setTitle(marketTag, for: .normal)
////                var tagWidth = tagView.commonTagWidth(titleStr: marketTag)
////                let savedWidth = self.itemWidth() - (entity.symbolWidth - 36) - 5
////                if savedWidth < tagWidth {
////                    tagWidth = savedWidth
////                }
////                tagView.snp.remakeConstraints { (make) in
////                    make.left.equalTo(entity.symbolWidth + 5)
////                    make.top.equalTo(5)
////                    make.width.equalTo(tagWidth)
////                }
////            }
////       }
//    }
//    
//    func setTag(){
//        rankLabel.text = "\(self.tag - 999)"
//        if self.tag - 1000 < 3{
//            rankLabel.textColor = UIColor.ThemekLine.up
//        }else{
//            rankLabel.textColor = UIColor.ThemeLabel.colorDark
//        }
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
//
