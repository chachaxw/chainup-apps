//
//  EXDrawContainerVC.swift
//  Chainup
//
//  Created by cwd on 2022/11/2.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
/*Contract Sidebar Market View*/
import JXSegmentedView
import RxSwift

enum MarketEventType{
    case selectFinsh(item: EXSwapItemModel)
    case updateTicker(ticker: EXCOTickerModel, symbol: String)
    case searchKey(keyWord: String)
}

class EXDrawViewModel{
    var listContainIsScrolling = false
    let exs_disposeBag = DisposeBag()
    var eventSubject = PublishSubject<MarketEventType>()
    //Subscription cancellation
    func subCancel() {
        EXSwapSocketManager.shared.subscribeTickers(datas: nil,cancel: true)
    }
    func subcriber(){
        EXSwapSocketManager.shared.subscribeTickers()
        EXSwapSocketManager.shared.onwsEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
                if event == .ticker {
                    mySelf.webSocketUpdateContractTicker(ticker: datas.tick, symbol: datas.channel)
                }
            }).disposed(by: self.exs_disposeBag)
    }
    //MARK: - websocket Ticker refresh
    @objc func webSocketUpdateContractTicker(ticker:EXCOTickerModel,symbol:String) {
        if listContainIsScrolling {
            return
        }
        eventSubject.onNext(.updateTicker(ticker: ticker, symbol: symbol))
    }
    
}
class EXDrawContainerVC: EXCOBaseContainerVc {
    static let topMargin: CGFloat = EX_NAV_STATUS_HEIGHT  + 16
    var vm = EXDrawViewModel()
    let useLike = EXContractUserVm()
    var fromKline = false {
        didSet{
            colorModue = fromKline ? .kLine : .global
        }
    }
    var colorModue: UIColor.Ex  = .global
    var dataSouce:[EXSwapDrawerViewData] = []
    var vcs:[EXDrawLsitVC] = []
    var isSearching = false
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.subcriber()
        self.linesegmentedDataSource.titleSelectedColor = colorModue.text1
        self.linesegmentedDataSource.titleNormalColor = colorModue.text2
        self.linesegmentedDataSource.titleNormalFont = UIFont.ThemeFont.BodyRegular
        self.linesegmentedDataSource.titleSelectedFont = UIFont.ThemeFont.BodyRegular
        self.segmentIndicatorType = .line
        configSubView()
        let hasOpened = EXStoreData.storeBool(forKey: contract_market_opened)
        if hasOpened { //User has opened it
            let userSelectTab = EXStoreData.storeInt(forKey: contract_market_selectId)
            //print("userSelectTab =\(userSelectTab)")
            //Need to record the previous selection based on user selection
            self.segmentedView.defaultSelectedIndex = userSelectTab
            self.listContainerView.defaultSelectedIndex = userSelectTab
        }else{ //First time
            useLike.getFavoriteList { [weak self] userList in
                if let user = userList,user.count > 0 {
                    self?.segmentedView.defaultSelectedIndex = 0
                    self?.listContainerView.defaultSelectedIndex = 0
                    return
                }
                //If there is no currency pair selected, 1 is selected by default
                self?.segmentedView.defaultSelectedIndex = 1
                self?.listContainerView.defaultSelectedIndex = 1
            }
            EXStoreData.setStoreObjectAndKey(true, key: contract_market_opened)
        }
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        vm.subcriber()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.subCancel()
       
    }
    deinit{
//        //print("ecstatic")
//        vm.subCancel()
    }
    
    //MARK: lazy
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    lazy var typeLabel:UILabel = {
        let label = UILabel()
        label.textColor = colorModue.text1
//        fromKline ? UIColor.ThemekLine.labcolorLite : UIColor.ThemeLabel.colorLite
        label.font = UIFont.Ex.Harmony(size: 20, weight: .medium)
        label.text = "cp_overview_text35".ex_localized()
        return label
    }()
    
    //Search bar
    lazy var searchBar: EXCOSearchBar = {
        let v = EXCOSearchBar()
        v.enableSearch = true
        v.textField.setPlaceHolder(placeHolder: "assets_action_search".ex_localized())
        v.backgroundColor = colorModue.fill6//UIColor.ThemeView.alertBg
        v.bgColor = colorModue.fill3//UIColor.ThemeView.card2 Card 2
        v.showCancelBtn = false
        v.textField.textfieldDidBeginBlock = { [weak self] in
            guard let self = self else { return }
            EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_search_click.rawValue)
        }
        v.textField.textfieldValueChangeBlock = {[weak self]str in
            print(str)
            self?.isSearching = str.count > 0
            self?.vm.eventSubject.onNext(.searchKey(keyWord: str))
        }
        return v
    }()
    
    
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = colorModue.fill4// UIColor.ThemeView.seperator
        return v
    }()

}
extension EXDrawContainerVC{
    override func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        
        EXLogger.debug(scene: .init(rawValue: "swap.segmentedView"), message: "scrollingFrom, listContainIsScrolling =\(self.vm.listContainIsScrolling)")
        self.vm.listContainIsScrolling = true
    }
    override func segmentedView(_ segmentedView: JXSegmentedView, didScrollSelectedItemAt index: Int) {
        
        self.vm.listContainIsScrolling = false
        EXLogger.debug(scene: .init(rawValue: "swap.segmentedView"), message: "didScrollSelectedItemAt, listContainIsScrolling =\(self.vm.listContainIsScrolling)")
    }
}
extension EXDrawContainerVC{
    func configSubView(){
        self.view.backgroundColor = colorModue.fill6//UIColor.ThemeView.alertBg
        for (idx,_) in names.enumerated() {
            let listVc = EXDrawLsitVC()
            listVc.orinDatas = self.dataSouce[idx].searData
            listVc.rowDatas = self.dataSouce[idx].searData
            vcs.append(listVc)
            listVc.vm = self.vm
            if idx == 0 {
                listVc.isUserLike = true
            }
            listVc.colorModle = self.colorModue
        }
        
        self.view.addSubview(typeLabel)
        self.view.addSubview(searchBar)
        
        self.segmentedView.addSubview(self.line)
        self.view.addSubview(self.listContainerView)
        self.segmentedView.backgroundColor =  colorModue.fill6// UIColor.ThemeView.alertBg
        typeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(EXDrawContainerVC.topMargin)
            make.height.equalTo(23)
        }
        searchBar.textField.input.textColor = colorModue.text1
        searchBar.snp.makeConstraints { make in
            make.left.equalToSuperview() //.offset(16)
            make.right.equalToSuperview()//.offset(-16)
            make.height.equalTo(32)
            make.top.equalTo(typeLabel.snp.bottom).offset(16)
        }
        
