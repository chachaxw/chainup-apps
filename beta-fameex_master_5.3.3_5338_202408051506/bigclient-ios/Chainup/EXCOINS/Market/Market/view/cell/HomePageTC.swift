//
//  HomePageTC.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/6.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import Swap
class FavoriteTC:HomePageTC {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        starImg.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //This method is implemented empty, and the self selection list does not need to display favorite stars
    override func upateStarState(isSwap: Bool){
        
    }
    
    override func longCell(_ tap: UITapGestureRecognizer) {
        longCellBlock?(entity)
    }
    
    
    
}


class HomePageTC: UITableViewCell {
    typealias LongCellBlock = (CoinDetailsEntity) -> ()
    var longCellBlock : LongCellBlock?
    let covm = EXContractUserVm()
    let vm = UserSymbolsVM()
    var entity = CoinDetailsEntity()
    var swapItem: EXSwapItemModel?
    lazy var tagView :EXTagView = {
        let view = EXTagView.commonTagView()
        view.isHidden = true
        return view
    }()
    //Is it optional
    lazy var starImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = EXKitBundle.svgImage(named: "public_favorites")
//        UIImage.themeImageNamed(imageName: "quotes_favorites")
        return arrowImmg
    }()

    //name
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = self.themeHNMediumFont(size: 16)
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = "--"
        return label
    }()
    
    //Turnover
    lazy var dealLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont().themeHNFont(size: 12)
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "--"
        return label
    }()
    
    //price
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont().themeHNBoldFont(size: 16)
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = "--"
        label.textAlignment = .right
        return label
    }()
    
    //True price
    lazy var rmbLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont().themeHNFont(size: 12)
        label.text = "--"
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.textAlignment = .right
        return label
    }()
    
    //Increase
    lazy var amplitudeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetCornerRadius(4)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = "--"
        label.font = UIFont().themeHNBoldFont(size: 14)
        return label
    }()
    
//    //Bottom line
//    lazy var bottomLineV : UIView = {
//        let view = UIView()
//        view.extUseAutoLayout()
//        view.backgroundColor = UIColor.ThemeView.seperator
//        return view
//    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubViews([nameLabel,starImg,tagView,dealLabel,priceLabel,rmbLabel,amplitudeLabel])
        contentView.backgroundColor = UIColor.ThemeView.card1
        self.backgroundColor = UIColor.ThemeView.card1
        selectionStyle = .none
        addConstraint()
        let long = UILongPressGestureRecognizer.init(target: self, action: #selector(longCell))
        long.minimumPressDuration = 0.6
        self.contentView.addGestureRecognizer(long)
    }
    
    func addConstraint() {
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(priceLabel.snp.left).offset(-10)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        
        dealLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.height.equalTo(16)
            make.bottom.equalToSuperview().offset(-10)
//            make.top.lessThanOrEqualTo(priceLabel.snp.bottom)
        }
        starImg.snp.makeConstraints { make in
            make.height.width.equalTo(10)
            make.left.equalTo(nameLabel)
            make.centerY.equalTo(dealLabel)
        }
        
        priceLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(SCREEN_WIDTH / 2.5)
            make.right.equalTo(amplitudeLabel.snp.left).offset(-28)
            make.height.equalTo(20)
            make.centerY.equalTo(nameLabel)
        }
        
        rmbLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(priceLabel)
            make.height.equalTo(16)
            make.centerY.equalTo(dealLabel)
        }
        
        amplitudeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
            make.width.equalTo(72)
            make.centerY.equalToSuperview()
        }
        
