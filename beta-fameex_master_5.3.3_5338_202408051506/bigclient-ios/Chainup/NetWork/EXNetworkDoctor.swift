//
//  EXNetworkDoctor.swift
//  Chainup
//
//  Created by liuxuan on 2023/11/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit
import Swap
//永久不会挂的请求 https://Saas oss cn hongkong aliyuncs. com/update json

enum EXApiType:String {
    case appApi = "appApiHost"
    case otcApi = "otcApiHost"
    case contractApi = "contractApiHost"
    case redPackAPi = "redPackApiHost"
}

enum EXWsType:String {
    case kline = "kline"
    case talk = "talk"
    case cows = "cows"
}

enum EXCerPlan:String {
    case cer = "ioscer"//Corresponding cer
    case cerPlanB = "lcuiww"//Corresponding to cer1
    case cerPlanC = "xtgta"//Corresponding to cer2
    case cerPlanD = "mrzkjc"//Corresponding to cer2
}

class EXNetworkDoctor: NSObject {

    private var appApihost :String = NetDefine.http_host_url
    private var otcApi :String = NetDefine.http_host_url_otc
    private var redpackApi :String = NetDefine.http_host_url_redpacket
    private var wsKline :String = NetDefine.wss_host_url
    private var wsTalk :String = NetDefine.wss_host_url2

    //New contract
    private var contractApiV2 :String = NetDefine.http_host_url_contractV2
    private var wsContractV2 :String = NetDefine.wss_host_contractV2

    let disposebag = DisposeBag()
    
    var hosts:[String]?
    var wshosts:[String]?

    var currentHost:String = ""
    var currentWs:String = ""
    let assetName = "updateV3.json"
    let regexStr = "00\\d{5}"
    let downloadCer = "ioscer.cer"
    var useDownload :Bool = false
    var downloadCerData :NSData?
    var netWorkCorrector: EXNetworkCorrector?
    
    private var ud: UserDefaults {
        return UserDefaults.standard
    }
    
    static let `manager` = EXNetworkDoctor()
    open class var sharedManager: EXNetworkDoctor {
        return manager
    }
    
    func configNetWork() {
#if DEBUG
        self.currentHost = NetDefine.http_host_url.hostStr()
        self.currentWs = NetDefine.http_host_url.hostStr()
        return
#endif
        
        //Overseas version does not need to modify any values
        if EXKitStanders.isOverSeasVersion() {
            return
        }
        if let historyDomain = self.ud[.domainCfg],
           let historyWs = self.ud[.wsCfg],
           let historyRoot = self.ud[.useRootCfg],
           let isDownloadType = self.ud[.isDownloadType]
        {
            self.currentHost = historyDomain
            self.currentWs = historyWs
            self.useDownload = (isDownloadType == "1")
            let location = DefaultDownloadDir.appendingPathComponent(downloadCer)
            if let cerdata = NSData(contentsOfFile: location.path) {
                self.downloadCerData = cerdata
            }
//            print("Use history domain name and certificate, domain name is:  (currentHost), ws is  (historyWs)")
            if historyRoot == "1" {
                self.updateAllDomain(use: true)
            }else if historyRoot == "0" {
                self.updateAllDomain(use: false)
            }
        }else {
            self.currentHost = NetDefine.http_host_url.hostStr()
            self.currentWs = NetDefine.http_host_url.hostStr()
        }
        //SAAS starts downloading configuration
        self.startScanNetwork()
    }
    
    //If the network is unobstructed, proceed to the next verification step
    func startScanNetwork() {
        if self.checkIsSaas() {
            self.getConfigs()
        }
    }
    
    func saasFileName() ->String {
        return "https://chainup.oss-accelerate.aliyuncs.com/updateV2.json"
    }
    
    func companyCustomName() ->String {
        var cid = EXAppConfigManager.sharedInstance.companyID()
        if cid.count == 0 {
            cid = EXHomeViewModel.appdCompanyID()
        }
        if cid.count == 0 {
            return ""
        }else {
            return "update_\(cid).json"
        }
    }
    
    private func getConfigs() {
        DLServiceProvider.request(.downloadAsset(assetName: assetName)) {[weak self] result in
            switch result {
            case .success:
                self?.tryDownloadCustomCfg()
            case .failure(_):
                self?.tryDownloadCustomCfg()
                break
            }
        }
    }
    
