//
//  HomePageTC.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/6.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
public class EXSFavoriteTC:EXSHomePageTC {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        starImg.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //This method cannot be deleted and must be left behind
    override func upateStarState(){
        
    }
    
    override func longCell(_ tap: UITapGestureRecognizer) {
        longCellBlock?()
    }
    
    
    
}


public class EXSHomePageTC: UITableViewCell {
    typealias LongCellBlock = () -> ()
    var longCellBlock : LongCellBlock?
    let covm = EXContractUserVm()
    var swapItem: EXSwapItemModel?
    
    lazy var starImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.svg_themeImageNamed(imageName: "public_favorites_small")
        return arrowImmg
    }()


    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = self.themeHNMediumFont(size: 16)
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = "--"
        return label
    }()
    

    lazy var dealLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont().themeHNFont(size: 12)
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "--"
        return label
    }()
    

    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont().themeHNBoldFont(size: 16)
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = "--"
        label.textAlignment = .right
        return label
    }()
    

    lazy var rmbLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont().themeHNFont(size: 12)
        label.text = "--"
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.textAlignment = .right
        return label
    }()
    

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
    

//    lazy var bottomLineV : UIView = {
//        let view = UIView()
//        view.extUseAutoLayout()
//        view.backgroundColor = UIColor.ThemeView.seperator
//        return view
//    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubViews([nameLabel,starImg,dealLabel,priceLabel,rmbLabel,amplitudeLabel])
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
        

    }
    

    
    //cupdate cell collectionbtn  isSwap：isCollection
    func upateStarState(){
        let isCollect =  EXStoreData.whetherCollectionCoinMap(String(swapItem!.instrument_id))
        let leftMargin = isCollect ? 15 : 0
        starImg.isHidden = !isCollect
        dealLabel.snp.updateConstraints { make in
            make.left.equalTo(nameLabel).offset(leftMargin)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if (highlighted) {
            self.contentView.backgroundColor = UIColor.ThemeView.card2
        }else{
            self.contentView.backgroundColor = UIColor.ThemeView.card1
        }
    }
}
extension EXSHomePageTC{

    @objc func longCell(_ tap : UITapGestureRecognizer){
        self.contentView.backgroundColor = UIColor.ThemeView.card2
        let v = EXPopMenuView.shared
        let  p = PopMenuItem()
        p.name = self.getCollectionStateAndTitle().actionName
        let isSwap = self.swapItem != nil
        let isCollection = self.getCollectionStateAndTitle().isCollection
        v.pop(fromView: self,acionItem: [p]) {[weak self] item in
           // //print("p.name =\(item.name)")
            self?.updataCollection(isCollecion: isCollection, iswap: isSwap)
        }
        v.dismissend = { [weak self] in
            self?.contentView.backgroundColor = UIColor.ThemeView.card1
        }
        return
    }
    // isCollection   actionName
    func getCollectionStateAndTitle() -> (isCollection: Bool, actionName: String ){
        var title = ""
        let isCollect =  EXStoreData.whetherCollectionCoinMap(String(swapItem!.instrument_id))
        title = isCollect ? "market_str_1".ex_localized() : "market_str_2".ex_localized()
        return (isCollect,title)
    }
    func updataCollection(isCollecion: Bool,iswap: Bool, callBack: EXComVoidBlock? = nil){
        covm.handleCoFavorite(actionType: isCollecion ? .singleDelete : .singleAdd, swapIds: [String(swapItem!.instrument_id)]) { [weak self] success in
            guard let `self` = self else {return}
            if success{
                self.upateStarState()
                callBack?()
            }
        }
    }
}
extension EXSHomePageTC {
    
    func bindSwapModel(model:EXSwapItemModel) {
        swapItem = model
        self.upateStarState()
        nameLabel.text = model.ex_contractInfo?.showName()
        self.dealLabel.text = "common_text_dayVolume".ex_localized() + " " + model.qty24BaseCoinUnit
        if model.last_px.isEmpty{
            model.setDefaultTicerData()
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
        if model.last_px.isEmpty {
            self.priceLabel.text = "--"//
            self.rmbLabel.text = ""
        } else {
            self.priceLabel.text = model.last_px
            self.rmbLabel.text = model.showRatePrice()
        }
    }
}

extension EXSHomePageTC:EXEmptyUIProtocal {
    public func isEmptyUI() -> Bool {
        guard let price = self.priceLabel.text,let rose = self.amplitudeLabel.text else {
            return true
        }
        return (price == "--" && rose == "--")
    }
    
    public func isEmptyData() -> Bool {
        return self.swapItem?.close == "--"
    }
}