        self.segmentedView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(4)
            make.height.equalTo(44)
            make.left.equalToSuperview() //.offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        self.line.snp.makeConstraints { make in
            make.bottom.equalTo(self.segmentedView.snp.bottom)
            make.height.equalTo(0.5)
            make.width.equalTo(self.segmentedView)
        }
        let y =  EXDrawContainerVC.topMargin + 23 + 16 + 48 + 44// (self.segmentedView.frame.maxY)
        segmentedView.listContainer = self.listContainerView
        //MARK: Rounding the width - otherwise scrolling to select can cause problems
        let w = Int(exs_dr_Width)
        self.listContainerView.frame = CGRect(x: 0, y:y, width: CGFloat(w), height:self.view.frame.height - y)
    }
    
}
extension EXDrawContainerVC{
    override func configTitles() -> [String]{
        return setOringinData()
    }
    override func indexDidChanged() {
        if currentIdx == 0 {
           //Refreshing the self selection list
            let v = vcs[0]
            v.getUserLike()
           
        }
        EXStoreData.setStoreObjectAndKey(currentIdx, key: contract_market_selectId)
    }
}

extension EXDrawContainerVC: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return vcs[index]
    }
}

extension EXDrawContainerVC{
    func setOringinData() -> [String] {
        var titles:[String] = []
        
        let list =  [EXSwapItemModel]()
        let userlike = EXSwapDrawerViewData(name: "cp_contract_customZone".ex_localized(), searData: list, originData: list)
        
        let usdtData = EXSwapDrawerViewData(name: "cp_contract_data_text13".ex_localized(), searData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_USDT) ?? [], originData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_USDT) ?? [])
        
        let coinData = EXSwapDrawerViewData(name: "cp_contract_data_text10".ex_localized(), searData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_STAND) ?? [], originData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_STAND) ?? [])
        //
        let  mixtureData = EXSwapDrawerViewData(name: "cp_contract_data_text12".ex_localized(), searData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_INVERSE) ?? [], originData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_INVERSE) ?? [])
        
        let simulation = EXSwapDrawerViewData(name: "cp_contract_data_text11".ex_localized(), searData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_SIMULATION) ?? [], originData: EXSwapPublicInfo.shared.getTickersWithArea(.CONTRACT_BLOCK_SIMULATION) ?? [])
        
        titles.append(userlike.name)
        dataSouce.append(userlike)
        if usdtData.isShow() {
            titles.append(usdtData.name)
            dataSouce.append(usdtData)
        }
        
        if coinData.isShow() {
            titles.append(coinData.name)
            dataSouce.append(coinData)
        }
        if mixtureData.isShow() {
            titles.append(mixtureData.name)
            dataSouce.append(mixtureData)
        }
        
        if simulation.isShow() {
            titles.append(simulation.name)
            dataSouce.append(simulation)
        }
        return titles
    }
    
}


extension EXDrawContainerVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}

