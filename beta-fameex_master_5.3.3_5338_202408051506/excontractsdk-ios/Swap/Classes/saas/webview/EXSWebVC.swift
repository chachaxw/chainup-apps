//
//  WebVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/18.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import WebKit
import EXKit

func domain_host_url() -> String{
    var hosturl = ""
    let host = EXSwapPrivateConfig.shared.base_host
    let index = host.positionOf(sub: ".")
    hosturl = host.extStringSub(NSRange.init(location: index, length: host.count - index))
    return hosturl
}
//MARK: fix pod 需要细拆依赖 English: MARK: Fix pod requires detailed disassembly of dependencies
class EXSWebVC: EXSNavCustomVC,WKNavigationDelegate {
    
    var urlStr = ""
    typealias DissMissBlock = () -> ()
    var missBlock : DissMissBlock?
    var closeBlock : DissMissBlock?
    var cookieDomain:String = domain_host_url()
    var customTitle:String = ""
    var progressView: UIProgressView?
    
    lazy var closeBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.isHidden = true
        //MARK: fix
        btn.setImage(UIImage.themeImageNamed(imageName:"personal_shutdown"), for: .normal)
        btn.addTarget(self, action: #selector(closeWebVc), for: .touchUpInside)
        return btn
    }()
    //MARK: fix
    private var excookies:[String] =  EXNetParameterGenerator.getHeaderParams().map{"\($0)=\($1)"}
    
    private func cookieScript() -> String {
        return excookies.map { "document.cookie='\($0);\(cookieAttributes())';" }.joined()
    }
    
