//
//  EXContractAssetListVC.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/7.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXPagingView
import EXKit
public typealias SwapToolbarAction = () -> ()
public class EXSwapAssetListVC: EXSBaseVC, EXEmptyDataSetable{
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    var isRequesting = false
    private let reuseID = "SLSwapAssetListCell_ID"
    var hasOpenContract: Bool? = nil
    public var actionBlock:SwapToolbarAction?
    public var openContactBlock:SwapToolbarAction?
    public var openContractAlertCallBack:EXComVoidBlock?
    public var accountBlaceCallBlock:SwapToolbarAction? //获取合约账户余额 English: Obtain contract account balance
    public var assetModel:EXContractBlance = EXContractBlance(){
        didSet{
            self.toolbarHeader.assetsInfoView.bindAssetModel(self.assetModel)
            if self.swapAssetTable.mj_header != nil{
                self.swapAssetTable.mj_header.endRefreshing()
            }
        }
    }
    var assetArr : [EXContractAssetModel] = []
    let toolbarHeader:SLSwapTableHeader = SLSwapTableHeader(frame: CGRect(x: 0, y: 0, width: EXSCREEN_WIDTH, height: 153))
   
    var needUpdatedPrivacy:Bool = false

    
    var checkOpenContract:Bool {
        var hasOpend = false
        if let hasOpenContract = hasOpenContract,hasOpenContract == true{
            hasOpend = true
        }
        return hasOpend
    }
   
     //MARK: lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubViews([toolbarHeader,swapAssetTable])
        self.configpieChartButton()
        swapAssetTable.extSetTableView(self, self)
        handleToolbar()
        exEmptyDataSet(swapAssetTable, attributeBlock: { [.verticalOffset:(CGFloat(30))] })
        swapAssetTable.extRegistCell([EXContractAssetInfoCell.classForCoder()],[reuseID])
        swapAssetTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        swapAssetTable.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let `self` = self else { return }
            self.requestBalalance()
            self.fetchContractInfo()
        })

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshLogout),
                                               name: NSNotification.Name(rawValue: "Logout_notification_name"),
                                               object: nil)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func queryAll(){
        EXSwapPlatformSDK.shared.getFiatCoinSymbolBack?()
        //Update bottom asset list
        fetchContractInfo()
        requestBalalance()
    }
    func fetchContractInfo(){
        let hasOpend = self.checkOpenContract
        if hasOpend == false {
            handleAlertOpenSwap {
                self.queryAssets()
            }
        }else{
            self.queryAssets()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    //MARK: lazy
    lazy var swapAssetTable: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.rowHeight = 146
        tableView.extSetTableView(self, self)
        return tableView
    }()

    
    func handleJumpToSwapVc() {
        self.openContactBlock?()
    }


    func updateBalance() {
        self.accountBlaceCallBlock?()
    }
    func requestBalalance() {
        updateBalance()
    }

    func handleToolbar() {
        view.addSubview(toolbarHeader)
        toolbarHeader.toolBar.bindToolBarItems(EXContractAssetToolBarItem.getSwapToolbars())
        toolbarHeader.toolBar.onToolBarSelected = {[weak self] (item) in
            self?.handleToolbarAction(item)
        }
        self.swapAssetTable.tableHeaderView = toolbarHeader
    }

    func handleToolbarAction(_ item:EXContractAssetToolBarItem) {
        if isRequesting {
            return
        }
        if hasOpenContract == nil {
            isRequesting = true
            /*
             未获取过用户的开通合约信息
             I have not obtained the user's activation contract information
             */
            handleAlertOpenSwap { [weak self] in
                guard let `self` = self else { return }
                self.gotoAction(item)
            }
        }else{
            gotoAction(item)
        }
    }
    
    func gotoAction(_ item:EXContractAssetToolBarItem){
        if checkOpenContract == false {
            openContractAlert()
            return
        }
        let itemAction = item.action
        if itemAction == .co_journalAccount {
            let assetsRecordVC = EXSAssetsRecordVC()
            assetsRecordVC.isBouns = true
            self.navigationController?.pushViewController(assetsRecordVC, animated: true)
        } else if itemAction == .co_swapGift {
            EXSwapPlatformSDK.shared.goToH5?(EXSwapPrivateConfig.shared.coCouponSwitchUrl,item.title,self,nil)
        } else if itemAction == .co_ProfitRecord{
            let urlString = EXSwapPrivateConfig.shared.profitUrl
            EXSwapPlatformSDK.shared.goToH5?(urlString,"   ",self,.coProfitRecord)
        }else{
            self.actionBlock?()//Transfer
        }
    }
}
extension EXSwapAssetListVC{
    public func updatePrivacy() {
        toolbarHeader.assetsInfoView.bindAssetModel(self.assetModel)
        self.swapAssetTable.reloadData()
    }
    
