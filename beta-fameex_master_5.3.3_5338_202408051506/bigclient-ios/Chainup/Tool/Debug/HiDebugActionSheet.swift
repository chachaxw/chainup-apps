////
////  HiDebugActionSheet.swift
////  Chainup
////
////  Created by liuxuan on 2023/3/8.
////  Copyright © 2023 zewu wang. All rights reserved.
////
//
//import UIKit
//
//class HiDebugActionSheet: UIViewController {
//    @IBOutlet var actionSheet: EXActionSheetView!
//    var test: UIView = UIView()
//    var filterData = [String:String]()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        test.backgroundColor = UIColor.red
//    }
//    
//    @IBAction func actionSheet(_ sender: Any) {
//        let sheet = EXActionSheetView()
//        sheet.configButtonTitles (buttons: ["Button A", "Button B", "Button C", "Button D"])
//        sheet.actionIdxCallback = {[weak self] tag in
//            self?.testSecurity()
//        }
//        EXAlert.showSheet(sheetView:sheet)
//    }
//    
//    func testSecurity() {
//
//    }
//    
//    @IBAction func textfieldSheet(_ sender: Any) {
////        let sheet = EXActionSheetView()
////        sheet.itemBtnCallback = {[weak self] key in
////            EXAlert.showFail(msg: "123")
////        }
////Sheet. configTextfields (title: "Fund Password", itemModels: self. models())
////        sheet.actionFormCallback = {[weak self] formDic in
////            print(formDic)
////        }
////        self.view.addSubview(sheet)
////
////        sheet.snp.makeConstraints { (make) in
////            make.bottom.equalToSuperview()
////            make.left.right.equalToSuperview()
////        }
//        
//        let sheet = EXContractPositionSheet()
//        sheet.bindInfos(contractPositionNumber: "123", assignedPosition: "345", avaliablePosition:"34566", symbol: "sdfj")
//        sheet.onPositionCallback = {[weak self](str , bool) in
//            if bool == true{//Increase margin
////                self?.transferMargin(entity.contractId, amount: "+" + str)
//            }else{//Reduce margin
////                self?.transferMargin(entity.contractId, amount: "-" + str)
//            }
//        }
////        EXAlert.showSheet(sheetView: sheet)
//        
//        EXAlert.showSheet(sheetView:sheet)
//    }
//    
//    @IBAction func dropMenuAction(_ sender: Any) {
//        let dropView = EXFilterView()
//        dropView.delegate = self
//        dropView.show(inView: self.view, position: CGPoint(x: 0, y: 64))
//        dropView.filterParams = self.filterData
//        dropView.reloadData()
//    }
//    
//    func models()->[EXOldInputSheetModel] {
//        let model = EXOldInputSheetModel.setModel(key:"key1",placeHolder: "", type: .input, privacyMode: true,keyBoard:.numberPad)
//        let model4 = EXOldInputSheetModel.setModel(key:"key1",placeHolder: "输入资金密码", type: .paste, privacyMode: true,keyBoard:.numberPad)
//
//        let model3 = EXOldInputSheetModel.setModel(key:"key3",placeHolder: "输入资金密码", type: .sms, privacyMode: true,keyBoard:.decimalPad)
//
//        let model2 = EXOldInputSheetModel.setModel(withTitle:"790215001@qq.com",key:"key2",placeHolder: "邮箱验证码", type: .sms)
//        return[model,model3,model2,model4]
//    }
//    
//    @IBAction func failDrop(_ sender: Any) {
//        EXAlert.showFail(msg: "Failure Message")
//
//    }
//    
//    @IBAction func successDrop(_ sender: Any) {
//        EXAlert.showSuccess (msg: "Success Message")
//
//    }
//    
//    @IBAction func warningDrop(_ sender: Any) {
//        let alert = EXStartAdAlert()
//        alert.adImageView.image = UIImage.themeImageNamed(imageName: "background_english")
//        alert.bindHref(ahref: "https://www.baidu.com")
//        EXAlert.showAlert(alertView: alert)
//        
//    }
//    
//    @IBAction func normal(_ sender: Any) {
//       
//    }
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
//
//extension HiDebugActionSheet : EXFilterViewDelegate {
//    
//    func filterConfirm(params: [String : String]) {
//        self.filterData = params
//    }
//    
//    func filterDataSource() -> [EXFilterDataModel] {
//        let items = EXFilterItem.getItem(titles: ["common_action_sendall".localized(),"otc_action_buy".localized(),"otc_action_sell".localized()], valueKeys: ["1","2","3"])
//        //fold
//        let foldModel
//            = EXFilterDataModel.getFoldModel(key: "tradeType", title: "common_type".localized(), contents: items)
//        
//        let coinitems = EXFilterItem.getItem(titles: ["人民币","美元","日元","欧元"], valueKeys: ["cny","usd","jpy","euo"])
//        //一半输入,一半折叠
//        let mixModel = EXFilterDataModel.getMixModel(title: "交易单位", leftKey: "symbol", rightKey: "unit", leftplaceHolder: "filter_input_coinsymbol".localized(), rightItems: coinitems)
//
//        //折叠
//        let item2 = EXFilterItem.getItem(titles: ["全部","已完成","待付款","待放行","已取消","申诉中"], valueKeys: ["1","2","3","4","5","6"])
//        let foldModel2
//            = EXFilterDataModel.getFoldModel(key: "moneyType", title: "common_type".localized(), contents:item2)
//        
//        //date
//        let dateModel = EXFilterDataModel.getDateModel(beginDateKey: "begin", endDateKey: "end", title: "date")
//        
//        //switch
//Let onOffModel=EXFilterDataModel. getSwitchModel (key: "onoff", title: "Hide Small Assets")
//        
//        //Simple input box
//Let inputModel=EXFilterDataModel. getInputModel (key: "writesomthing", title: "What to input", placeHolder: "Please input", unit: "cny")
//        
//        //Simple selection
//Let selectModel=EXFilterDataModel. getSelectionModel (key: "search", title: "currency pair", placeHolder: "BTC/USDT")
//
//        return [foldModel,mixModel,foldModel2,dateModel,onOffModel,inputModel,selectModel]
//    }
//    
//    func didSelectAtIdxPath(idx: IndexPath) {
//        
////        let vc = HiDebugHubController .instanceFromStoryboard(name: "HiDebug")
////        self.navigationController?.pushViewController(vc, animated: true)
//
//    }
//    
//}
//
