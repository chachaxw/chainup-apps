//
//  PageWheelVCV.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//Rotation chart

import UIKit
import YYWebImage

class PageWheelVCV: UICollectionViewCell {
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
//        imgV.contentMode = .scaleAspectFit
        return imgV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imgV)
        imgV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setCell(_ entity : CmsAppAdvertEntity){
        if EXHomeViewModel.status() == .one{
            if let url = URL.init(string: entity.imageUrl){
                imgV.yy_setImage(with: url , placeholder: UIImage.init(named: EXHomeViewModel.getHomeBannerDefaultImage()), options: YYWebImageOptions.allowBackgroundTask, completion: nil)
            }else{
                imgV.image = UIImage.init(named: EXHomeViewModel.getHomeBannerDefaultImage())
            }
        }else if EXHomeViewModel.status() == .two{
            if let url = URL.init(string: entity.imageUrl){
                imgV.yy_setImage(with: url , placeholder: UIImage.init(named: "banner"), options: YYWebImageOptions.allowBackgroundTask, completion: nil)
            }else{
                imgV.image = UIImage.init(named: "banner")
            }
        }else if EXHomeViewModel.status() == .three{
            imgV.extSetCornerRadius(1.5)
            if let url = URL.init(string: entity.imageUrl){
                imgV.yy_setImage(with: url , placeholder: UIImage.init(named: "banner_japan"), options: YYWebImageOptions.allowBackgroundTask, completion: nil)
            }else{
                imgV.image = UIImage.init(named: "banner_japan")
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