    @objc private func refreshLogout() {
        self.hasOpenContract = nil
        self.updateBalance()
        self.assetArr = []
        self.swapAssetTable.reloadData()
    }

    func configpieChartButton(){
        toolbarHeader.assetsInfoView.pieChartButton.setImage(UIImage.svg_themeImageNamed(imageName: "assets_profit"), for: .normal)
        toolbarHeader.assetsInfoView.pieChartButton.isHidden = false
        toolbarHeader.assetsInfoView.pieChartButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = `self` else { return }
            self.gotoNext()
        }).disposed(by: self.disposeBag)
    }

    
    func handleAlertOpenSwap(completion:@escaping () -> ()) {

        let instrumentID = EXSwapPublicInfo.shared.getAllSwapInfo()?.first?.instrument_id ?? 0

        networkApi.rx.request(.getUserConfig(id: instrumentID)).exs_MJObjectMap(SLUserConfig.self).subscribe(onSuccess: { [weak self] (config) in
            self?.isRequesting = false
            self?.hasOpenContract = config.hasOpenContract()
            if !config.hasOpenContract() {
                self?.refreshLogout()
                self?.openContractAlertCallBack?()
                return
            }else {
                completion()
            }
          
        },onError: { [weak self] (_) in
            self?.isRequesting = false
        }).disposed(by: self.exs_disposeBag)

    }

   public func justQueryAsset(){
        let instrumentID = EXSwapPublicInfo.shared.getAllSwapInfo()?.first?.instrument_id ?? 0
        networkApi.rx.request(.getUserConfig(id: instrumentID)).exs_MJObjectMap(SLUserConfig.self).subscribe(onSuccess: { [weak self] (config) in
            if !config.hasOpenContract() {
                self?.refreshLogout()
            }else {
                self?.queryAssets()
            }
        },onError: { (_) in

        }).disposed(by: self.exs_disposeBag)
        
    }
    
    func gotoNext(){
        let action = EXContractAssetToolBarItem()
        action.action = .co_ProfitRecord
        gotoAction(action)
    }
    
    public func openContractAlert(){
        let alert = EXSwapAssetAlertView.createAlert(contentStr: "contract_text_openSwap_operation".ex_localized(), btnTitle: "contract_text_btn_swapopen".ex_localized(), frame: CGRect.init(x: 0, y: 0, width: 311, height: 298))
        alert.alertCallback = {[weak self] idx in
            guard let mySelf = self else {return}
            if idx == 1 {
                mySelf.handleJumpToSwapVc()
            }
        }
        alert.show()
    }
    

}

//MARK: request
extension EXSwapAssetListVC{
    func queryAssets() {
        EXContractNetwork.getUserPositionOrAsset(onlyAccount: true, marginCoin: "") {[weak self] (model) in
            guard let mySelf = self else {return}
            mySelf.assetArr = model.accountList
            mySelf.swapAssetTable.reloadData()
        } failure: { (error) in
        }.disposed(by: self.exs_disposeBag)
    }

}
extension EXSwapAssetListVC: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}

extension EXSwapAssetListVC : UITableViewDelegate , UITableViewDataSource {
    
    public  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    public  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.ThemeNav.bg
        header.frame = CGRect(x: 0, y: 0, width: EXSCREEN_WIDTH, height: 10)
        return header
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetArr.count
    }

    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as! EXContractAssetInfoCell
        let itemModel = assetArr[indexPath.row]
        cell.assetModel = itemModel
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc = EXContractAssetsDetailVC()
        self.navigationController?.pushViewController(vc, animated: true)
        vc.property = assetArr[indexPath.row]
    }
}

extension EXSwapAssetListVC: JXPagingViewListViewDelegate {
    public  func listView() -> UIView {
        return self.view
    }

    public  func listScrollView() -> UIScrollView {
        return swapAssetTable
    }

    public func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        listViewDidScrollCallback = callback
    }
    public func listDidAppear() {
        EXLogger.debug(message: "listDidAppear")
        queryAll()
    }
}


public class EXContractBlance: EXCOBaseModel {
    public var title = ""
    public var btcAccount = ""
    public var rmbAccount = ""
    
}

