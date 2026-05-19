//
//  EXCoinAddressListVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXCoinAddressListVc: BaseVC,StoryBoardLoadable,NavigationPlugin,EXEmptyDataSetable {
    var coinModel: EXAccountCoinMapItem = EXAccountCoinMapItem()
    @IBOutlet var addressTable: UITableView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var addNewAddressButton: EXButton!
    var addressDatasource:[AddressItem] = []
    var coinSymbol:String = ""//Subchain Name
    var mainChainName = ""//Main chain name
    
    var selectAddressItem:AddressItem?
    
    typealias AddressItemCallback = (AddressItem)->()
    var onAddressItemCallback:AddressItemCallback?
    
    
    typealias AddressDeleteCallback = (AddressItem)->()
    var onAddressDeleteCallback:AddressDeleteCallback?
    
    let smsService:EXSmsService = EXSmsService()

    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.addressTable, presenter: self)
        nav.isLastNavigationStyle = true
        return nav
    }()
    
    func handleNavigation() {
        
        let coin = coinModel.coinName.aliasName()
        self.navigation.setTitle(title: coin + " " + "common_text_address".localized())
//        navigation.configRightItems(["address_action_addnew".localized()],isImageName: false)
//        navigation.rightItemCallback = {[weak self] tag in
//            self?.addnewAddress()
//        }
    }
    
    func addnewAddress() {
        let addnew = EXCoinAddNewAddressVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        addnew.coinSymbol = self.coinSymbol
        addnew.mainChainName = mainChainName
        addnew.coinModel = self.coinModel
        addnew.onAddressSuccessed = {[weak self] in
            self?.handleNewAddress()
        }
        self.navigationController?.pushViewController(addnew, animated: true)
    }
    
    func handleNewAddress() {
        requestAddressList()
    }
    
    func handleTableView() {
        self.addressTable.register(UINib.init(nibName: "EXAddressListCell", bundle: nil), forCellReuseIdentifier: "EXAddressListCell")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewAddressButton.setTitle("add_address".localized(), for: .normal)
        handleTableView()
        handleNavigation()
        requestAddressList()
        self.exEmptyDataSet(self.addressTable, attributeBlock: { () -> ([EXEmptyDataSetAttributeKeyType : Any]) in
            return [
                .verticalOffset:0,
            ]
        })
    }
    
    func requestAddressList() {
        if coinSymbol.isEmpty {
            return
        }
        appApi.rx.request(.addressList(coinSymbol: coinSymbol))
        .MJObjectMap(EXAddressListModel.self)
        .subscribe{[weak self] event in
            switch event {
            case .success(let model):
                self?.handleAddressList(model.addressList)
                break
            case .failure(_):
                break
            }
        }.disposed(by: self.disposeBag)
    }
    
    func handleAddressList(_ addressList:[AddressItem]) {
        self.addressDatasource = addressList
        addressTable.reloadData()
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
    
    func isTagSupportCoin() -> Bool {
        let hasTag = EXAppMarketManager.sharedInstance.coinNeedTag(coinSymbol)
        return hasTag
    }
    
    @IBAction func onAddNewAddressAction(_ sender: Any) {
        addnewAddress()
    }
}

extension EXCoinAddressListVc : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isTagSupportCoin() {
            return 99
        }else {
            return 77
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addressItem = addressDatasource[indexPath.row]
        onAddressItemCallback?(addressItem)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "address_action_delete".localized()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let addressItem = addressDatasource[indexPath.row]
            
            let alert = EXCommonAlert()
            let img = UIImage.svg_themeImageNamed(imageName: "public_prompt")
                        alert.configAlert(tipImage: true,
                              title: "common_text_tip".localized(),
                              message:"common_text_confirmDelete".localized()
                              ,cancelBtnTitle: "common_text_btnCancel".localized(),
                              sureBtnTitle: "common_text_btnConfirm".localized()) { type in
                EXAlert.dismiss()
                if type == .sure{
                    self.safeCheck(addressItem.id, indexPath.row)
                }
            }
            EXAlert.showAlert(alertView: alert)
        }
    }
    
    func safeCheck(_ key:String, _ index:Int){
        let manger = EXComSafeVaildManger()
        manger.safeCheck = .addressDelete
        manger.startSafeAlert()
        manger.resultCallBack = { result in
            self.verifiedSafety(result,key,index)
        }
    }
    
    func verifiedSafety(_ reuslt: EXCodeResult,_ key:String, _ index:Int) {
        appApi.rx.request(.deleteWithDrawAddr(ids: key,
                                              googleCode: reuslt.googleCode,
                                              smsCode: reuslt.phoneCode,
                                              emailAuthCode: reuslt.emailCode))
            .MJObjectMap(EXVoidModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(_):
                    self?.updateRowDatas(index)
                    EXAlert.showSuccess(msg: "address_tip_deleteSuccess".localized())
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    func updateRowDatas(_ index: Int) {
        if addressDatasource.count > index {
            let addressItem = addressDatasource[index]
            self.onAddressDeleteCallback?(addressItem)
            addressDatasource.remove(at: index)
            addressTable.reloadData()
        }
    }
    
}

extension EXCoinAddressListVc : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressDatasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addressItem = addressDatasource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXAddressListCell") as! EXAddressListCell
        cell.updateCellItem(addressItem)
        if let selectItem = selectAddressItem,selectItem.address == addressItem.address {
            cell.showAddressCheckMark(true)
        }else {
            cell.showAddressCheckMark(false)
        }
        return cell
    }
}

