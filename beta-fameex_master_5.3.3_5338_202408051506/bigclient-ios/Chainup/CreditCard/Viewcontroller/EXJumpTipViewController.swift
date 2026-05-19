//
//  EXJumpTipViewController.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/28.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

class EXJumpTipViewController: NavCustomVC{
    var model: EXPayResult?
    lazy var mainView: EXJumpTipView = {
        let view = EXJumpTipView()
        view.sureBlock = { [weak self] in
            guard let `self` = self else { return }
            guard self.model != nil else {
                return
            }
            let web = WebVC()
            var url:String? = ""
            if self.model!.serveiceType == .banxa {
                url = self.model!.data_map?.payment_post_url
            }else{
                url = self.model!.html
            }
            if let html = url {
                web.loadUrl(html)
            }
            self.navigationController?.pushViewController(web, animated: true)
        }
        return view
    }()
    override func setNavCustomV() {
        navtype = .listtitle
        self.lastVC = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let serviceName = model?.serviceName ?? "Banxa"
        let title = String(format: "creditCard_text6".localized(), serviceName)
        mainView.titleLabel.text = title
        mainView.kycLabel.text = String(format: "creditCard_text7".localized(), serviceName)
        
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
            make.left.right.equalToSuperview()
        }
    }
    

}
