//
//  EXHomePageModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/6/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Foundation
import DeepDiff
import EXKit
import Swap
class NoticeInfoItem : EXBaseModel{//announcement
    var id = ""
    var title = ""
    var content = ""
    var ctime = ""
    var mtime = ""
    var stime = ""
    var lang = ""
    var httpUrl = ""
}

//0. webView 1. coinmap_ Market 2. Coinmap_ Trading Currency Pair Trading Page 3. Coinmap_ Details Coin Pair Details Page 4. otc_ Buy OTC - Purchase 5. OTC_ Sell Off the Counter - Sell 6. Order_ Record order record 7. account_ Transfer account transfer 8. otc_ Account assets - off exchange account 9. coin_ Account Asset Currency Account 10.safe_ Set Security Settings 11. safe_ Money Security Settings - Fund Password 12. personal_ Information Personal Data 13. personal_ Invitation Profile - Invitation Code 14. Collection_ Way payment method 15. real_ Name real name authentication

class CmsAppDataItem : EXBaseModel {//tool
    var id = ""
    var title = ""
    var subhead = ""
    var imageUrl = ""
    var httpUrl = ""
    var sort = ""
    var lang = ""//Language, I don't know what to use
    var nativeUrl = ""//Local URL
    var symbol = ""//?? I don't know what it's for
    var type = ""
    var isOutsideUrl = "0"//Is it an external URL
    var bannerDirection: Int = 0
    func fmtUrl() ->String {
        if httpUrl.count > 0,let origin = URL.init(string: httpUrl) {
            if let _ = origin.query {
                return httpUrl + "&exIsOutsideUrl=\(isOutsideUrl)"
            }else {
                return httpUrl + "?exIsOutsideUrl=\(isOutsideUrl)"
            }
        }
        return ""
    }
}
//Settled profit and loss
class EXHomeTicker:EXBaseModel {
    //Contract ID
    var contract_id:Int64 = 0
    var itemModel : EXSwapItemModel? {
        didSet {
            
            if let s = itemModel?.symbol {
                symbol = s
            }
        }
    }
    
    var symbol :String = ""
    var amount :String = ""
    var high:String = ""
    var vol:String = ""
    var low :String  = ""
    var rose :String = ""
    var close :String = ""
    var open :String = ""
    var name :String = ""
    var showName:String = ""
    var rmb:String = ""
    var app_serial_number:Int = -1
    var precision = 2
    var volprecision = 2
    var rose1 : Float = 0
    var backColor : UIColor?
    var color = UIColor.ThemeLabel.colorMedium
    var volume:String = ""//Volume returned by transaction volume
    var doubleClose : Double = 0
    
