////
////  EXJapanRankCell.swift
////  Chainup
////
////  Created by liuxuan on 2023/8/18.
////  Copyright © 2023 ChainUP. All rights reserved.
////
//
//import UIKit
//
//class EXJapanRankCell: EXHomeBaseCell {
//    
//    var wsVm = EXKlineWsVm()
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
//    
//    //name
//    lazy var nameLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
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
//    //Fluctuation range
//    lazy var amplitudeLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        
//        label.font = UIFont.ThemeFont.SecondaryMedium
//        label.textColor = UIColor.white
//        label.textAlignment = .center
//        label.extSetCornerRadius(4)
//        return label
//    }()
//    
//    
//    var xdataarr : [CGFloat] = []
//    var ydataarr : [CGFloat] = []
//    
//    var itemModel = EXHomeTicker()
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
//    
//    
//    func itemWidth() -> CGFloat {
//        let width = (SCREEN_WIDTH - 36 - 15 - 20 - 10) / 3
//        return width
//    }
//    
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.extSetCell()
//        let width = self.itemWidth()
//        contentView.addSubViews([nameLabel,priceLabel,amplitudeLabel,kLine])
//        
//        nameLabel.snp.remakeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.height.equalTo(19)
//            make.left.equalToSuperview().offset(15)
//            make.width.equalTo(width)
//        }
//        
//        priceLabel.snp.remakeConstraints { (make) in
//            make.height.equalTo(19)
//            make.centerY.equalToSuperview()
//            make.right.equalTo(amplitudeLabel.snp.left).offset(-10)
//            make.left.equalTo(nameLabel.snp.right).offset(10)
//        }
//        
//        amplitudeLabel.snp.remakeConstraints { (make) in
//            make.top.equalTo(kLine.snp.bottom).offset(5)
//            make.height.equalTo(14)
//            make.width.equalTo(76)
//            make.right.equalToSuperview().offset(-15)
//        }
//        
//        kLine.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(15)
//            make.right.equalToSuperview().offset(-15)
//            make.height.equalTo(20)
//            make.width.equalTo(76)
//        }
//    }
//    
//    func bindCell(_ item:EXHomeTicker) {
//        self.itemModel = item
//        nameLabel.setCoinMap(item.name.aliasCoinMapName(),leftFont:UIFont().themeHNBoldFont(size: 16))
//        amplitudeLabel.textColor = item.backColor
//        amplitudeLabel.text = item.rose
//        priceLabel.text = item.close
//        handleWsVM(item.symbol,item.backColor)
//    }
//    
//    func handleWsVM(_ symbol : String, _ color:UIColor? ){
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
//                if let klineColor = color {
//                    self.kLine.setColor(klineColor)
//                }
//                if self.ydataarr.count > 0 && self.xdataarr.count > 0{
//                    self.kLine.isHidden = false
//                    self.kLine.setView(XDatasArr: self.xdataarr, YDatasArr: self.ydataarr)
//                }else{
//                    self.kLine.isHidden = true
//                }
//            }).disposed(by: self.disposeBag)
//    }
//}
//
