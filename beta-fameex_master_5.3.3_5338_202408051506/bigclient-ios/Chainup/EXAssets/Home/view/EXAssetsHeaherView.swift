//
//  EXAssetsHeaherView.swift
//  Chainup
//
//  Created by wangdong on 2023/9/7.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXAssetsHeaherView: NibBaseView {

    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var assetsInfoView: UIView!
//    @IBOutlet weak var assetsTitleLabel: UILabel!
    @IBOutlet weak var assetsLabel: UILabel!
    @IBOutlet weak var assetsDescriptionLable: UILabel!
    @IBOutlet weak var eyesButton: UIButton!
    @IBOutlet weak var assetsInfoViewTop: NSLayoutConstraint!
    
    var assetsModel: EXHomeAssetModel? {
        didSet {
            updatePrivacy()
        }
    }
    
    override func onCreate() {
        lineView.alpha = 0.0
        assetsDescriptionLable.text = "assets_total_balances".localized()
        assetsInfoViewTop.constant = NAV_STATUS_HEIGHT + 10
        eyesButton.setEnlargeEdgeWithTop(40, left: 40, bottom: 40, right: 40)
//        assetsLabel.textColor = .Ex.text1
    }
    
    func updatePrivacy() {
          let bool = XUserDefault.assetPrivacyIsOn()
          if bool {
              assetsLabel.text = String.privacyString()
          }else{
              assetsLabel.attributedText = assetsModel?.makeAssetsAttr()
          }
      }
    
    func remakeSubview(){
        self.assetsDescriptionLable.snp.remakeConstraints { make in
            make.top.equalTo(eyesButton.snp.top)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(10)
        }
        self.assetsLabel.snp.remakeConstraints { make in
            make.top.equalTo(assetsDescriptionLable.snp.bottom).offset(-8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
    }
    
}
