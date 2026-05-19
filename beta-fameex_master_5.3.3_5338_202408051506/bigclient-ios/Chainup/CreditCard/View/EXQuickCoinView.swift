//
//  EXQuickCoinView.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import YYWebImage
/**
Currency icon button
 */
class EXQuickCoinView: UIView {
    var tailing = false {
        didSet{
            if tailing {
                tailinglayout()
            }
        }
    }
    var coin: EXCreditCoin? {
        didSet{
            guard let c = coin else{
                return
            }
            if let url = URL(string: c.iconUrl){
                coinBgImg.yy_setImage(with: url, placeholder: nil, options: YYWebImageOptions.allowBackgroundTask) { (img, url, type, s, error) in
                }
            }else{
                coinBgImg.image = UIImage(named: "")
            }
            nameLabel.text = c.showName
        }
    }
    
    lazy var coinBgImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.corneradius = 10
        return arrowImmg
    }()
  
    
    
    ///Option Name
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.Ex.medium(16), textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var arrowImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.themeImageNamed(imageName: "trade_arrow_right")
        return arrowImmg
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([coinBgImg,nameLabel,arrowImg])
        leadinglayout()
    }
    func leadinglayout(){
       
        coinBgImg.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(coinBgImg.snp_right).offset(8)
            make.centerY.equalToSuperview()
        }
        arrowImg.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(8)
//            make.width.height.equalTo(10)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
    }
    func tailinglayout(){
        arrowImg.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            
        }
        nameLabel.snp.remakeConstraints { make in
            make.right.equalTo(arrowImg.snp_left).offset(-8)
            make.centerY.equalToSuperview()
        }
        coinBgImg.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
            make.right.equalTo(nameLabel.snp_left).offset(-8)
        }
    }
    class func getWidth(coin: EXCreditCoin) -> CGFloat {
        let font = UIFont.Ex.medium(16)
        let w = coin.showName.getTextWidth(font: font, lineH: 0)
        let total = 20 + 8 + w + 8 + 16  + 16
//        print("w = \(w)")
//        print("total = \(total)")
        return total
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

