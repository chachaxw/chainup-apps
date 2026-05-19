//
//  EXTransactionDrawerTC.swift
//  Chainup
//
//  Created by zewu wang on 2020/4/2.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit
import EXKit
import RxSwift

class EXTransactionDrawerTC: UITableViewCell {
    
    var longPressBlock:((CoinDetailsEntity,EXTransactionDrawerTC)->Void)?
    
    var entity = CoinDetailsEntity()
    
    lazy var tagView :EXTagView = {
        let view = EXTagView.commonTagView()
        view.textColor = .Ex.main4
        view.isHidden = true
        return view
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = .Ex.medium(16)
        label.textAlignment = .right
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "--"
        return label
    }()
    
    lazy var rateLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = .Ex.medium(12)
        label.textAlignment = .right
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "--"
        return label
    }()
    
    lazy var multipleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textColor = .Ex.main4
        label.font = .Ex.regular(10)
        label.backgroundColor = UIColor.ThemeView.highlight15
        label.corneradius = 2
        label.textAlignment = .center
        return label
    }()
    
    //是否是自选
    lazy var starImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = EXKitBundle.svgImage(named: "public_favorites_small")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        self.extSetCell()
        contentView.addSubViews([starImageView,nameLabel,tagView,priceLabel,rateLabel,multipleLabel])
        
        starImageView.snp.makeConstraints { make in
            make.height.width.equalTo(8)
            make.left.equalToSuperview().offset(5)
            make.centerY.equalTo(nameLabel)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.equalToSuperview().offset(16)
        }
        
        tagView.snp.remakeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right)
            make.centerY.equalTo(nameLabel)
            make.width.equalTo(5)
        }
        
        multipleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(4)
            make.centerY.equalTo(nameLabel)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(8)
        }
        
        rateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(priceLabel.snp.bottom).offset(2)
        }
    }
    var isShowingPopover:Bool = false {
        didSet {
            let colorModule:UIColor.Ex = fromKline ? .kLine : .global
            contentView.backgroundColor = isShowingPopover ? colorModule.fill3 : colorModule.fill6
        }
    }
    
    var isSelfCollection:Bool = false
    
    func setCell(_ entity : CoinDetailsEntity , showMultiple : Bool = false){
        let colorModule:UIColor.Ex = fromKline ? .kLine : .global
        let array = entity.name.aliasCoinMapName().components(separatedBy: "/")
        let coinName = array.count > 0 ? (array[0] + " ") : ""
        let marketName = array.count >= 2 ? array[1] : ""
        nameLabel.setCoinMapWith(coinName,
                                 leftColor: colorModule.text1,
                                 leftFont: .Ex.medium(16),
                                 rightStr: marketName,
                                 rightColor: colorModule.text2,
                                 rightFont: .Ex.medium(12),
                                 kern: 0)
        priceLabel.text = entity.close
        priceLabel.textColor = entity.color
        rateLabel.text = entity.rose
        rateLabel.textColor = entity.color
        self.entity = entity
        starImageView.isHidden = isSelfCollection || !XUserDefault.whetherCollectionCoinMap(entity.symbol)
        let symbol = EXAppMarketManager.sharedInstance.getMarketLeft(entity.name)
        let marketTag = EXAppMarketManager.sharedInstance.getCoinMarketTag(symbol)
        
        if showMultiple {
            multipleLabel.isHidden = false
            let mapEntity = EXAppMarketManager.sharedInstance.getLeverMapModel(marketName: entity.name)
            let leverType = mapEntity.getLeverSupportType()
            if EXLeverService.service.isSupportAllLevers() {
                if leverType == .onlyIsolated {
                    multipleLabel.text = mapEntity.multiple + "X"
                }else {
                    multipleLabel.text = EXAppConfigManager.sharedInstance.getLeverMutiple() + "X"
                }
            }else if EXAppConfigManager.sharedInstance.didOpenIsolatedLever() {
                multipleLabel.text = mapEntity.multiple + "X"
            }else {
                multipleLabel.text = EXAppConfigManager.sharedInstance.getLeverMutiple() + "X"
            }
            var size = multipleLabel.intrinsicContentSize
            size.width += 4
            multipleLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(nameLabel.snp.right).offset(4)
                make.centerY.equalTo(nameLabel)
                make.size.equalTo(size)
            }
        }else {
            multipleLabel.isHidden = true
        }
        if marketTag.isEmpty {
            tagView.isHidden = true
        }else {
            tagView.isHidden = false
            tagView.text = marketTag
            let tagWidth = 20
            if showMultiple {
                tagView.snp.remakeConstraints { (make) in
                    make.left.equalTo(multipleLabel.snp.right).offset(4)
                    make.right.lessThanOrEqualTo(priceLabel.snp.left)
                    make.centerY.equalTo(nameLabel)
                    make.width.equalTo(tagWidth)
                    make.height.equalTo(10)
                }
            }else {
                tagView.snp.remakeConstraints { (make) in
                    make.left.equalTo(nameLabel.snp.right).offset(4)
                    make.centerY.equalTo(nameLabel)
                    make.right.lessThanOrEqualTo(priceLabel.snp.left)
                    make.width.equalTo(tagWidth)
                    make.height.equalTo(10)
                }
            }
            tagView.titleResizeSize()
        }
    }
    
    func ws_Cell(){
        self.entity.subject.asObserver().subscribe {[weak self] (event) in
            guard let mySelf = self else{return}
            if let str = event.element{
                if str != mySelf.entity.name{
                    return
                }
                mySelf.priceLabel.text = mySelf.entity.close
                mySelf.priceLabel.textColor = mySelf.entity.color
            }
        }.disposed(by: disposeBag)
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
        // Configure the view for the selected state
    }
}


