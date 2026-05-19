//
//  EXBannerCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/3.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import FSPagerView

class EXBannerCell: EXHomeBaseCell {
    
    var bannerModels:[CmsAppDataItem] = []
    
    lazy var bannerBg : UIImageView = {
        let view = UIImageView.init()
        view.contentMode = .scaleAspectFill
        view.isHidden = true
        view.image = UIImage.themeImageNamed(imageName: EXHomeViewModel.getHomeBannerDefaultImage())
        return view
    }()
    
    lazy var banner : FSPagerView = {
        let view = FSPagerView.init()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.ThemeView.bg
        view.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "bannerIdentifier")
        view.itemSize = FSPagerView.automaticSize
        view.delegate = self
        view.dataSource = self
        view.isInfinite = true
        view.automaticSlidingInterval = 5.0
        return view
    }()
    
//    //indicator
//    lazy var pageControl : EXBannerPageControl = {
//        let pageControl = EXBannerPageControl()
//        pageControl.isUserInteractionEnabled = false
//        return pageControl
//    }()
//
    lazy var pageControl : UILabel = {
        let pageControl = UILabel()
        pageControl.font = UIFont.ThemeFont.MinimumRegular
        pageControl.textColor = UIColor.white
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.banner.backgroundColor = UIColor.ThemeNav.bg
        contentView.backgroundColor = UIColor.ThemeNav.bg
        contentView.addSubview(banner)
        banner.addSubview(bannerBg)
        contentView.addSubview(pageControl)
        
        bannerBg.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let bannerh = EXHomePageHeightHelper.bannerH
        
        banner.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(bannerh)
            make.bottom.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(14)
            make.right.equalToSuperview().offset(-28)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bindBanner(_ models: [CmsAppDataItem]) {
        self.bannerModels = models
        bannerBg.isHidden = models.count > 0
//        pageControl.numberOfPages = models.count
        if bannerModels.count <= 1 {
            banner.isInfinite = false
            banner.automaticSlidingInterval = 0
            pageControl.isHidden = true
        }
        self.banner.reloadData()
    }
    
}

extension EXBannerCell :FSPagerViewDataSource {
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let model = self.bannerModels[index]
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "bannerIdentifier", at: index)
        if EXHomeViewModel.status() == .two {
            cell.imageView?.yy_setImage(with: URL.init(string: model.imageUrl), placeholder: UIImage.themeImageNamed(imageName:"banner"))
        }else {
            cell.imageView?.extSetCornerRadius(1.5)
            cell.imageView?.yy_setImage(with: URL.init(string: model.imageUrl), placeholder: UIImage.themeImageNamed(imageName: EXHomeViewModel.getHomeBannerDefaultImage()))
        }
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.bannerModels.count
    }
}

extension EXBannerCell :FSPagerViewDelegate {
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        pageControl.text = "\(index+1)/\(self.bannerModels.count)"
//        pageControl.currentPage = index
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.text = "\(targetIndex + 1)/\(self.bannerModels.count)"
//        pageControl.currentPage = targetIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let model = self.bannerModels[index]
        HomeGOTO().gotoVC(self.yy_viewController, tnativeUrl: model.nativeUrl, httpUrl: model.fmtUrl(),title:model.title)
    }
}

