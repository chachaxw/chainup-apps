//
//  EXFiatHeaderView.swift
//  Chainup
//
//  Created by liuxuan on 2023/7/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXFiatHeaderView: NibBaseView {
    
    @IBOutlet var fiatBtn: EXDirectionSelector!
    @IBOutlet var msgBtn: UIButton!
    @IBOutlet var considerLabel: UILabel!
    @IBOutlet var filterView: EXFiatFilterView!
    var isExpand:Bool = false
    
    var onUpdateFiatCallback :ActionBtnCallback?
    typealias ActionBtnCallback = (String) -> ()
    
    var cellDidExpandBlock : ExpandCallback?
    typealias ExpandCallback = (Bool) -> ()

    override func onCreate() {
        nibView.backgroundColor = .clear
        fiatBtn.backgroundColor = .clear
        fiatBtn.iconSize = .init(width: 10, height: 10)
        fiatBtn.titleLabel.font = .Ex.regular(14)
        fiatBtn.titleLabel.textColor = .Ex.text1
        let rp = "otc_text_rp".localized()
        considerLabel.text = rp + ":--"
        
        filterView.showMoreCallback = {[weak self] show in
            self?.expandHeader(show)
        }
        filterView.onFiatCallback = {[weak self] fiatKey in
            self?.updateCallback(fiatKey)
        }
    }
    
    func expandHeader(_ isExpand:Bool ) {
        cellDidExpandBlock?(isExpand)
    }
    
    func updateCallback(_ fiatKey:String) {
        onUpdateFiatCallback?(fiatKey)
    }
    
    func isShowPayCoin() -> Bool {
        return OTCPulbicManager.sharedInstance.isPayCoinDisplayAtListView()
    }
    
    func configHeaderHeight(_ expand:Bool = false) -> CGFloat {
        self.isExpand = expand
        if self.isShowPayCoin() {
            return 42 + filterView.getHeight(expand: true)
        }
        return 42
    }

    func configHeaderInfos() {
        let showPayCoin = self.isShowPayCoin()
        filterView.isHidden = !showPayCoin
        if showPayCoin {
            filterView.bindFoldHeader(isExpand)
        }
    }
 
    @IBAction func msgAction(_ sender: Any) {
        let normal = EXNormalAlert()
        normal.configSigleAlert(title: nil, message: "alert_content_otcRPdesc".localized())
        EXAlert.showAlert(alertView: normal)
    }
}
