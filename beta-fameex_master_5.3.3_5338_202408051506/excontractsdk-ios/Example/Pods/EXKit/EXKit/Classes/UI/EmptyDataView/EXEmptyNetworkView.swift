//
//  EXEmptyNetworkView.swift
//  Chainup
//
//  Created by 1 on 2021/4/7.
//  Copyright © 2021 Chainup. All rights reserved.
//

import Foundation
import YYText
import UIKit

public class EXEmptyNetworkView: UIView {
    public var noDataImageView:UIImageView = UIImageView.init()
    public var chechNetLableTop:YYLabel = YYLabel()
    public var refreshBtn:UIButton = UIButton.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        creatUI()
    }

    func creatUI(){
        let backview = UIView.init();
        backview.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(backview)
        backview.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }

        self.noDataImageView.backgroundColor = UIColor.clear;
        self.noDataImageView.image = EXKitBundle.svgImage(named: "public_wifi")
        self.addSubview(noDataImageView)
        self.noDataImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(150)
           // make.size.equalTo(CGSize.init(width: 100, height: 140))
            make.centerX.equalTo(self.snp.centerX)
        }
        
        let attrString = NSMutableAttributedString()
            .add(string: EXUIDatasource.shared.check_network_settings, attrDic: [NSAttributedString.Key.foregroundColor : UIColor.Ex.text2, NSAttributedString.Key.font : UIFont.Ex.regular(14)])
        attrString.yy_setTextHighlight(attrString.string.nsRanges(of: EXUIDatasource.shared.check_network).first ?? attrString.yy_rangeOfAll(), color: UIColor.Ex.main1, backgroundColor: nil) {[weak self] (_, _, _, _) in
            guard let mySelf = self else{return}
            mySelf.checkNetAction()
        }
        self.chechNetLableTop.numberOfLines = 0
        self.chechNetLableTop.attributedText = attrString
        self.chechNetLableTop.textAlignment = .center
        self.chechNetLableTop.isUserInteractionEnabled = true
        
        self.addSubview(chechNetLableTop)
        self.chechNetLableTop.snp.makeConstraints { (make) in
            make.top.equalTo(self.noDataImageView.snp.bottom).offset(20);
            make.size.equalTo(CGSize.init(width: UIScreen.main.bounds.width, height: 15));
            make.centerX.equalTo(self.snp.centerX);
        }
        
        self.refreshBtn.setTitle(EXUIDatasource.shared.check_refresh_more, for: .normal)
        self.refreshBtn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        self.refreshBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.refreshBtn.backgroundColor = .Ex.main1
        self.refreshBtn.setTitleColor(.Ex.text4, for: .normal)
        self.refreshBtn.corneradius = 4
        self.addSubview(self.refreshBtn)
        self.refreshBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.chechNetLableTop.snp.bottom).offset(16)
            make.size.equalTo(CGSize.init(width: 124, height: 40))
            make.centerX.equalTo(self.snp.centerX);
        }
    }
    
    @objc func checkNetAction(){
        guard let settingUrl = URL.init(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingUrl){
            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
        }
    }
}
