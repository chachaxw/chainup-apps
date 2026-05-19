//
//  EXNaviSearchBar.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXNaviSearchBar: NibBaseView {
    
    @IBOutlet var searchIcon: UIButton!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var borderBg: UIView!
    @IBOutlet var contentView: UIView!
    
    override func onCreate() {
        self.backgroundColor = UIColor.ThemeSearchPage.searchBg
        borderBg.backgroundColor = UIColor.ThemeSearchPage.searchBarBg
        contentView.backgroundColor = UIColor.ThemeSearchPage.searchBg
        borderBg.corneradius = 16
//        if EXAppConfigManager.sharedInstance.didOpenContract() {
//            searchField.setPlaceHolderAtt("market_search_all".localized(), color: UIColor.ThemeLabel.colorDark, font: 14)
//        }else {
            searchField.setPlaceHolderAtt("assets_action_search".localized(), color: UIColor.ThemeLabel.colorDark, font: 14)
//        }
        searchField.clearButtonMode = .whileEditing
        searchField.setModifyClearButton()
        searchField.textColor = UIColor.ThemeLabel.colorLite
        searchIcon.setImage(UIImage.themeImageNamed(imageName: "public_search"), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        cancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
        cancelBtn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        cancelBtn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
    }
    
    func hideCancelBtn() {
        cancelBtn.isHidden = true
        searchField.snp.remakeConstraints { (make) in
            make.centerY.equalTo(cancelBtn)
            make.right.equalTo(cancelBtn.snp.right)
            make.left.equalTo(searchIcon.snp.right).offset(8)
        }
    }
    
    func customSearchFor(content:String) {
        self.searchField.text = content
        self.searchField.sendActions(for: .valueChanged)
    }

}