    var marketTag:String = ""
    var marketTagWidth:CGFloat = 0
    var coinName:String = ""
    //Old logic, move it over first, don't handle it
    func updateModelWithTicker(ticker:EXTickerModel) {

        self.amount = ticker.amount.decimalString(volprecision)
        self.high = ticker.high.decimalString(precision)
        self.low = ticker.low.decimalString(precision)
        self.open = ticker.open.decimalString(precision)

        if ticker.rose == ""{
            rose = "--"
        }else {
            if ticker.rose.contains("-"){
                rose = ticker.rose.replacingOccurrences(of: "-", with: "")
                rose = "-" + NSString.init(string: rose).multiplying(by: "100", decimals: 2,holdZeor: true)
                if let r = Int(rose) , r == 0{
                    rose = rose.replacingOccurrences(of: "-", with: "")
                }
            }else{
                rose = NSString.init(string: ticker.rose).multiplying(by: "100", decimals: 2,holdZeor: true)
            }
            if let rose1 = Float(self.rose){
                if rose1 == 0{
                    rose = "0.00" + "%"
                    backColor = UIColor.ThemeLabel.colorDark
                    color = .Ex.text2
                }else if rose1 < 0{
                    rose = rose + "%"
                    backColor = UIColor.ThemekLine.down
                    color = UIColor.ThemekLine.down
                }else{
                    rose = "+" + rose + "%"
                    backColor = UIColor.ThemekLine.up
                    color = UIColor.ThemekLine.up
                }
                self.rose1 = rose1
            }
        }
        
        if ticker.vol == ""{
            vol = "--"
            close = "--"
        }else {
            vol = NSString.init(string: ticker.vol).decimalString(volprecision)
            vol = NumberHandler.privateDealDataFormate(vol)
        }
        
        //You need to run the code above before calling it
        if contract_id != 0 {
            
            if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
                self.close = ticker.close.toPricePrecision(withContractID: contract_id)
                handleDataNewContractWay()
            }
        }else {
            
            self.close = ticker.close.decimalString1(precision)
            self.doubleClose = Double(close) ?? 0
            handleDataCommonWay()
        }
        
    }
    
    func handleDataCommonWay() {
        
        handleRmbDisplay(array: name.components(separatedBy: "/"))
    }
    
    func handleRmbDisplay(array:[String]) {
        
        if array.count > 1{
            if close == "" {
                rmb = "--"
                close = "--"
            }else {
                let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(array[1])
                if let rmb = NSString.init(string: close).multiplyingBy1(t.1, decimals: t.2,holdZero: true){
                    self.rmb = "\(t.0)" + rmb
                }
            }
        }
    }
    func handleDataNewContractWay() {
        if contract_id != 0 {
            
            handleRmbDisplay(array: name.components(separatedBy: "-"))
        }
    }
    func handleDataContractWay() {
        if contract_id != 0 {
            
            handleRmbDisplay(array: symbol.components(separatedBy: "/"))
        }
    }
    override func mj_keyValuesDidFinishConvertingToObject() {
        
        let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(symbol)
        
        if let i = Int(entity.price){//Default Precision
            precision = i
        }
        if let i = Int(entity.volume) {
            volprecision = i
        }
       
        self.doubleClose = Double(close) ?? 0
        
        if vol == ""{
            vol = "--"
        }else {
            vol = NSString.init(string: vol).decimalString(volprecision)
            vol = NumberHandler.privateDealDataFormate(vol)
        }
        
        if volume != ""{
            volume = (volume as NSString).decimalString1(volprecision)
            volume = NumberHandler.privateDealDataFormate(volume)
        }
        
        let array = entity.name.components(separatedBy: "/")
        if array.count > 1{
            if close == "" {
                rmb = "--"
                close = "--"
            }else {
                let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(array[1])
                if let rmb = NSString.init(string: close).multiplyingBy1(t.1, decimals: t.2,holdZero: true){
                    self.rmb = "≈\(t.0)" + rmb
                }
            }
            let symbol = EXAppMarketManager.sharedInstance.getMarketLeft(array[0])
            marketTag = EXAppMarketManager.sharedInstance.getCoinMarketTag(symbol)
        }

        if rose == ""{
            rose = "--"
        }else {
            if rose.contains("-"){
                rose = rose.replacingOccurrences(of: "-", with: "")
                rose = "-" + NSString.init(string: rose).multiplying(by: "100", decimals: 2)
                if let r = Int(rose) , r == 0{
                    rose = rose.replacingOccurrences(of: "-", with: "")
                }
            }else{
                rose = NSString.init(string: rose).multiplying(by: "100", decimals: 2)
            }
            if let rose1 = Float(self.rose){
                if rose1 == 0{
                    rose = "0.00" + "%"
                    backColor = UIColor.ThemeLabel.colorDark
                    color = UIColor.ThemeLabel.colorDark
                }else if rose1 < 0{
                    rose = rose + "%"
                    backColor = UIColor.ThemekLine.down
                    color = UIColor.ThemekLine.down
                }else{
                    rose = "+" + rose + "%"
                    backColor = UIColor.ThemekLine.up
                    color = UIColor.ThemekLine.up
                }
                self.rose1 = rose1
            }
        }
        //You need to run the code above before calling it
        if contract_id != 0 {
            if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
                self.close = close.toPricePrecision(withContractID: contract_id)
                handleDataNewContractWay()
            }
        }else {
            name = entity.name
            showName = entity.showName
            coinName = entity.coinName
            handleDataCommonWay()
        }
        self.close = self.close.decimalString1(precision)
    }
    
    //Old logic, move over here
    func dealRose(_ rose : String) -> String{
        var rose1 = rose
        if rose1.count > 6 , rose1.contains("."){
            rose1 = rose1.extStringSub(NSRange.init(location: 0, length: rose1.count - 1))
            if rose1.last == "."{
                rose1 = rose1.extStringSub(NSRange.init(location: 0, length: rose1.count - 1))
            }
            return dealRose(rose1)
        }
        return rose1
    }
}
extension EXHomeTicker:DiffAware{}

