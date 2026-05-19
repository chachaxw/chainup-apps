//
//  EXTopSearchCell.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import Swap
import EXKit
typealias FavorateBlock = (_ coinId: String, _ btn: UIButton) -> ()
class EXTopSearchCell: UITableViewCell {
    
    var vcType: EXMarketSegmentType = .exchange
    var favorateBlock: FavorateBlock?
    var ticker:EXHomeTicker?
    
    private lazy var rankingLabel:UILabel = {
        let rankL = UILabel()
        rankL.textColor = .Ex.text2
        rankL.font = .Ex.medium(16)
        return rankL
    }()
    
    private lazy var symbolLabel:UILabel = {
        let symbol = UILabel()
        symbol.textColor = .Ex.text1
        symbol.font = .Ex.medium(16)
        return symbol
    }()
    
    private lazy var favorateBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.themeImageNamed(imageName: "quotes_notfavorited"), for: .normal)
        btn.setImage(EXKitBundle.svgImage(named: "public_favorites"), for: .selected)
        btn.addTarget(self, action: #selector(favorateBtnClick(btn:)), for: .touchUpInside)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    private lazy var priceBg:UIView = {
        let v = UIView()
        return v
    }()
    
    private lazy var priceLabel:UILabel = {
        let rankL = UILabel()
        rankL.textAlignment = .right
        rankL.textColor = .Ex.text1
        rankL.font = .Ex.medium(16)
        return rankL
    }()
    
    private lazy var rateLabel:UILabel = {
        let rankL = UILabel()
        rankL.textAlignment = .right
        rankL.textColor = .Ex.text2
        rankL.font = .Ex.medium(12)
        return rankL
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extSetCell(.clear, selStyle: .none, isRemoveSelectedBackgroundView: true)
        contentView.addSubViews([rankingLabel,symbolLabel,priceBg,favorateBtn])
        priceBg.addSubViews([priceLabel,rateLabel])
        rankingLabel.snp.makeConstraints { make in
            make.leading.equalTo(MARGIN_LEFT)
            make.centerY.equalToSuperview()
        }
        
        
        priceBg.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-48)
            make.centerY.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalTo(rateLabel.snp.top)
        }
        
        rateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(priceLabel.snp.bottom)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        favorateBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-MARGIN_LEFT)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    func bindSymbols(ticker:EXHomeTicker,isFavorite:Bool,rankIdx:Int = -1) {
        self.ticker = ticker
        //RankIdx -1 not displayed
        if rankIdx > 0 {
            self.rankingLabel.text = "\(rankIdx)"
            symbolLabel.snp.remakeConstraints { make in
                make.leading.equalTo(rankingLabel.snp.trailing).offset(8)
                make.centerY.equalTo(rankingLabel)
            }
        }else {
            self.symbolLabel.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(MARGIN_LEFT)
                make.centerY.equalToSuperview()
            }
            
        }
        self.rankingLabel.isHidden = rankIdx <= 0
        self.symbolLabel.setCoinMap(ticker.showName, leftFont: .Ex.medium(16), rightFont: .Ex.medium(12), handleKern: 2)
        self.priceLabel.text = ticker.close
        self.rateLabel.text = ticker.rose
        self.rateLabel.textColor = ticker.color
        self.favorateBtn.isSelected = isFavorite
    }
    
    func updatePriceAndRate(ticker:EXHomeTicker) {
        self.priceLabel.text = ticker.close
        self.rateLabel.text = ticker.rose
        self.rateLabel.textColor = ticker.color
    }
    
    
    var model = EXSwapItemModel(){
        didSet{
            
            self.symbolLabel.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(MARGIN_LEFT)
                make.centerY.equalToSuperview()
            }
            
            var rose = String(format: "%@", model.change_rate.toPercentString(2))
            var textColor = UIColor.white
            if let rose1 = Float( model.change_rate){
                if rose1 == 0{
                    rose = "0.00" + "%"
                    textColor = .Ex.kLine.up1
                }else if rose1 < 0{
                    textColor = .Ex.kLine.down1
                }else{
                    rose = "+" + rose
                    textColor = .Ex.kLine.up1
                }
            }
            
            let isFavorite =  EXStoreData.whetherCollectionCoinMap(String(model.instrument_id))
            self.symbolLabel.text = model.ex_contractInfo?.showName()
            
            
            if model.last_px.isEmpty{
                model.setDefaultTicerData()
            }
            self.priceLabel.text = model.last_px
            self.rateLabel.text = rose
            self.rateLabel.textColor = textColor
            self.favorateBtn.isSelected = isFavorite
            
        }
    }
    
    
    @objc func favorateBtnClick(btn: UIButton){
        var id = self.ticker?.symbol
        if self.vcType == .coExchange {
            id  = String(self.model.instrument_id)
        }
        btn.isSelected = !btn.isSelected
        self.favorateBlock?(id!, btn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

