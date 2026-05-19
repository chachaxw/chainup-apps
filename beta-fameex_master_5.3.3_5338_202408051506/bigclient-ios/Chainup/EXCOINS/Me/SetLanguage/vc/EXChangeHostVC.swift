//
//  EXChangeHostVC.swift
//  Chainup
//
//  Created by chainup on 2023/6/16.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit

class EXChangeHostVC: NavCustomVC {
    
    private var api_dataSource:[EXHostEntity] = []
    private var ws_dataSource:[EXHostEntity] = []

    private var countDownValue = 0
    private var pendingPings = [EXPing]()
    
    lazy var refreshBtn:UIButton = {
        let refresh = UIButton.init(type: .custom)
        refresh.setTitle("customSetting_action_testSpeed".localized(), for: .normal)
        refresh.setTitle("customSetting_action_testing".localized(), for: .selected)
        refresh.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        refresh.setTitleColor(UIColor.ThemeLabel.colorHighlight, for:.normal)
        refresh.extSetAddTarget(self, #selector(clickRefreshBtn))
        return refresh
    }()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXChangeHostTableViewCell.classForCoder()], ["EXChangeHostTableViewCell"])
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EXNetworkDoctor.sharedManager.abortingAutoProcess()
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        initializeDataSource()
        
        startPing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            for item in api_dataSource {
                if item.selected, item.status == .success {
                    EXNetworkDoctor.sharedManager.changeCurrentHost(selectedHost: item.host)
                }
            }
            
            for item in ws_dataSource {
                if item.wsSelected, item.status == .success {
                    EXNetworkDoctor.sharedManager.changeWsHost(selectedHost: item.host)
                }
            }
            stopPing()
        }
        
    }
    
    private func stopPing() {
        for item in pendingPings {
            item.stopWs()
        }
    }
    
    private func startPing() {
        self.showLoading()
        self.refreshBtn.isSelected = true
        countDownValue = 0
        for i in 0..<api_dataSource.count {
            api_dataSource[i].status = .testing
        }
        for i in 0..<ws_dataSource.count {
            ws_dataSource[i].status = .testing
        }
        
        for item in pendingPings {
            item.startPinging()
        }
        tableView.reloadData()
    }
    
    private func initializeDataSource() {

        let appapiHost = EXNetworkDoctor.sharedManager.getAppAPIHost()
        let wsApiHost = EXNetworkDoctor.sharedManager.getKlineWs()
        let oldDomain = appapiHost.hostStr()
        let wsOldDomain = wsApiHost.hostStr()
        if let apihosts = EXNetworkDoctor.sharedManager.hosts {
            for (_,host) in apihosts.enumerated() {
                let urlString = EXNetworkDoctor.sharedManager.changeApiTo(domain: host, oldDomainUrl: appapiHost)

                let hostStatus = EXHostEntity(status: .none,
                                              host: host,
                                              selected: host == oldDomain )
                api_dataSource.append(hostStatus)
                
                let ping = EXPing(host: host,address: urlString, type:.api)
                ping.delegate = self
                pendingPings.append(ping)
            }
        }
        
        if let wshosts = EXNetworkDoctor.sharedManager.wshosts {
            for (_,host) in wshosts.enumerated() {
                let wsUrlString = EXNetworkDoctor.sharedManager.changeApiTo(domain: host, oldDomainUrl: wsApiHost)
                
                let hostStatus = EXHostEntity(status: .none,
                                              host: host,
                                              wsSelected: host == wsOldDomain)
                ws_dataSource.append(hostStatus)
                
                let ping = EXPing(host: host,address: wsUrlString, type: .ws)
                ping.delegate = self
                pendingPings.append(ping)
            }
        }
        
    }
    
    override func setNavCustomV() {
        self.setTitle("\(LanguageTools.getString(key: "customSetting_action_changeHost"))")
        let btn = UIButton()
        btn.setImage(UIImage.themeImageNamed(imageName: "fiat_order"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickBtn))
        self.navCustomView.addSubview(btn)
        
  
        self.navCustomView.addSubview(self.refreshBtn)
        
        btn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.navCustomView.popBtn)
            make.width.height.equalTo(48)
            make.right.equalToSuperview().offset(0)
        }
        refreshBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.navCustomView.popBtn)
            make.right.equalTo(btn.snp.left)
        }
        self.xscrollView = tableView
        self.lastVC = true
    }
    
    @objc func clickRefreshBtn() {
        self.startPing()
    }
    
    @objc func clickBtn() {
        var apiResponds:[String] = []
        var wsResponds:[String] = []
        for item in api_dataSource {
            apiResponds.append(item.apiRtt)
        }
        
        for item in ws_dataSource {
            wsResponds.append(item.wsRtt)
        }
       
        let webvc = WebVC()
        #if DEBUG
        webvc.loadUrl("http://m.hiotc.pro/zh_CN/app_operation/network/",
                      customCookies:[
                        "ApiSpeed=\(apiResponds.joined(separator: ","))",
                        "WsSpeed=\(wsResponds.joined(separator: ","))"])
        #else
        webvc.loadUrl("https://m0001003.lcuiww.top/zh_CN/app_operation/network/",
                      customCookies:[
                        "ApiSpeed=\(apiResponds.joined(separator: ","))",
                        "WsSpeed=\(wsResponds.joined(separator: ","))"])
        #endif

        self.navigationController?.pushViewController(webvc, animated: true)
    }
}