class EXRecommendList:EXBaseModel {
    var key :String = ""
    var title :String = ""
    var list :[EXHomeTicker] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
//        if list.count > 10 {
//            let temp = ([NSDictionary])list
//            let models = temp.prefix(9).map { $0 }
//            self.list = EXHomeTicker.mj_objectArray(withKeyValuesArray: models).copy() as! [EXHomeTicker]
//        }else {
//            self.list = EXHomeTicker.mj_objectArray(withKeyValuesArray: self.list).copy() as! [EXHomeTicker]
//        }
        self.list = EXHomeTicker.mj_objectArray(withKeyValuesArray: self.list).copy() as! [EXHomeTicker]
        if self.list.count > 10 {
            var temp = [EXHomeTicker]()
            for i in 0..<10 {
                temp.append(self.list[i])
            }
            self.list = temp
        }
        
        for (idx,entity) in list.enumerated() {
            entity.app_serial_number = idx + 1
        }
    }
}

class EXHomeIndexModel:EXBaseModel {
    //To do caching, use EXHomeIndexViewModel to convert to VC calls
    var cmsAppAdvertList: [Any] = []//H5 and app rotation chart
    var noticeInfoList : [Any] = []//Announcement List
    var cmsAppDataList : [Any] = []//Toolbar, homepage display position
    var cmsAppDataListOther : [Any] = []//Affiliated String: String]=[]
    var home_recommend_list:[Any] = []
    var header_symbol: [Any] = []
    var co_header_symbols = EXContractHomeTickerModel()
    var co_home_symbol_list:[Any] = []
    var contract_home_symbol_list:[Any] = []
    var cmsAppDataStyle:String = ""//1 row/2 2 rows
    var cmsAppDataOtherStyle:String = ""//One, two, two
    
    func copyable() -> EXHomeIndexModel {
        let indexModel = EXHomeIndexModel()
        indexModel.cmsAppAdvertList = cmsAppAdvertList
        indexModel.noticeInfoList = noticeInfoList
        indexModel.cmsAppDataList = cmsAppDataList
        indexModel.cmsAppDataListOther = cmsAppDataListOther
        indexModel.home_recommend_list = []
        indexModel.cmsAppDataStyle = cmsAppDataStyle
        indexModel.cmsAppDataOtherStyle = cmsAppDataOtherStyle
        if let headerSymbols = header_symbol as? [[String:Any]] {
            let items  = headerSymbols.map { (symbol) -> [String:Any] in
                var newsymbol = symbol
                newsymbol["close"] = ""
                newsymbol["rose"] = ""
                return newsymbol
            }
            indexModel.header_symbol = items
        }else {
            indexModel.header_symbol = []
        }
        return indexModel
    }
}

enum HomeKingKongType: String {
    case singleRow = "1"
    case doubleRow = "2"
}

enum HomeSubBannerType: String {
    case singleColoum = "1"
    case doubleColoum = "2"
}

