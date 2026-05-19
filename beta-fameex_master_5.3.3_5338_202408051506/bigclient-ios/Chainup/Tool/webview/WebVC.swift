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
import Swap
class WebVC: NavCustomVC,WKNavigationDelegate {
    
    var urlStr = ""
    var kolTraderMyOrderNewBack: Bool = false
    var kolTradersListNew: Bool = false
    var contract: Bool = false
    typealias DissMissBlock = () -> ()
    var missBlock : DissMissBlock?
    var closeBlock : DissMissBlock?
    var cookieDomain:String = NetDefine.domain_host_url()
    var customTitle:String = ""
    var progressView: UIProgressView?
    
    lazy var closeBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.isHidden = true
        btn.setImage(UIImage.themeImageNamed(imageName:"personal_shutdown"), for: .normal)
        btn.addTarget(self, action: #selector(closeWebVc), for: .touchUpInside)
        return btn
    }()

    private var excookies:[String] = NetManager.sharedInstance.getHeaderParams().map{"\($0)=\($1)"}
    
    private func cookieScript() -> String {
        let cookies = excookies.map { "document.cookie = '\($0)';\(cookieAttributes());" }.joined()
//        print("cookie =>\(cookies)")
        return cookies
    }
    
    private func cookieAttributes() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEE, dd-MMM-yyyy HH:mm:ss zzz"
//        formatter.locale = Locale(identifier: "en_US")
//        formatter.timeZone = TimeZone(identifier: "GMT")
        //The format above cannot be recognized
        let expireDate = Date(timeIntervalSinceNow: (60 * 60 * 24 * 30))
        let expireString =   expireDate.timeStamp //  formatter.string(from: expireDate)
//        print("expireString =\(expireString)")
        return "domain='\(cookieDomain)'; expires='\(expireString)'; path=/ ;"
    }
    
    //https://m.chainapex.pro/zh_CN/app_operation/kolTraderMyOrderNew/?isapp=1
    override func navBack() {
        if self.kolTraderMyOrderNewBack{
//            print("webView sendMsgToWeb")
            sendMsgToWeb(method: "kolTraderMyOrderNewBack")
            return
        }
        
        if self.kolTradersListNew{
            self.popBack()
            return
        }
        if webView.canGoBack {
            webView.goBack()
        }else {
            self.popBack()
        }
    }
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.kolTraderMyOrderNewBack{
            sendMsgToWeb(method: "kolTraderMyOrderNewBack")
            return false
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.webView.allowsBackForwardNavigationGestures = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.missBlock?()
    }
    
    
    func sendMsgToWeb(method: String){
        
        webView.callHandler(method, arguments: nil) { _ in
            
        }
    }
    lazy var webView : DWKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences = WKPreferences()
        let userContentController = WKUserContentController()
        //        userContentController.addUserScript(wkUScript)
        userContentController.add(EXScriptMessageProxy(delegate: self), name: EXJsHandler.handlerName)
        userContentController.add(EXScriptMessageProxy(delegate: self), name: EXJsHandler.kolTraderMyOrderNewBack)
        let cookieScript = WKUserScript(source: self.cookieScript(),
                                        injectionTime: .atDocumentStart,
                                        forMainFrameOnly: false)
        userContentController.addUserScript(cookieScript)
        
        config.userContentController = userContentController
        
        
        let view = DWKWebView.init(frame: CGRect.zero, configuration: config)
        view.extUseAutoLayout()
        
        if #available(iOS 9.0, *) {
            view.allowsBackForwardNavigationGestures = true
        } else {
            /*
In iOS 8, first set the WKWebView
             webView.allowsBackForwardNavigationGestures = YES;
And then set it to NO again
             webView.allowsBackForwardNavigationGestures = NO;
As soon as a finger touches the screen, a crash will appear
             */
            view.allowsBackForwardNavigationGestures = false
        }
        view.navigationDelegate = self
        //Solve the problem of black edges at the bottom of web pages
        //        view.backgroundColor = UIColor.clear
        view.isOpaque = false //If this value is not set, the page background will always be white
        view.autoresizingMask = .flexibleHeight
        view.addJavascriptObject(EXJsApiMethodSwift(), namespace: nil)
        
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
        webView.dsuiDelegate = self as? WKUIDelegate
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        //Use login password
        handleNoti()
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
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
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        self.webView.allowsBackForwardNavigationGestures = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
       
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
        navCustomView.transparentStyle()
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
            make.width.equalTo(SCREEN_WIDTH - 192)
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
      
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if self.customTitle.count > 0 {
                return
            }
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
        WebCacheCleaner.clean()
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func loginSuccess() {
        // reload
        self.reload()
    }
    
    func reload() {
        self.excookies = NetManager.sharedInstance.getHeaderParams().map{"\($0)=\($1)"}
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
        charSet.insert(charactersIn: "#")
        let encodingURL = str.addingPercentEncoding(withAllowedCharacters: charSet)!
        return encodingURL
    }
    
    func loadUrl(_ urlStr : String,customCookies:[String] = []){
        if urlStr.isEmpty {
            return
        }
        if let url = URL.init(string: percentEncode(urlStr)) , urlStr.hasPrefix("http"){
            var handledUrl = percentEncode(urlStr)
            let currentFiatSymbol =  EXSwapPrivateConfig.shared.fiatCoinSymbol.uppercased()
            if let _ = url.query {
                handledUrl = handledUrl + "&isapp=1&ua=ios" + "&lan=" + LanguageHandler.priviatePhoneLanguage + "&cover=2&lang_coin=\(currentFiatSymbol)"
            }else {
                handledUrl = handledUrl + "?isapp=1&ua=ios" + "&lan=" + LanguageHandler.priviatePhoneLanguage + "&cover=2&lang_coin=\(currentFiatSymbol)"
            }
            if let up = UIColor.Ex.up1.rgbString, let down = UIColor.Ex.down1.rgbString {
                handledUrl += "&color_up=\(up)&color_down=\(down)"
            }
//            print(handledUrl)
//            handledUrl = "http://192.168.0.104/cookie.html"
            //Non overseas version, regardless of overseas version
            if EXKitStanders.isOverSeasVersion() == false,
               EXNetworkDoctor.sharedManager.currentHost.count > 0 {
                //Determine whether the current optimal host and access domain are consistent
                let host = urlStr.hostStr()
                if host != EXNetworkDoctor.sharedManager.currentHost {
                    if let urlhost = url.host {
                        //In case of inconsistency, check if the current host is in the accelerated domain name (belonging to our own URL) - "Replace, do not replace the others
                        if EXNetworkDoctor.sharedManager.detectHostIsSaas(host: urlhost) {
                            handledUrl = EXNetworkDoctor.sharedManager.changeApiTo(domain: EXNetworkDoctor.sharedManager.currentHost, oldDomainUrl: handledUrl)
//                            handledUrl = handledUrl.replacingOccurrences(of: host, with: EXNetworkDoctor.sharedManager.currentHost)
                        }else {
                            //                        //If it is a link to the customer's main domain name, also switch it off
                            if host == EXAppConfigManager.sharedInstance.companyDomain() {
                                cookieDomain = host
                            }
                        }
                    }
                }
            }
            if customCookies.count > 0 {
                self.excookies = self.excookies + customCookies
            }
            self.urlStr = handledUrl
            var request = URLRequest.init(url:URL.init(string: handledUrl)!)
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
//        print("webView didFinish \(navigation)")
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView?.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        print("webView didStartProvisionalNavigation navigation = \(navigation)")
        progressView?.isHidden = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
//        print("webView decidePolicyFor navigationAction= decisionHandler =\(navigationAction.request.url)")
        if let url = navigationAction.request.url{
            if url.absoluteString.contains(quickTradeBanxaUrlKey){
                self.gotoQuickTrade()
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
            
//            if url.absoluteString.contains("kolTraderMyOrderNew"){
//                self.kolTraderMyOrderNewBack = true
//                decisionHandler(WKNavigationActionPolicy.allow)
//                return
//            }
            if url.scheme != "http" && url.scheme != "https"{
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func gotoQuickTrade(){
        if let vcs = self.navigationController?.viewControllers{
            var destion: UIViewController?
            for vc in vcs {
                if vc.isKind(of: EXQuickBuyCoinViewController.self){
                    destion = vc
                }
            }
            if let d = destion{
                self.navigationController?.popToViewController(destion!, animated: true)
            }
        }
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
        self.kolTraderMyOrderNewBack = false
//        print("webView decidePolicyFor  navigationResponse = decisionHandler Response =\(navigationResponse.response)")
        if let url = navigationResponse.response.url?.absoluteString{
            if url.contains("kolTraderMyOrderNew"){
                self.kolTraderMyOrderNewBack = true
            }
            if url.contains("kolTradersListNew"){
                self.kolTradersListNew = true
            }
//            print("webView navigationResponse = \(url)  kolTraderMyOrderNewBack = \(kolTraderMyOrderNewBack)")
        }
        decisionHandler(.allow)
    }
}

extension WebVC : WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        print("webView createWebViewWith = decisionHandler navigationAction.request = \(navigationAction.request.url?.absoluteString)")

        if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == false  {
             webView.load(navigationAction.request)
         }
         return nil
     }
}


extension WebVC: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == EXJsHandler.handlerName {
            if let actionName = message.body as? String {
                switch actionName {
                case EXJsActionName.login:
                    BusinessTools.modalLoginVC("1")
                default:
                    break
                }
            }
        }
    }
}


final class WebCacheCleaner {
    
    class func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }
}

