//
//  EXNoticeCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/3.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import FSPagerView
import MapKit

class EXNoticeCell: EXHomeBaseCell {
    
    var noticeItems: [NoticeInfoItem] = []

    
    lazy var banner : FSPagerView = {
        let view = FSPagerView.init()
        view.scrollDirection = .vertical
        view.alwaysBounceVertical = false
        view.backgroundColor = UIColor.ThemeView.bg
        view.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "marqueenCellIdentifier")
        view.itemSize = FSPagerView.automaticSize
        view.delegate = self
        view.dataSource = self
        view.isInfinite = true
        view.automaticSlidingInterval = 3.0
        view.isScrollEnabled = false
        return view
    }()

    
    
    lazy var noticeIcon : UIImageView = {
        let view = UIImageView.init()
        return view
    }()
    
    lazy var messageBtn : UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.addTarget(self, action: #selector(toNoticeList), for: .touchUpInside)
        return btn
    }()
    
//    lazy var line : UIView = {
//        let line = UIView()
//        line.backgroundColor = UIColor.ThemeView.seperator
//        return line
//    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(banner)
        contentView.addSubview(noticeIcon)
        contentView.addSubview(messageBtn)
//        contentView.addSubview(line)
        self.contentView.backgroundColor = UIColor.ThemeNav.bg
        banner.backgroundColor = UIColor.ThemeNav.bg
        messageBtn.setImage(UIImage.themeImageNamed(imageName: "home_more"), for: .normal)
        noticeIcon.image = UIImage.themeImageNamed(imageName: "home_announcement")
        banner.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(40)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-39)
        }
        noticeIcon.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT)
            make.centerY.equalToSuperview()
            make.width.equalTo(16)
        }
        
        messageBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(52)
            make.height.equalTo(44)
        }
        
//        line.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview()
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
//
//        if EXHomeViewModel.status() == .two {
//            contentView.backgroundColor = UIColor.ThemeNav.bg
//            self.backgroundColor = UIColor.ThemeNav.bg
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindNoticeItems(_ models:[NoticeInfoItem]) {
        self.noticeItems = models
        banner.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @objc func toNoticeList() {
        let vc = EXAnnouncementVC()
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension EXNoticeCell:FSPagerViewDelegate,FSPagerViewDataSource{
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.noticeItems.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let model = self.noticeItems[index]
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "marqueenCellIdentifier", at: index)
        cell.textLabel?.text = model.title
        cell.textLabel?.textColor = UIColor.ThemeLabel.colorMedium
        cell.textLabel?.font = UIFont.ThemeFont.SecondaryMedium
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.superview?.backgroundColor = UIColor.ThemeNav.bg
        cell.textLabel?.superview?.snp.remakeConstraints({ make in
            make.edges.equalToSuperview()
        })
        cell.textLabel?.snp.remakeConstraints({ (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        })
        cell.contentView.layer.shadowOpacity = 0
        cell.selectionColor = UIColor.clear
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let entity = self.noticeItems[index]
        
        let announceEntity = EXAnnouncementEntity()
        announceEntity.title = entity.title
        announceEntity.id = entity.id
        //Click to enter the web
        let announcementDetailsVC = EXAnnouncementDetailsVC()
        announcementDetailsVC.entity = announceEntity
        self.yy_viewController?.navigationController?.pushViewController(announcementDetailsVC, animated: true)
    }
}