    private func cookieAttributes() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd-MMM-yyyy HH:mm:ss zzz"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "GMT")
        let expireDate = Date(timeIntervalSinceNow: (60 * 60 * 24 * 30))
        let expireString = formatter.string(from: expireDate)
        return "domain=\(cookieDomain); expires=\(expireString); path=/ ;"
    }
    
    override func navBack() {
        if webView.canGoBack {
            checkGoBack()
            webView.goBack()
        }else {
            self.popBack()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.missBlock?()
    }
    
    lazy var webView : WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences = WKPreferences()
        let userContentController = WKUserContentController()
        userContentController.add(EXSwapScriptMessageProxy(delegate: self), name: EXSJsHandler.handlerName)
        let cookieScript = WKUserScript(source: self.cookieScript(),
                                        injectionTime: .atDocumentStart,
                                        forMainFrameOnly: false)
        userContentController.addUserScript(cookieScript)
        
        config.userContentController = userContentController
        
        
        let view = WKWebView(frame: CGRect.zero, configuration: config)
        view.extUseAutoLayout()
        
        if #available(iOS 9.0, *) {
            view.allowsBackForwardNavigationGestures = true
        } else {
            /*
             在iOS 8下， 先设置WKWebView的 English: In iOS 8, first set the WKWebView
             webView.allowsBackForwardNavigationGestures = YES;
             然后再设置为NO的话 English: If it is set to NO again
             webView.allowsBackForwardNavigationGestures = NO;
             只要手指一碰屏幕，就会出现Crash English: As long as the finger touches the screen, a crash will appear
             */
            view.allowsBackForwardNavigationGestures = false
        }
        view.navigationDelegate = self
        //解决网页底部黑边问题 English: Solve the problem of black edges at the bottom of web pages
        //        view.backgroundColor = UIColor.clear
        view.isOpaque = false //不设置这个值 页面背景始终是白色 English: Do not set this value, the page background will always be white
        view.autoresizingMask = .flexibleHeight
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        configNaviBackBtn()
        self.view.backgroundColor = UIColor.clear
        contentView.addSubview(webView)
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        if self.customTitle.count > 0 {
            self.setTitle(customTitle)
        }
        webView.uiDelegate = self  //as? WKUIDelegate
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        //用登录密码 English: Use login password
        handleNoti()
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView?.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        progressView?.progressTintColor = UIColor.ThemeView.highlight
        progressView?.trackTintColor = UIColor.ThemeView.bg

        progressView?.backgroundColor = UIColor.ThemeView.bg
        navCustomView.addSubview(progressView!)
        progressView?.snp.makeConstraints({ (make) in
            make.left.right.equalTo(0)
            make.bottom.equalToSuperview()
            make.height.equalTo(2)
        })
        checkNaviStyle()
    }
    
    func checkNaviStyle() {
        if let newUrl = URL.init(string: self.urlStr),let querys = newUrl.queryMap {
            if let nav = querys["navi_style"] {
                if nav == "transparent" {
                    self.transparentStyle()
                }
            }
            
            if let hideTitle = querys["navi_titleHide"] {
                if hideTitle == "1" {
                    self.setTitle("")
                }
            }
        }
    }
    
    func changeBgColor() {
        if let newUrl = URL.init(string: self.urlStr),let querys = newUrl.queryMap {
            if let color = querys["color"],color.count > 0 {
                self.webView.backgroundColor = UIColor.extColorWithHex("#\(color)")
            }
        }
    }
    
    func transparentStyle() {
        contentView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func configNaviBackBtn() {
        self.navCustomView.backView.addSubview(self.closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(navCustomView.popBtn.snp.right).offset(10)
            make.centerY.equalTo(navCustomView.popBtn)
            make.width.height.equalTo(45)
        }
        navCustomView.middleTitle.textAlignment = .center
        navCustomView.middleTitle.snp.remakeConstraints { (make) in
            make.centerY.equalTo(closeBtn)
            make.height.lessThanOrEqualTo(64)
            make.left.equalTo(96)
            make.width.equalTo(Device_W - 192)
        }

    }
    
    @objc func closeWebVc() {
        if let closeCallback = self.closeBlock {
            closeCallback()
        }else {
            self.popBack()
        }
    }
    
    func handleNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: Notification.Name(rawValue: "EXLoginSuccess"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginCanceled), name: Notification.Name(rawValue: "EXCancelLogin"), object: nil)
        //        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let title = webView.title {
                self.setTitle(title)
            }
        }
        if keyPath == "estimatedProgress" {
            if let progress = (change?[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                progressView?.progress = progress
            }
            return
        }
    }
    
    deinit {
        EXSWebCacheCleaner.clean()
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func loginSuccess() {
        // reload
        self.reload()
    }

    func reload() {
        self.excookies = EXNetParameterGenerator.getHeaderParams().map{"\($0)=\($1)"}
        let cookieScript = WKUserScript(source: self.cookieScript(),
                                        injectionTime: .atDocumentStart,
                                        forMainFrameOnly: false)
        self.webView.configuration.userContentController.addUserScript(cookieScript)

        if let url = URL.init(string: percentEncode(self.urlStr)) , urlStr.hasPrefix("http"){
            var request = URLRequest.init(url:url)
            request.setValue(excookies.joined(separator: ";"), forHTTPHeaderField: "Cookie")
            self.webView.load(request)
        }
    }
    
    @objc func loginCanceled() {
        self.popBack()
    }
    
    override func setNavCustomV() {
        self.navtype = .listtitle
    }
    
    func percentEncode(_ str: String) -> String {
        var charSet = CharacterSet.urlQueryAllowed
//        charSet.insert(charactersIn: "#")
        charSet.remove("#")
        let encodingURL = str.addingPercentEncoding(withAllowedCharacters: charSet)!
        return encodingURL
    }
    
    func loadUrl(_ urlStr : String,customCookies:[String] = [],needHandleUrl:Bool = true){
        if urlStr.isEmpty {
            return
        }
        if let url = URL.init(string: percentEncode(urlStr)) , urlStr.hasPrefix("http"){
            
            var handledUrl = percentEncode(urlStr)
            let currentFiatSymbol =  EXSwapPrivateConfig.shared.fiatCoinSymbol.uppercased()
            if let _ = url.query {
                handledUrl = handledUrl + "&isapp=1&ua=ios" + "&lan=" + LanguageHandler.phoneLanguage + "&cover=2&lang_coin=\(currentFiatSymbol)"
            }else {
                handledUrl = handledUrl + "?isapp=1&ua=ios" + "&lan=" + LanguageHandler.phoneLanguage + "&cover=2&lang_coin=\(currentFiatSymbol)"
            }
            print(handledUrl)
//            if customCookies.count > 0 {
//                self.excookies = self.excookies + customCookies
//            }
            if needHandleUrl {
                self.urlStr = handledUrl
            }else {
                self.urlStr = urlStr
            }
            guard URL(string: self.urlStr) != nil else {
                #if DEBUG
                    assert(false, "generate url failed [urlStr]: \(urlStr)")
                #endif
                return
            }
            var request = URLRequest.init(url:URL.init(string: self.urlStr)!)
            request.setValue(excookies.joined(separator:";"), forHTTPHeaderField: "Cookie")
            self.webView.load(request)
        }else{
            self.urlStr = urlStr
            self.webView.loadHTMLString(urlStr, baseURL: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView?.isHidden = true
        checkGoBack()
        changeBgColor()
        webView.evaluateJavaScript("document.title") { (result, error) in
            if let title = result as? String {
//                //print("网页标题: \(title)") English: Print ("Web page title: \ (title)")
                self.setTitle(title)
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView?.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView?.isHidden = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url{
//            if url.scheme?.lowercased() == "hiexcommand" {
//                let str = url.absoluteString.replacingOccurrences(of: "hiexcommand://", with: "hiexCommand://")
//                if EXNavigationHandler.sharedHandler.openURL(str) {
//                    decisionHandler(.cancel)
//                    return
//                }
//            }
            if url.scheme != "http" && url.scheme != "https"{
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    

    
    func checkGoBack() {
        if self.webView.canGoBack {
            self.closeBtn.isHidden = false
        }else {
            self.closeBtn.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        //print("navigationResponse Response = \(navigationResponse.response)")
        decisionHandler(.allow)
    }
}

extension EXSWebVC : WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == false  {
             webView.load(navigationAction.request)
         }
         return nil
     }
}


extension EXSWebVC: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == EXSJsHandler.handlerName {
            if let actionName = message.body as? String {
                switch actionName {
                case EXSJsActionName.login:
                    EXSwapPlatformSDK.shared.loginCallBack?()
                default:
                    break
                }
            }
        }
    }
}


final class EXSWebCacheCleaner {
    
    class func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        //print("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                //print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
}


enum EXSJsHandler {
    static let handlerName:String = "jsHandler"
}

enum EXSJsActionName {
    static let login:String = "WebLogin"
    
}


class EXSwapScriptMessageProxy: NSObject, WKScriptMessageHandler {
    
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(
            userContentController, didReceive: message)
    }
}