extension EXChangeHostVC : EXPingDelegate {
    
    func ping(_ ping: EXPing, didReceive entity: EXPingEntity) {
        countDownValue += 1
        if ping.type == .api {
            for (i,item) in api_dataSource.enumerated() {
                if item.host == entity.host {
                    if item.status != .unusable {
                        let rtt = entity.rtt()
                        api_dataSource[i].apiRtt = "\(rtt.0)"
                        api_dataSource[i].rttColor = rtt.1
                        api_dataSource[i].apiTime = entity.apiTime()
                        api_dataSource[i].status = .success
                    }
                    break;
                }
            }
        }else {
            for (i,item) in ws_dataSource.enumerated() {
                if item.host == entity.host {
                    if item.status != .unusable {
                        let wsrtt = entity.wsRtt()
                        ws_dataSource[i].wsRtt = "\(wsrtt.0)"
                        ws_dataSource[i].wsrttColor = wsrtt.1
                        ws_dataSource[i].wsTime = entity.wstime()
                        ws_dataSource[i].status = .success
                    }
                    break;
                }
            }
        }
        checkProcessAndRefresh()
    }
    
    func ping(_ ping: EXPing, didFail entity: EXPingEntity) {
        
        countDownValue += 1
        if ping.type == .api {
            for (i,item) in api_dataSource.enumerated() {
                if item.host == entity.host {
                    api_dataSource[i].status = .unusable
                    api_dataSource[i].apiTime = entity.apiTime()
                    break;
                }
            }
        }else  {
            for (i,item) in ws_dataSource.enumerated() {
                if item.host == entity.host {
                    ws_dataSource[i].status = .unusable
                    ws_dataSource[i].wsTime = entity.wstime()
                    break;
                }
            }
        }
        checkProcessAndRefresh()
    }
    