class EXHomeIndexViewModel: NSObject {
    var cmsAppAdvertList: [CmsAppDataItem] = []//H5 and app rotation chart
    var noticeInfoList : [NoticeInfoItem] = []//Announcement List
    var cmsAppDataList : [CmsAppDataItem] = []//Toolbar, homepage display position
    var cmsAppDataListOther : [CmsAppDataItem] = []//Affiliated banner
    var header_symbol: [EXHomeTicker] = []
    var home_recommend_list:[EXRecommendList] = []
    var kingkongType:HomeKingKongType = .singleRow
    var subBannerType:HomeSubBannerType = .singleColoum
    
    func viewModelWith(_ model:EXHomeIndexModel) {
        if model.cmsAppDataStyle == "1" {
            self.kingkongType = .singleRow
        }else if model.cmsAppDataStyle == "2" {
            self.kingkongType = .doubleRow
        }
        
        if model.cmsAppDataOtherStyle == "1" {
            self.subBannerType = .singleColoum
        }else if model.cmsAppDataOtherStyle == "2" {
            self.subBannerType = .doubleColoum
        }
        self.noticeInfoList = NoticeInfoItem.mj_objectArray(withKeyValuesArray: model.noticeInfoList).copy() as! [NoticeInfoItem]
        self.cmsAppAdvertList = CmsAppDataItem.mj_objectArray(withKeyValuesArray: model.cmsAppAdvertList).copy() as! [CmsAppDataItem]
        self.cmsAppDataList = CmsAppDataItem.mj_objectArray(withKeyValuesArray: model.cmsAppDataList).copy() as! [CmsAppDataItem]
        self.cmsAppDataListOther = CmsAppDataItem.mj_objectArray(withKeyValuesArray: model.cmsAppDataListOther).copy() as! [CmsAppDataItem]
        self.cmsAppDataListOther = self.cmsAppDataListOther.sorted(by: { a , b  in
            return a.bannerDirection < b.bannerDirection
        })
        if EXAppConfigManager.sharedInstance.getContractVersion() == .new,
           EXHomeViewModel.isContractStatus() {
            let contracts = EXHomeContractModel.mj_objectArray(withKeyValuesArray: model.contract_home_symbol_list) as! [EXHomeContractModel]
            
            var areaDic = [BTContract_Block_Type:[EXHomeContractModel]]()

            for item in contracts {
                if var arr = areaDic[item.area] {
                    arr.append(item)
                    areaDic[item.area] = arr

                }else {
                    var arr = [EXHomeContractModel]()
                    arr.append(item)
                    areaDic[item.area] = arr
                }
            }
            var recommendList = [EXRecommendList]()
            for area in EXSwapPublicInfo.shared.getSortAreaArray() {
          
                let recommend = EXRecommendList()
                if let value = areaDic[area] {
                    
                    recommend.title = EXContractArea.generateBy(blockType: area).introduce
                    recommend.list = value.map({ (coModel) -> EXHomeTicker in
                        let ticker = EXHomeTicker()
                        ticker.symbol = coModel.wsSymbol()
                        ticker.name = coModel.symbol
                        ticker.showName = coModel.showName()
                        
                        ticker.contract_id = coModel.instrument_id
                        return ticker
                    })
                    recommendList.append(recommend)
                }
            }
           
            self.home_recommend_list = recommendList
      
            return
        }

        if EXHomeViewModel.isContractStatus() {
            
            self.header_symbol = (EXContractHomeTickerModel.mj_object(withKeyValues: model.co_header_symbols)).list
            
            self.home_recommend_list = EXContractRecommendList.mj_objectArray(withKeyValuesArray: model.co_home_symbol_list).copy() as! [EXContractRecommendList]
            self.home_recommend_list = self.home_recommend_list.filter({ (item) -> Bool in
                return item.list.count > 0
            })
            return
        }

        self.header_symbol = EXHomeTicker.mj_objectArray(withKeyValuesArray: model.header_symbol).copy() as! [EXHomeTicker]
        self.home_recommend_list = EXRecommendList.mj_objectArray(withKeyValuesArray: model.home_recommend_list).copy() as! [EXRecommendList]
    }
}

