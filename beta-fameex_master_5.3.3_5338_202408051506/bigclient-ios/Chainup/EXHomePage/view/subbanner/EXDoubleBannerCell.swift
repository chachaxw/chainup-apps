//
//  EXDoubleBannerCell.swift
//  Chainup
//
//  Created by liuxuan on 2022/8/2.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

class EXDoubleBannerCell: EXHomeBaseCell {
    var banners:[CmsAppDataItem] = []
    let doubleCellIdentifier = "doubleCellIdentifier"
    lazy var bannerL : UIImageView = {
        let view = UIImageView.init()
        view.corneradius = 10
        view.layer.masksToBounds = true
        let tap = UITapGestureRecognizer.init(target: self, action:#selector(click(tap:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        view.tag = 0
        return view
    }()
    lazy var bannerR : UIImageView = {
        let view = UIImageView.init()
        view.corneradius = 10
        view.layer.masksToBounds = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click(tap:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        view.tag = 1
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addSubViews([bannerL,bannerR])
        
        bannerL.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(bannerR.snp.leading).offset(-11)
            make.width.equalTo(bannerR.snp.width)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        bannerR.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(bannerR.snp.trailing).offset(11)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }

    }
    
    
    func bindBanners(subBanner:[CmsAppDataItem]) {
        self.banners = subBanner
        if let item = subBanner.safeObject(at: 0) {
            bannerL.yy_setImage(with: URL.init(string: item.imageUrl),placeholder: UIImage.themeImageNamed(imageName: "home_pic_smallbanner_2_occupationmap"))
        }
        if let item = subBanner.safeObject(at: 1) {
            bannerR.yy_setImage(with: URL.init(string: item.imageUrl),placeholder: UIImage.themeImageNamed(imageName: "home_pic_smallbanner_2_occupationmap"))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func click(tap: UITapGestureRecognizer ){
        let index = tap.view!.tag
        if self.banners.count > index {
            let model = self.banners[index]
            HomeGOTO().gotoVC(self.yy_viewController, tnativeUrl: model.nativeUrl, httpUrl: model.fmtUrl(),title:model.title)
        }
    }
}