//        bottomLineV.snp.makeConstraints { (make) in
//            make.height.equalTo(0.5)
//            make.left.equalToSuperview().offset(15)
//            make.bottom.right.equalToSuperview()
//        }
        tagView.snp.remakeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right)
            make.right.lessThanOrEqualTo(amplitudeLabel.snp.left)
            make.top.equalTo(5)
            make.width.equalTo(5)
            make.height.equalTo(5)
        }
    }
    
    func setCellWithEntity(_ entity : CoinDetailsEntity){
        self.entity = entity
        self.upateStarState(isSwap: false)

        self.nameLabel.setCoinMap(entity.name.aliasCoinMapName(),leftFont:UIFont.ThemeFont.HeadBold,rightFont: UIFont.ThemeFont.SecondaryMedium,handleKern: 2)

        if entity.marketTag.isEmpty {
            tagView.isHidden = true
        }else {
            tagView.isHidden = false
            tagView.text = entity.marketTag
            let nameWidth = entity.nameWidth + 15 + 2
            tagView.snp.remakeConstraints { (make) in
                make.left.equalTo(nameWidth + 5)
                make.right.lessThanOrEqualTo(nameLabel.snp.right)
                make.centerY.equalTo(nameLabel)
                make.width.equalTo(entity.marketTagWidth)
                make.height.equalTo(entity.marketTagWidth)
            }
            tagView.titleResizeSize()
        }
    }
    
    //Update the cell's favorite button isSwap: Contract. IsCollection: Collection
    func upateStarState(isSwap: Bool){
        var isCollect = XUserDefault.whetherCollectionCoinMap(entity.symbol)
        if isSwap{
            isCollect =  EXStoreData.whetherCollectionCoinMap(String(swapItem!.instrument_id))
        }
        let leftMargin = isCollect ? 15 : 0
        starImg.isHidden = !isCollect
        dealLabel.snp.updateConstraints { make in
            make.left.equalTo(nameLabel).offset(leftMargin)
        }
    }
    
    //The value passed in by ws
    func ws_setCellWithEntity(_ entity : CoinDetailsEntity){
        self.dealLabel.text = "common_text_dayVolume".localized() + " \(entity.vol)"
        self.rmbLabel.text = entity.rmb
        self.priceLabel.text = entity.close
        self.amplitudeLabel.text = entity.rose
        self.amplitudeLabel.backgroundColor = entity.backColor
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
        self.contentView.backgroundColor = selected ?.ThemeView.card2 : .ThemeView.card1
    }
    
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
//        if (highlighted) {
//            self.contentView.backgroundColor = UIColor.ThemeView.card2
//        }else{
//            self.contentView.backgroundColor = UIColor.ThemeView.card1
//        }
//    }
}
extension HomePageTC{
    //Long press the cell contract and currency together
    @objc func longCell(_ tap : UITapGestureRecognizer){
        self.contentView.backgroundColor = UIColor.ThemeView.card2
        let v = EXPopMenuView.shared
        let  p = PopMenuItem()
        p.name = self.getCollectionStateAndTitle().actionName
        let isSwap = self.swapItem != nil
        let isCollection = self.getCollectionStateAndTitle().isCollection
        v.pop(fromView: self,acionItem: [p]) {[weak self] item in
           // print("p.name =\(item.name)")
            self?.updataCollection(isCollecion: isCollection, iswap: isSwap)
        }
        v.dismissend = { [weak self] in
            self?.contentView.backgroundColor = UIColor.ThemeView.card1
        }
        return
    }
    //Is the isCollection optional to add or delete actionName
    func getCollectionStateAndTitle() -> (isCollection: Bool, actionName: String ){
        var title = ""
        var isCollect = false
        if swapItem != nil{ //contract
             isCollect =  EXStoreData.whetherCollectionCoinMap(String(swapItem!.instrument_id))
        }else{
             isCollect = XUserDefault.whetherCollectionCoinMap(entity.symbol)
            
        }
        title = isCollect ? "market_str_1".localized() : "market_str_2".localized()
        return (isCollect,title)
    }
    func updataCollection(isCollecion: Bool,iswap: Bool, callBack: EXComVoidBlock? = nil){
        
        if iswap{
            covm.handleCoFavorite(actionType: isCollecion ? .singleDelete : .singleAdd, swapIds: [String(swapItem!.instrument_id)]) { [weak self] success in
                guard let `self` = self else {return}
                if success{
                    self.upateStarState(isSwap: true)
                    callBack?()
                }
            }
        }else{
           
            let newEntity = CoinMapEntity()
            newEntity.symbol = entity.symbol
            vm.handleFavorite(actionType: isCollecion ? .singleDelete : .singleAdd ,
                              coinMaps: [newEntity],
                              callback:{[weak self] success in
                guard let `self` = self else {return}
                if success{
                    self.upateStarState(isSwap: false)
                }
            })
        }
    }
}
extension HomePageTC {
    
    func bindSwapModel(model:EXSwapItemModel) {
        tagView.isHidden = true
        swapItem = model
        self.upateStarState(isSwap: true)
        nameLabel.text = model.ex_contractInfo?.showName()
        self.dealLabel.text = "common_text_dayVolume".localized() + " " + model.qty24BaseCoinUnit
        if model.last_px.isEmpty{
            self.priceLabel.text = "--"
        }else{
            self.priceLabel.text = model.last_px//Latest price
        }
        var rose = "--"
        if !model.change_rate.isEmpty{
            rose = String(format: "%@", model.change_rate.toPercentString(2))
        }
        self.amplitudeLabel.backgroundColor = UIColor.ThemekLine.labcolorDark
        if let rose1 = Float( model.change_rate){
            if rose1 == 0{
                rose = "0.00" + "%"
                self.amplitudeLabel.backgroundColor = UIColor.ThemekLine.labcolorDark
            }else if rose1 < 0{
                self.amplitudeLabel.backgroundColor = UIColor.ThemekLine.down
            }else{
                rose = "+" + rose
                self.amplitudeLabel.backgroundColor = UIColor.ThemekLine.up
            }
        }
        
        self.amplitudeLabel.text = rose
        self.rmbLabel.text = model.showRatePrice()
    }
}

extension HomePageTC:EXEmptyUIProtocal {
    func isEmptyUI() -> Bool {
        guard let price = self.priceLabel.text,let rose = self.amplitudeLabel.text else {
            return true
        }
        return (price == "--" && rose == "--")
    }
    
    func isEmptyData() -> Bool {
        return self.entity.rose == "--" || self.entity.close == "--"
    }
}

