//
//  EXPresentContainer.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/9.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXPresentContainer: BaseVC {

    lazy var closeBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.themeImageNamed(imageName: "login_close"), for: .normal)
        btn.addTarget(self, action: #selector(onLeftButtonAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var navigation:UIView = {
        let nav = UIView()
        nav.backgroundColor = UIColor.ThemeView.bg
        return nav
    }()
    
    var contentVC:UIViewController?
    var closeBtnR:Bool
    
    convenience init() {
        self.init(contentVC: nil)
    }
    
    init(contentVC:UIViewController?,closeBtnR:Bool = false) {
        self.contentVC = contentVC
        self.closeBtnR = closeBtnR
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.closeBtnR = false
        super.init(coder: aDecoder)
    }
    
    @objc func onLeftButtonAction(_ sender: Any) {
        self.popBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(navigation)
        navigation.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(NAV_SCREEN_HEIGHT)
        }
        navigation.addSubview(closeBtn)
        if self.closeBtnR {
            closeBtn.snp.makeConstraints { make in
                make.width.height.equalTo(20)
                make.trailing.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-12)
            }
        }else {
            closeBtn.snp.makeConstraints { make in
                make.width.height.equalTo(20)
                make.leading.equalToSuperview().offset(16)
                make.bottom.equalToSuperview().offset(-12)
            }
        }

        if let vc = self.contentVC {
            vc.view.frame = CGRect(x: 0, y: NAV_SCREEN_HEIGHT, width: SCREEN_WIDTH, height: CONTENTVIEW_HEIGHT)
            self.addChild(vc)
            view.addSubview(vc.view)
            vc.didMove(toParent: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}

