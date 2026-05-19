//
//  EXCapchaView.swift
//  Chainup
//
//  Created by liuxuan on 2023/6/10.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import WebKit

class EXCapchaView: UIView,WKNavigationDelegate {
    typealias AliCaptchaCancel = () -> ()
    typealias AliCaptchaCallback = (EXAliCaptchaModel) -> ()
    var onAliCallback:AliCaptchaCallback?
    var onAliCancel:AliCaptchaCancel?
    
    lazy var webView: WKWebView = {
        //Configure page adaptive scaling
        //        let javascript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta)"
        let configuration = WKWebViewConfiguration()
        let userScript = WKUserScript(source: "", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let usercontroller = WKUserContentController()
        usercontroller.addUserScript(userScript)
        configuration.userContentController = usercontroller
        //Add the calling method for HTML page JS. The default method name added here is getSlideData, which can be changed as needed
        configuration.userContentController.add(EXScriptMessageProxy(delegate: self), name: "getSlideData")
        //Configure WKWebView
        let webView = WKWebView(frame: self.frame, configuration: configuration)
        webView.navigationDelegate = self
        webView.backgroundColor = UIColor.ThemeView.bg
        return webView
    }()
    
    lazy var title:UILabel = {
        let l = UILabel()
        l.text = "captcha_aliyun_title".localized()
        l.font = UIFont.ThemeFont.HeadMedium
        l.textColor = UIColor.ThemeLabel.colorLite
        return l
    }()
    
    lazy var closeBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        btn.setImage(UIImage.themeImageNamed(imageName: "login_close"), for: .normal)
        return btn
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.allCorners], radius: 4)
    }
    
    @objc func closeBtnAction() {
        self.onAliCancel?()
        EXAlert.dismiss()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubview(title)
        self.addSubview(webView)
        self.addSubview(closeBtn)
        webView.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(SCREEN_WIDTH - 90)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
        }
        
        closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(16)
        }
        
        if let url = URL(string: EXAppConfigManager.sharedInstance.getAliCaptchaUrl()) {
            let request = URLRequest(url: url);
            webView.load(request); //Load Page
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXCapchaView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "getSlideData"){
            if let info = message.body as? [String:Any] {
                if let model = EXAliCaptchaModel.mj_object(withKeyValues: info) {
                    self.onAliCallback?(model)
                }
            }
        }
    }
}