    func tryDownloadCustomCfg() {
        let company = companyCustomName()
        if company.isEmpty {
            return
        }
        
        DLServiceProvider.request(.downloadCustomAsset(assetName:company)) {[weak self] result in
            switch result {
            case .success:
                self?.readLocalFile()
            case .failure(_):
                self?.readLocalFile()
                break
            }
        }
    }
    
    func getLocalFile(url:String) -> EXNetworkHostsModel? {
        let location = DefaultDownloadDir.appendingPathComponent(url)
        if let jsonData = NSData(contentsOfFile: location.path) {
            do{
                if let json = try JSONSerialization.jsonObject(with: jsonData as Data, options: []) as? [String:AnyObject] {
                    if let model = EXNetworkHostsModel.mj_object(withKeyValues: json) {
                        return model
                    }
                }
            }catch let error as NSError{
//                print("Parsing error:  (error. localizedDescription)")
            }
        }
        return nil
    }

    func readLocalFile() {
        let customFileModel = getLocalFile(url: companyCustomName())
        let saasFileModel = getLocalFile(url: assetName)
        if let cModel = customFileModel,let saasM = saasFileModel {
            if cModel.merge_open == "1" {
                saasM.links.append(contentsOf: cModel.links)
                saasM.ws_links.append(contentsOf: cModel.links)
                saasM.links = saasM.links.filterDuplicates({$0.hostName})
                saasM.ws_links = saasM.ws_links.filterDuplicates({$0.hostName})
                self.updateHostConfigure(saasM)
            }else {
                saasM.links = cModel.links
                saasM.ws_links = cModel.links
                self.updateHostConfigure(saasM)
            }
        }else if let saasM = saasFileModel {
            self.updateHostConfigure(saasM)
        }
    }
    
    private func updateHostConfigure(_ model:EXNetworkHostsModel) {
        if model.ios_on == false {
            self.ud.remove(key: .wsCfg)
            self.ud.remove(key: .domainCfg)
            self.ud.remove(key: .useRootCfg)
            self.ud.remove(key: .isDownloadType)
            return
        }
        //1. Check if the current host exists in the special list
        let original = NetDefine.http_host_url
        var regex: NSRegularExpression = NSRegularExpression.init()
        //Constructing Regular Expressions
        do {
            regex = try NSRegularExpression.init(pattern: regexStr, options: NSRegularExpression.Options.caseInsensitive)
        } catch {
            
        }
        let res = regex.matches(in: original, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, original.count))
        var company_id = ""
        if res.count == 1 {
            let resRst = res[0]
            company_id = (original as NSString).substring(with: resRst.range)
        }
        if company_id.count > 0 {
            var specialModel:EXSpecialModel?
            for item in model.special_list {
                let res = regex.matches(in: item.host, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, item.host.count))
                if res.count == 1 {
                    let specialRst = res[0]
                    let special_company_id = (item.host as NSString).substring(with: specialRst.range)
                    //If it is equal to the one in the special list
                    if company_id == special_company_id {
                        specialModel = item
                        break
                    }
                }
            }
            var testModel:EXTestModel?
            
