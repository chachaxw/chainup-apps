//
//  EXSwapSettingVc.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXSwapSettingVc: EXSNavCustomVC {
    
    typealias EXSwapSettingVcCallBack = () -> ()
    var selectUnitBlock : EXSwapSettingVcCallBack?
    var changeUserConfigCallBlock :EXSwapSettingVcCallBack?
    var changePositionCallBlock :EXSwapSettingVcCallBack?
    var triggerChangeBlock : EXSwapSettingVcCallBack?
    var currentID:Int64 = 0
    var isPositionModeCanSwitch = true
    let cellReUseID = "SLSwapSettingCell_ID"
    var datalist = [EXSContractSetItem]()
    lazy var contentTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.ext_SetTableView(self, self)
        tableView.ext_RegistCell([EXSwapSettingTC.classForCoder()], [cellReUseID])
        return tableView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.contentTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        requestUserConfig()
        self.contentView.addSubview(self.contentTableView)
        self.initLayout()
        relaodView()
    }
    
    override func setNavCustomV() {
        self.setTitle("cp_contract_setting_text13".ex_localized())
        self.navtype = .listtitle
    }
    
    private func initLayout() {
        self.contentTableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.navCustomView.snp.bottom).offset(16)
        }
    }
    
    func relaodView(){
        datalist = EXSContractSetItem.getSetDatalist()
        self.contentTableView.reloadData()
    }
}
extension EXSwapSettingVc{
    func requestUserConfig(){
        networkApi.rx.request(.getUserConfig(id: currentID)).exs_MJObjectMap(SLUserConfig.self).subscribe(onSuccess: {[weak self] (config) in
            guard let mySelf = self else {
                return
            }
            mySelf.isPositionModeCanSwitch = config.isPositionModeCanSwitch()
            
        },onError: { (_) in
            
        }).disposed(by: self.exs_disposeBag)
    }
}
// MARK: - UITableViewDelegate & UITableViewDataSource

extension EXSwapSettingVc: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.datalist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReUseID, for: indexPath) as! EXSwapSettingTC
        cell.setItem = datalist[indexPath.row]
        cell.onValueChangeCallback = { [weak self] res in
            self?.switchV(res)
        }
        return cell

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item  = datalist[indexPath.row]
        if item.type == .time {
          return 69 //有副标题多10 English: 10 more subtitles
        }
        return 52
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let item = datalist[indexPath.row]
        if item.type == .confirmAgain {
            return
        }
        if item.type == .chart {
            let alert = EXCharSetAlert()
            alert.snp.makeConstraints { make in
                make.height.equalTo(350)
            }
            alert.clickBlock = { [weak self] in
                self?.relaodView()
            }
            EXAlert.showSheet(sheetView: alert)
            return
        }
        
        
        let sheet = EXActionSheetView()
        var arr : [String]?
        var idx = 0
        if item.type == .positonMode {
            if !isPositionModeCanSwitch {
                let alert = EXCommonAlert()
                alert.configAlert(title: "cp_contract_setting_text7".ex_localized(),bottomOnlyOneBtn: true)
                EXAlert.showAlert(alertView: alert)
                return
            }
            arr = ["cp_contract_setting_text15".ex_localized(),"cp_contract_setting_text16".ex_localized()]
            idx = EXStoreData.storeObject(forKey: EXS_HOLD_MODE) as? Int ?? 0
        } else if item.type == .unit {
            arr = ["cp_overview_text9".ex_localized(),"cp_extra_text82".ex_localized()]
            idx = EXStoreData.storeObject(forKey: EXS_UNIT_VOL) as? Int ?? 0
        } else if item.type == .time{
            //有效期 English: Validity period
            arr = introducedList()
            idx = EXStoreData.storeObject(forKey: EX_DATE_CYCLE) as? Int ?? 0
        }
        sheet.configButtonTitles(buttons: arr!,selectedIdx: idx)
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            mySelf.handleSelectedRow(item: item, idx: idx)
        }
        sheet.actionCancelCallback =  {() in
        }
        EXAlert.showSheet(sheetView: sheet)
    }
    func introducedList() -> [String] {
        let arr:[EXSwapPlanOrderValidityPeriod] = [.oneDay, .oneWeek, .twoWeek, .oneMonth]
        return arr.map{$0.introduced}
    }
    func handleSelectedRow(item: EXSContractSetItem, idx: Int) {
//        let cell = self.contentTableView.cellForRow(at: indexPath) as! EXSwapSettingTC
        if item.type == .positonMode {
            let positionModelStr = idx == 0 ? "1" : "2"
            EXContractNetwork.editUserConfig(id:currentID, positionModel: positionModelStr, coUnit:"") {[weak self] success in
                if !success {
                    return
                }
                EXStoreData.setStoreObjectAndKey(idx, key: EXS_HOLD_MODE)
                self?.relaodView()
                self?.changeUserConfigCallBlock?()
                self?.changePositionCallBlock?()
            }
            
        } else if item.type == .unit {
            
            EXContractNetwork.editUserConfig(id:currentID, positionModel: "", coUnit: idx == 0 ? "2": "1") {[weak self] success in
                
                if !success {
                    return
                }
                
                EXStoreData.setStoreObjectAndKey(idx, key: EXS_UNIT_VOL)
                self?.relaodView()
                self?.selectUnitBlock?()
            }
        }else if item.type == .time {
            let period = EXSwapPlanOrderValidityPeriod.init(rawValue: idx)
            EXContractNetwork.editUserConfig(id: currentID, positionModel: "", coUnit: "",expiredTime: period?.parm() ?? "") {[weak self] (success) in
                if !success {
                    return
                }
                EXStoreData.setStoreObjectAndKey(idx, key: EX_DATE_CYCLE)
                self?.relaodView()
                self?.changeUserConfigCallBlock?()
            }
        }
    }
    
    func switchV(_ b : Bool){
        if b == true{//开启手势 English: Activate gesture
            EXStoreData.setComfirmSwapAlertStatus(true)
        }else{
            EXStoreData.setComfirmSwapAlertStatus(false)
        }
      //  self.contentTableView.reloadData()
    }
}