    func checkProcessAndRefresh() {
        if countDownValue == pendingPings.count {
            self.dismissLoading()
            self.refreshBtn.isSelected = false
            let apisorted = api_dataSource.filter({return $0.apiTime != "+" }).sorted { a, b in
                let time = NumberHandler.handleDouble(a.apiTime)
                let timeB = NumberHandler.handleDouble(b.apiTime)
                return time < timeB
            }
            
            let wssorted = ws_dataSource.filter({return $0.wsTime != "+" }).sorted { a, b in
                let time = NumberHandler.handleDouble(a.wsTime)
                let timeB = NumberHandler.handleDouble(b.wsTime)
                return time < timeB
            }
            if apisorted.count > 0,wssorted.count > 0 {
                let firstApi = apisorted[0]
                let firstWs = wssorted[0]
                var firstApiIdx = -1
                var firstWsIdx = -1
                for (idx,api) in api_dataSource.enumerated() {
                    if api.host == firstApi.host {
                        firstApiIdx = idx
                        break
                    }
                }
                
                for (idx,ws) in ws_dataSource.enumerated() {
                    if ws.host == firstWs.host {
                        firstWsIdx = idx
                        break
                    }
                }
                if firstApiIdx >= 0 {
                    self.resetDataSourceSelectedStatus(idx: firstApiIdx, type: .api)
                }
                if firstWsIdx >= 0 {
                    self.resetDataSourceSelectedStatus(idx: firstWsIdx, type: .ws)
                }
            }
            
        }
        tableView.reloadData()
    }
}

extension EXChangeHostVC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = EXChangeHostHeader.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 30))
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(api_dataSource.count, ws_dataSource.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var apientity:EXHostEntity?
        var wsentity:EXHostEntity?

        let cell = tableView.dequeueReusableCell(withIdentifier: "EXChangeHostTableViewCell")! as! EXChangeHostTableViewCell
        if api_dataSource.count > indexPath.row {
            apientity = api_dataSource[indexPath.row]
        }
        if ws_dataSource.count > indexPath.row {
            wsentity = ws_dataSource[indexPath.row]
        }
        cell.nameLabel.text = "\("customSetting_action_host".localized())\(indexPath.row + 1)"

//        #if DEBUG
//        cell.nameLabel.text = apientity?.host
//        #endif
        cell.bindDomainEntity(entity: apientity, wsentity: wsentity)
        cell.domainCallback = {[weak self] domain in
            self?.changeApiHost(entity: domain,type:.api,idxPath: indexPath)
        }
        cell.wsCallback = {[weak self] domain in
            self?.changeApiHost(entity: domain,type: .ws,idxPath: indexPath)
        }
        
        return cell
    }
    
    func changeApiHost(entity:EXHostEntity,type:EXPingType,idxPath:IndexPath) {
        if  entity.status == .unusable || entity.status == .testing {
            //remind
            EXAlert.showFail(msg: "\( "customSetting_action_host".localized())\(entity.statusStr())")
            return;
        }
        resetDataSourceSelectedStatus(idx: idxPath.row, type: type)
    }
    
    private func resetDataSourceSelectedStatus(idx:Int,type:EXPingType) {
        
        if type == .api {
            for i in 0..<api_dataSource.count {
                api_dataSource[i].selected = false
            }
            api_dataSource[idx].selected = true
        }else if type == .ws {
            for i in 0..<ws_dataSource.count {
                ws_dataSource[i].wsSelected = false
            }
            ws_dataSource[idx].wsSelected = true
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

    }
    
}

class EXChangeHostHeader:UIView {
    
    let api_x_position = SCREEN_WIDTH * 0.285
    let ws_x_position = SCREEN_WIDTH * 0.74
    
    lazy var titleApi:UILabel = {
        let t = UILabel()
        t.font = UIFont.ThemeFont.SecondaryMedium
        t.textColor = UIColor.ThemeLabel.colorMedium
        t.text = "customSetting_title_apiSpeed".localized()
        return t
    }()
    
    lazy var titleWs:UILabel = {
        let t = UILabel()
        t.font = UIFont.ThemeFont.SecondaryMedium
        t.textColor = UIColor.ThemeLabel.colorMedium
        t.text = "customSetting_title_wsSpeed".localized()
        return t
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(titleApi)
        self.addSubview(titleWs)
        titleApi.snp.makeConstraints { make in
            make.left.equalTo(api_x_position)
            make.centerY.equalToSuperview()
        }
        titleWs.snp.makeConstraints { make in
            make.left.equalTo(ws_x_position)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