            for item in model.test_list {
                let res = regex.matches(in: item.host, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, item.host.count))
                if res.count == 1 {
                    let specialRst = res[0]
                    let special_company_id = (item.host as NSString).substring(with: specialRst.range)
                    //If it is equal to the one in the special list
                    if company_id == special_company_id {
                        testModel = item
                        break
                    }
                }
            }
            
            if specialModel == nil {
                hosts = model.links.map({ $0.hostName}).filter{$0.count>0}
                wshosts = model.ws_links.map({ $0.hostName}).filter{$0.count>0}
            }
            
            if let specialM = specialModel {
                //Special List
                self.changeApiToRoot(model: specialM)
            }else if let testM = testModel {
                self.changeApiToSpeedUP(withDomain: testM.saas_domain, cer: testM.saas_cer_fileName)
            }else {
                let links = model.links.flatMap { (item) -> [String] in
                    return [item.hostName]
                }
                let wslinks = model.ws_links.flatMap { (item) -> [String] in
                    return [item.hostName]
                }
                netWorkCorrector = EXNetworkCorrector.init(retryCount: model.retryCount, retryInteval: model.retryInterval, lines: links,wsLines: wslinks,differance:model.differance)
                netWorkCorrector?.startMonitoring()
                //If there is a locally selected domain and it is in hosts, it will not be updated
                guard let localChoiceDomain = self.ud[.localChoiceDomainCfg], let hostlist = hosts, hostlist.contains(localChoiceDomain) else {
                    
                    //SAAS general users
                    self.changeApiToSpeedUP(withDomain: model.saas_domain, cer: model.saas_cer_fileName)
                    return
                }
            }
        }else {
            #if DEBUG
            hosts = model.links.map({ $0.hostName}).filter{$0.count>0}
            let links = model.links.flatMap { (item) -> [String] in
                return [item.hostName]
            }
            let wslinks = model.ws_links.flatMap { (item) -> [String] in
                return [item.hostName]
            }
            netWorkCorrector = EXNetworkCorrector.init(retryCount: model.retryCount, retryInteval: model.retryInterval, lines: links,wsLines: wslinks,differance:model.differance)
            netWorkCorrector?.startMonitoring()
            #endif
        }
    }
    
    private func changeApiToRoot(model:EXSpecialModel) {
        self.currentHost = model.force_domain
        self.currentWs = model.force_domain
        self.updateAllDomain(use: true)
    }
    
    func handleDownloadSuccess(_ domain:String) {
        let location = DefaultDownloadDir.appendingPathComponent(downloadCer)
        let downloadData = NSData(contentsOfFile: location.path)
        do{
            if let cerData = downloadData  {
                self.downloadCerData = cerData
                self.currentHost = domain
                self.currentWs = domain
                self.updateAllDomain(use: false)
                self.ud[.isDownloadType] = "1"
                self.useDownload = true
            }
        }catch let error as NSError{
//            print("Parsing error:  (error. localizedDescription)")
        }
    }
    
    
    private func changeApiToSpeedUP(withDomain:String,cer:String) {
        if withDomain.count > 0,cer.count > 0 {
            if cer == "download" {
                DLServiceProvider.request(.downloadAsset(assetName: downloadCer)) {[weak self] result in
                    switch result {
                    case .success:
                        self?.handleDownloadSuccess(withDomain)
                    case .failure(_):
                        break
                    }
                }
            }else {
                self.ud[.isDownloadType] = "0"
                self.currentHost = withDomain
                self.currentWs = withDomain
                self.updateAllDomain(use: false)
            }
        }
    }
    
    static func doctorHost() ->String { //Download File - Switch Link - Download Certificate - Privatization Temporarily Not Used
        return "https://chainup.oss-accelerate.aliyuncs.com/"
//          return "https://bigcustom-oss.oss-cn-hongkong.aliyuncs.com/"

    }
    
    static func customLineUrl() ->String { //Configure link switching - privatization temporarily not needed
        return "https://bigcustom-oss.oss-cn-hongkong.aliyuncs.com/domain/"
        //https://bigcustom-oss.oss-cn-hongkong.aliyuncs.com/upload/20201130171506680.apk
    }
    
}

extension EXNetworkDoctor {
    static func getContractProfitUrl() -> String {
        var urlString = "https://mco."
        var currentDomain =  EXAppConfigManager.sharedInstance.companyDomain() //      EXNetworkDoctor.sharedManager.currentHost
        if currentDomain == "" {
            currentDomain = EXNetworkDoctor.sharedManager.getAppAPIHost().hostStr()
        }
        urlString += currentDomain
        if (LanguageHandler.phoneLanguage != ""){
            urlString += ("/" + LanguageHandler.phoneLanguage)
        }
        urlString += "/app_operation/coProfitRecord"
        //  https://mco.dw2nn.com/zh_CN/app_operation/coProfitRecord
        print("最终=>urlString =\(urlString) ")
        return urlString
    }
    
    private func checkIsSaas() -> Bool {
        if let plistpath = Bundle.main.path(forResource: "Info", ofType: "plist"){
            if let dict = NSDictionary.init(contentsOfFile: plistpath){
                if let homeViewStatus = dict["appswitchsaas"] as? String{
                    switch homeViewStatus{
                    case "1":
                        return true
                    case "0":
                        return false
                    default:
                        return true
                    }
                }
            }
        }
        return true
    }
    
    //Directly return the configured API host without SAAS
    func getAppAPIHost() -> String {
        if checkIsSaas() {
            return self.appApihost
        }else {
            return NetDefine.http_host_url
        }
    }
    
    func getOtcAPIHost() -> String {
        if checkIsSaas() {
            return self.otcApi
        }else {
            return NetDefine.http_host_url_otc
        }
    }
    
    func getRedPackAPIHost() -> String {
        if checkIsSaas() {
            return self.redpackApi
        }else {
            return NetDefine.http_host_url_redpacket
        }
    }
    
