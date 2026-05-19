//
//  EXHomeSubBannerCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/14.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import FSPagerView

class EXHomeSubBannerCell: EXHomeBaseCell {
    var banners:[CmsAppDataItem] = []
    let customCellIdentifier = "customBannerCellIdentifier"

    lazy var banner : FSPagerView = {
        let view = FSPagerView.init()
        view.corneradius = 4
        view.register(EXBannerItemCell.self, forCellWithReuseIdentifier: customCellIdentifier)
        view.delegate = self
        view.dataSource = self
        view.isInfinite = true
        view.automaticSlidingInterval = 5.0
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addSubview(banner)
        
        banner.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func bindBanners(subBanner:[CmsAppDataItem]) {
        self.banners = subBanner
//        pageControl.numberOfPages = subBanner.count
        if subBanner.count <= 1 {
//            pageControl.isHidden = true
            banner.isInfinite = false
            banner.automaticSlidingInterval = 0
        }
        self.banner.reloadData()
    }
}

extension EXHomeSubBannerCell : FSPagerViewDelegate,FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.banners.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let model = banners[index]
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, at: index)
        cell.backgroundColor = UIColor.ThemeView.bg
        if let imgV = cell.imageView {
            imgV.contentMode =  .scaleToFill//.scaleAspectFill
            imgV.clipsToBounds = true
            if EXHomeViewModel.status() == .three {
                cell.imageView?.yy_setImage(with: URL.init(string: model.imageUrl), placeholder: UIImage.init(named:"banner_japan"))
            }else {
                imgV.yy_setImage(with: URL.init(string: model.imageUrl), placeholder:  UIImage.themeImageNamed(imageName: "home_pic_smallbanner_1_occupationmap"))
            }
        }
        return cell
    }
//    
//    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
//        pageControl.currentPage = index
//    }
//    
//    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
//        pageControl.currentPage = targetIndex
//    }
    
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        let model = banners[index]
        HomeGOTO().gotoVC(self.yy_viewController, tnativeUrl: model.nativeUrl, httpUrl: model.fmtUrl(),title:model.title)
    }
}

