//
//  EXDrawerListCell.swift
//  Chainup
//
//  Created by cwd on 2022/11/2.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXDrawerListCell: UITableViewCell {
    var userliker = false {
        didSet{
            if userliker{
                starImg.isHidden = true 
            }
        }
    }
    var needRefreshList : EXComVoidBlock?
    let covm = EXContractUserVm()
    var swapItem: EXSwapItemModel?
    
    var colorModue = UIColor.Ex.global {
        didSet{
            if colorModue == .global {
                return
            }
            contentView.backgroundColor = colorModue.fill6
            self.backgroundColor = colorModue.fill6
            nameLabel.textColor =  colorModue.text1//UIColor.ThemeLabel.colorLite
            priceLabel.textColor =  colorModue.text1//UI
            
        }
    }
    lazy var tagView :EXCOTagView = {
        let view = EXCOTagView.commonTagView()
        view.isHidden = true
        return view
    }()
    
    
    //是否是自选 English: Is it optional
    lazy var starImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.svg_themeImageNamed(imageName: "public_favorites_small")
        return arrowImmg
    }()

    //名字 English: name
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = self.themeHNMediumFont(size: 16)
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = "--"
        return label
    }()
    
    
    //价格 English: price
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont().themeHNBoldFont(size: 16)
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = "--"
        label.textAlignment = .right
        return label
    }()
    
    
    //涨幅 English: Increase in price
    lazy var amplitudeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetCornerRadius(4)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = "--"
        label.font = UIFont().themeHNBoldFont(size: 12)
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubViews([starImg,nameLabel,priceLabel,amplitudeLabel])
        contentView.backgroundColor = colorModue.fill6  //UIColor.ThemeView.alertBg
        self.backgroundColor =  colorModue.fill6//UIColor.ThemeView.alertBg
        selectionStyle = .none
        addConstraint()
        let long = UILongPressGestureRecognizer.init(target: self, action: #selector(longCell))
        long.minimumPressDuration = 0.6
        self.contentView.addGestureRecognizer(long)
    }
    
    func addConstraint() {
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(20)
        }
        starImg.snp.makeConstraints { make in
            make.height.width.equalTo(8)
            make.left.equalToSuperview().offset(5)
            make.centerY.equalTo(nameLabel)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(20)
            make.centerY.equalTo(nameLabel)
        }
        
        amplitudeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(priceLabel.snp.bottom).offset(2)
        }
    }
    
    
    //更新cell 的收藏按钮  English: Update the cell's favorites button
    func upateStarState(){
        let isCollect =  EXStoreData.whetherCollectionCoinMap(String(swapItem!.instrument_id))
        starImg.isHidden = !isCollect
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if (highlighted) {
            self.contentView.backgroundColor =  colorModue.fill3 //UIColor.ThemeView.card2
        }else{
            self.contentView.backgroundColor = colorModue.fill6 // UIColor.ThemeView.alertBg
        }
    }
}
extension EXDrawerListCell{
    //长按cell 合约和币币的一起 English: Long press the cell contract and the currency together
    @objc func longCell(_ tap : UITapGestureRecognizer){
        self.contentView.backgroundColor =  colorModue.fill3//UIColor.ThemeView.card2
        let v = EXPopMenuView.shared
        let  p = PopMenuItem()
        p.name = self.getCollectionStateAndTitle().actionName
        let isCollection = self.getCollectionStateAndTitle().isCollection
        v.pop(fromView: self,acionItem: [p]) {[weak self] item in
           // //print("p.name =\(item.name)")
            self?.updataCollection(isCollecion: isCollection)
        }
        v.dismissend = { [weak self] in
            self?.contentView.backgroundColor = self?.colorModue.fill6//UIColor.ThemeView.alertBg
        }
        return
    }
    // isCollection 是否自选   actionName 添加或删除 English: Is isCollection optional to add or delete actionName
    func getCollectionStateAndTitle() -> (isCollection: Bool, actionName: String ){
        let isCollect =  EXStoreData.whetherCollectionCoinMap(String(swapItem!.instrument_id))
        //MARK: fix 提取文案 English: MARK: Fix Extract Text
        let title = isCollect ? "cp_contract_delete_optional_symbol".ex_localized().removeQ() : "cp_contract_add_optional_symbol".ex_localized().removeQ()
        return (isCollect,title)
    }
    func updataCollection(isCollecion: Bool, callBack: EXComVoidBlock? = nil){
        covm.handleCoFavorite(actionType: isCollecion ? .singleDelete : .singleAdd, swapIds: [String(swapItem!.instrument_id)]) { [weak self] success in
            guard let `self` = self else {return}
            if success{
                self.upateStarState()
                callBack?()
                if self.userliker{
                    self.needRefreshList?()
                }
            }
        }
    }
}
extension EXDrawerListCell {
    
    func bindSwapModel(model:EXSwapItemModel) {
        swapItem = model
        if self.userliker {
            starImg.isHidden = true
        }else{
            starImg.isHidden = false
            self.upateStarState()
        }
        nameLabel.text = model.ex_contractInfo?.showName()
        if model.last_px.isEmpty{
            model.setDefaultTicerData()
        }
        self.priceLabel.text = model.last_px//最新价格 English: Latest prices
        
        var rose = "--"
        if !model.change_rate.isEmpty{
            rose = String(format: "%@", model.change_rate.toPercentString(2))
        }
        var color = UIColor.ThemekLine.labcolorDark
        if let rose1 = Float( model.change_rate){
            if rose1 == 0{
                rose = "0.00" + "%"
                color  = UIColor.ThemekLine.labcolorDark
            }else if rose1 < 0{
                color = UIColor.ThemekLine.down
            }else{
                rose = "+" + rose
                color = UIColor.ThemekLine.up
            }
        }
        self.priceLabel.textColor = color
        self.amplitudeLabel.textColor = color
        self.amplitudeLabel.text = rose
    }
}