    func getKlineWs() -> String {
        if checkIsSaas() {
            return self.wsKline
        }else {
            return NetDefine.wss_host_url
        }
    }
    
    func getTalkWs() -> String {
        if checkIsSaas() {
            return self.wsTalk
        }else {
            return NetDefine.wss_host_url2
        }
    }
    
    func getNewContractAPI() -> String {
        if checkIsSaas() {
            return self.contractApiV2
        }else {
            return NetDefine.http_host_url_contractV2
        }
    }
    
    func getNewContractWs() -> String {
        if checkIsSaas() {
            return self.wsContractV2
        }else {
            return NetDefine.wss_host_contractV2
        }
    }
    
    //Check if the domain name is an accelerated domain name
    //Incoming host, extracting primary domain
    //Assuming there is no list, go to the host to check the 000xxxx domain name
    func detectHostIsSaas(host:String) ->Bool {
        if let allLinks = self.hosts,allLinks.count > 0 {
            var isSaas = false
            for domain in allLinks {
                if host.contains(domain) {
                    isSaas = true
                    break
                }
            }
            return isSaas
        }else {
            var regex: NSRegularExpression = NSRegularExpression.init()
            let linkPattern: String = regexStr
            //Constructing Regular Expressions
            do {
                regex = try NSRegularExpression.init(pattern: linkPattern, options: NSRegularExpression.Options.caseInsensitive)
            } catch {
            }
            let res = regex.matches(in: host, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, host.count))
            for _ in res
            {
                return true
            }
            return false
        }
    }
}

extension EXNetworkDoctor {
    //Switch between API and ws
    
    func updateAllDomain(use:Bool) {
        updateApiDomain(useRoot: use)
        updateWsDomain(useRoot: use)
    }
    
    func changeApiTo(domain:String,oldDomainUrl:String) -> String {
//        print("To switch to:  (domain), the old line format is:  (oldDomainUrl)")
        var backUrlString = oldDomainUrl
        let oldDomain = oldDomainUrl.hostStr()
        let newDomainIsIp = NetDefine.match(domain, regularEnum: .ip)
        let oldDomainIsIp = NetDefine.match(oldDomain, regularEnum: .ip)

        //Both switches are IP addresses
        //The new one is IP, domain ->IP mode
        //The old one is in IP, IP ->domain mode
        //都不是ip模式,domainA切换到domainB//The most primitive mode
        if newDomainIsIp && oldDomainIsIp {
            backUrlString = oldDomainUrl.replacingOccurrences(of: oldDomain, with: domain)
        }else if newDomainIsIp {
            /*
            old : https://appapi0001493.lcuiww.top/
            new : https://180.163.62.125/appapi0001493/
             */
            //Take out the company, appapi0001493
            let hostCompany = oldDomainUrl.hostCompany()
            if let url = URL.init(string: oldDomainUrl),let host = url.host {
                let newDomain = domain + "/\(hostCompany)"
                backUrlString = oldDomainUrl.replacingOccurrences(of:host, with: newDomain)
            }
        }else if oldDomainIsIp {
            /*
             new :https://appapi0001493.lcuiww.top/
             old: https://180.163.62.125/appapi0001493/
             */
            let hostCompany = oldDomainUrl.hostCompany(true)
            if let url = URL.init(string: oldDomainUrl),let host = url.host {
                let newDomain = "\(hostCompany)" + ".\(domain)"
                let oldDomain = host + "/\(hostCompany)"
                backUrlString = oldDomainUrl.replacingOccurrences(of: oldDomain, with: newDomain)
            }
        }else {
            backUrlString = oldDomainUrl.replacingOccurrences(of: oldDomain, with: domain)
        }
//        print("Return value:  (backUrlString)")
        return backUrlString
    }
    
