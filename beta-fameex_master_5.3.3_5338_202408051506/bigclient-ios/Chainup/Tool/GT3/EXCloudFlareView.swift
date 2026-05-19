//
//  EXCloudFlareView.swift
//  Chainup
//
//  Created by cwd on 2023/12/4.
//  Copyright © 2023 Chainup. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import EXKit
class EXCloundFlareView: UIView,WKNavigationDelegate {
   
    var onSuccessCallBack: EXComStringBlock?
    var onErrorCallBack: EXVoidModel?
    var clareConfig: EXAPPValidationConfig?
    lazy var webView : DWKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences = WKPreferences()
        let userContentController = WKUserContentController()
        //        userContentController.addUserScript(wkUScript)
        userContentController.add(EXScriptMessageProxy(delegate: self), name: EXJsHandler.handlerName)
       

        let cookieScript = WKUserScript(source: "",
                                        injectionTime: .atDocumentStart,
                                        forMainFrameOnly: false)
        userContentController.addUserScript(cookieScript)
        
        config.userContentController = userContentController
        
        
        let view = DWKWebView.init(frame: CGRect.zero, configuration: config)
        view.extUseAutoLayout()
        view.scrollView.isScrollEnabled = false
        if #available(iOS 9.0, *) {
            view.allowsBackForwardNavigationGestures = true
        } else {
            view.allowsBackForwardNavigationGestures = false
        }
        view.navigationDelegate = self
        view.isOpaque = false //If this value is not set, the page background will always be white
        view.autoresizingMask = .flexibleHeight
        view.addJavascriptObject(jsMethod, namespace: nil)
                
//        dark：#232323
//        light：#EDEFF2
        let colorStr = "#EDEFF2"
        let color = EXTheme.current.isDark ? UIColor.Ex.fill3 : UIColor.extColorWithHex(colorStr)
        view.layer.borderWidth = 1
        view.backgroundColor = color
        view.layer.borderColor = color.cgColor
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    lazy var jsMethod: EXCLoundFlartJsApiMethodSwift = {
        let js = EXCLoundFlartJsApiMethodSwift()
        js.successTokenCallBack = { [weak self] token in
            guard let `self` = self else { return }
            self.onSuccessCallBack?(token)
        }
        js.errorCallBack = { [weak self] in
            guard let `self` = self else { return }
            self.webView.isUserInteractionEnabled = false
        }
        return js
    }()
    lazy var title:UILabel = {
        let l = UILabel()
        l.text = "complete_verify".localized()
        l.font = UIFont.Ex.medium(16)
        l.textColor = UIColor.Ex.text1
        return l
    }()
    
    lazy var closeBtn:RepeatButton = {
        let btn = RepeatButton.init(type: .custom)
        btn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        btn.setImage(UIImage.themeImageNamed(imageName: "public_close"), for: .normal)
        return btn
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.allCorners], radius: 12)
    }
    
    @objc func closeBtnAction() {
        EXAlert.dismiss()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.Ex.fill6
        self.addSubview(title)
        self.addSubview(webView)
        self.addSubview(closeBtn)
        
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
        }
        
        closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(title)
            make.width.height.equalTo(16)
        }
        
        webView.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
//            make.width.equalTo(SCREEN_WIDTH - 100)
//            make.height.equalTo(56)
            make.height.equalTo(65)
//            make.width.equalTo(300)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        
       
    }
    
    func startWork(key: String ){
        
        let lan  = LanguageHandler.priviatePhoneLanguage
        let dic:[String : String] = [
           "key":key,
           "isDark": EXThemeManager.isNight() ? "true" : "false",
           "lan": lan,
         ]
        var pararm = "?isapp=1&"
        for key in dic.keys{
            pararm += key
            pararm += "="
            pararm += dic[key] ?? ""
            pararm += "&"
        }
        print("pararm = \(pararm)")
        pararm = pararm.substring(to: pararm.index(before: pararm.endIndex))
        //使用返回的 domain 替换 haowei.wuyj.top
        var urlStr = "http://haowei.wuyj.top/zh_CN/cloudflare" + pararm
        
        if let domain = clareConfig?.cloudflare?.domain{
            var prix = "https://"
            if domain.contains("wuyj") || domain.contains("m.tencent.com"){
                prix = "http://"
            }
            if domain.isEmpty == false{
                urlStr = prix + domain + "/zh_CN/cloudflare" + pararm
            }
            print("url = \(urlStr)")
            if let url = URL(string: urlStr) {
                let request = URLRequest(url:url)
                self.webView.load(request)
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EXCloundFlareView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("message name = \(message.name)")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none';", completionHandler: nil) 
    }
}

extension EXCloundFlareView{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        print("webView decidePolicyFor navigationAction= decisionHandler =\(navigationAction.request.url)")
        if let url = navigationAction.request.url{
            print("url = \(url)")
            if url.absoluteString.contains("feedback-reports"){
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        print(action)
        return false
    }
}