    func changeCurrentHost(selectedHost:String) {
        if selectedHost != self.currentHost, let hostList = hosts, hostList.contains(selectedHost) {
            self.currentHost = selectedHost
            updateApiDomain(useRoot: false)
            self.ud[.localChoiceDomainCfg] = selectedHost
            if let appDelegate:AppDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.changeHosts()
            }
        }
    }
    
    func changeWsHost(selectedHost:String) {
        if selectedHost != self.currentWs, let hostList = wshosts, hostList.contains(selectedHost) {
            self.currentWs = selectedHost
            updateWsDomain(useRoot:false)
            EXWebSocket.marketService.reconnectServer()
        }
    }
    
    func updateApiDomain(useRoot:Bool) {
        if useRoot {
            self.appApihost = "https://appapi." + currentHost + "/"
            self.otcApi = "https://otcappapi." + currentHost + "/"
            self.redpackApi = "https://service." + currentHost + "/hongbaoapi/"
            self.contractApiV2 = "https://futuresappapi." + currentHost + "/"
        }else {
            self.appApihost = self.changeApiTo(domain: currentHost, oldDomainUrl: appApihost)
            self.otcApi = self.changeApiTo(domain: currentHost, oldDomainUrl: otcApi)
            self.redpackApi = self.changeApiTo(domain: currentHost, oldDomainUrl: redpackApi)
            self.contractApiV2 = self.changeApiTo(domain: currentHost, oldDomainUrl: contractApiV2)
        }
        self.synchronize(useRoot: useRoot)
    }
    
    //Convert IP type back to domain
    func switchWsToDomainFormat() {
        let wsK = NetDefine.wss_host_url
        let wsTalk = NetDefine.wss_host_url2
        let o_wsContractV2 :String = NetDefine.wss_host_contractV2

        let oldDomain = wsKline.hostStr()
        self.wsKline = wsK.replacingOccurrences(of: oldDomain, with:currentWs )
        self.wsTalk = wsTalk.replacingOccurrences(of: oldDomain, with: currentWs)
        self.wsContractV2 = o_wsContractV2.replacingOccurrences(of: oldDomain, with: currentHost)
    }
    //Only update domain names related to contracts
    func updateSwapDomain(selectedHost:String, isWs: Bool) {
        if isWs {
            if let hostList = wshosts, hostList.contains(selectedHost) {
                self.wsContractV2 = self.changeApiTo(domain: selectedHost, oldDomainUrl: wsContractV2)
                EXSwapPrivateConfig.shared.ws =  self.wsContractV2
            }
        }else{
            if let hostList = hosts, hostList.contains(selectedHost) {
                self.contractApiV2 = self.changeApiTo(domain: selectedHost, oldDomainUrl: contractApiV2)
                EXSwapPrivateConfig.shared.base_host =  self.contractApiV2
            }
        }
       
    }
    //Let's just ignore the contract ws
    func updateWsDomain(useRoot:Bool) {
        if useRoot {
            self.wsKline = "wss://ws." + currentWs + "/kline-api/ws"
            self.wsTalk = "wss://ws2." + currentWs + "/otc-chat/chatServer/"
            self.wsContractV2 = "wss://futuresws." + currentWs + "/kline-api/ws"
        }else {
            self.wsKline = self.changeApiTo(domain: currentWs, oldDomainUrl: wsKline)
            self.wsTalk = self.changeApiTo(domain: currentWs, oldDomainUrl: wsTalk)
            self.wsContractV2 = self.changeApiTo(domain: currentWs, oldDomainUrl: wsContractV2)
        }
        self.synchronize(useRoot: useRoot)
    }
    
    private func synchronize(useRoot:Bool) {
        
        self.ud[.domainCfg] = self.currentHost
        self.ud[.wsCfg] = self.currentWs
        self.ud[.useRootCfg] = useRoot ? "1" : "0"
        self.ud.synchronize()
    }
    
    
}


extension EXNetworkDoctor {
    
    //Abort the function being automatically calculated
    func abortingAutoProcess() {
        netWorkCorrector?.aborting = true
    }
}

//For debugging, it doesn't matter
extension EXNetworkDoctor {
    
    func changeDebugApi(useHost:String) {
        self.appApihost = "https://appapi." + useHost + "/"
        self.otcApi = "https://otcappapi." + useHost + "/"
        self.redpackApi = "https://service." + useHost + "/hongbao/"
        self.wsKline = "wss://ws." + useHost + "/kline-api/ws"
        self.wsTalk = "wss://ws2." + useHost + "/otc-chat/chatServer/"
    }
    
    func changeDeubgSaas(companID:String) {
        self.appApihost = "https://appapi000\(companID).hlinnn.top/"
        self.otcApi = "https://otcappapi000\(companID).hlinnn.top/"
        self.redpackApi = "https://service000\(companID).hlinnn.top/hongbaoapi/"
        self.wsKline = "wss://ws000\(companID).hlinnn.top/kline-api/ws"
        self.wsTalk = "wss://ws2000\(companID).hlinnn.top/otc-chat/chatServer/"
    }
    
}

