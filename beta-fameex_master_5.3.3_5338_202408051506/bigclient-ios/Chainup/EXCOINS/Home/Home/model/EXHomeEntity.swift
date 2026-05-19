//
//  EXHomeEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class HomeEntity: SuperEntity {
    
    var cmsAppAdvertList : [CmsAppAdvertEntity] = []//H5 and app rotation chart
    
    var cmsAppDataListOther : [CmsAppAdvertEntity] = [] //Deputy banner
    
    var noticeInfoList : [NoticeInfoEntity] = []//Announcement List
    
    var risingListIsOpen = ""//Rise chart switch, 1: On, 0: Off
    
    var fallingListIsOpen = ""//Drop chart switch, 1: On, 0: Off
    
    var dealListIsOpen = ""//Transaction list switch, 1: On, 0: Off
    
    var switchArray : [String] = []
    
    var homeFunctionEntityList : [HomeFunctionEntity] = []//Home display space
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        
        if let array = dict["cmsAppAdvertList"] as? [[String : Any]]{
            var arr : [CmsAppAdvertEntity] = []
            for dic in array{
                let entity = CmsAppAdvertEntity()
                entity.setEntityWithDict(dic)
                arr.append(entity)
                arr.sort { (entity1, entity2) -> Bool in
                    if let str = NSString.init(string: entity1.sort).subtracting(entity2.sort, decimals: 0) , str.contains("-"){
                        return true
                    }
                    return false
                }
            }
            cmsAppAdvertList = arr
        }
        
        if let array = dict["cmsAppDataListOther"] as? [[String : Any]]{
            var arr : [CmsAppAdvertEntity] = []
            for dic in array{
                let entity = CmsAppAdvertEntity()
                entity.setEntityWithDict(dic)
                arr.append(entity)
                arr.sort { (entity1, entity2) -> Bool in
                    if let str = NSString.init(string: entity1.sort).subtracting(entity2.sort, decimals: 0) , str.contains("-"){
                        return true
                    }
                    return false
                }
            }
            cmsAppDataListOther = arr
        }
        
        if let array = dict["noticeInfoList"] as? [[String : Any]]{
            var arr : [NoticeInfoEntity] = []
            for dic in array{
                let entity = NoticeInfoEntity()
                entity.setEntityWithDict(dic)
                arr.append(entity)
            }
            noticeInfoList = arr
        }
        
        if let array = dict["cmsAppDataList"] as? [[String : Any]]{
            var arr : [HomeFunctionEntity] = []
            for dic in array{
                let entity = HomeFunctionEntity()
                entity.setEntityWithDict(dic)
                arr.append(entity)
            }
            homeFunctionEntityList = arr
        }
        
        switchArray.removeAll()
        
        risingListIsOpen = dictContains("risingListIsOpen")
        if risingListIsOpen == "1"{
            switchArray.append("rasing")
        }
        
        fallingListIsOpen = dictContains("fallingListIsOpen")
        if fallingListIsOpen == "1"{
            switchArray.append("falling")
        }
        
        dealListIsOpen = dictContains("dealListIsOpen")
        if dealListIsOpen == "1"{
            switchArray.append("deal")
        }
        
    }
    
}

class NoticeInfoEntity : SuperEntity{//announcement
    
    var id = ""
    
    var title = ""
    
    var content = ""
    
    var ctime = ""
    
    var mtime = ""
    
    var stime = ""
    
    var lang = ""
    
    var httpUrl = ""
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        id = dictContains("id")
        title = dictContains("title")
        content = dictContains("content")
        ctime = dictContains("ctime")
        mtime = dictContains("mtime")
        stime = dictContains("stime")
        lang = dictContains("lang")
        httpUrl = dictContains("httpUrl")
    }
    
}

class CmsAppAdvertEntity : SuperEntity {//Rotation chart
    
    var id = ""
    
    var title = ""
    
    var imageUrl = ""
    
    var httpUrl = ""
    
    var sort = ""
    
    var lang = ""
    
    var nativeUrl = ""//Local URL
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        
        id = dictContains("id")
        
        title = dictContains("title")
        
        imageUrl = dictContains("imageUrl")
        
        httpUrl = dictContains("httpUrl")
        
        sort = dictContains("sort")
        
        lang = dictContains("lang")
        
        nativeUrl = dictContains("nativeUrl")
    }
    
}


class HomeRecommendedEntity : SuperEntity{//Home page recommendation
    
//    var amplitudeColor = UIColor.ThemeLabel.colorMedium
    var backColor = UIColor.ThemekLine.up
    var color = UIColor.ThemeLabel.colorMedium
    var rose = "--"
    var symbol:String = "" //Add app from data
    var name = ""
    var close = "--"
    var rmb = ""
    var precision = 2
//    var volprecision = 2
    var rose1 : Float = 0
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        if let rose = Float(rose){
            if rose == 0{
                backColor = UIColor.ThemeLabel.colorMedium
//                amplitudeColor = UIColor.ThemeView.bg
            }else if rose < 0{
                backColor = UIColor.ThemekLine.down.withAlphaComponent(0.2)
//                amplitudeColor =  UIColor.ThemekLine.down
            }else{
                backColor = UIColor.ThemekLine.up.withAlphaComponent(0.2)
//                amplitudeColor = UIColor.ThemekLine.up
            }
        }
    }
    
    //Process rose
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

class HomeListEntity : CoinDetailsEntity{//Various charts on the homepage
    
    var price = "--"
    
    var coinName = "USDT"//Currency name
    
    var dealVolume = "--"//Turnover
    
    var volume = "--"
    
    var nameAttrWidth:CGFloat = 0
    
    var symbolWidth:CGFloat = 0
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        self.dict = dict
        symbol = dictContains("symbol")
        let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(symbol)
        name = entity.name
        if let i = Int(entity.price){//Default Precision
            precision = i
        }
        super.setEntityWithDict(dict)
        if let rose = Float(rose){
            if rose == 0{
                backColor = UIColor.ThemeLabel.colorMedium
                color = UIColor.ThemeLabel.colorMedium
            }
        }
        
        volume = dictContains("volume")
        if volume != ""{
            volume = (volume as NSString).decimalString1(2)
            volume = NumberHandler.privateDealDataFormate(volume)
            name = symbol
        }
        
        if coinName != ""{
            price = EXAppMarketManager.sharedInstance.getCoinExchangeRate(coinName).1
            dealVolume = NumberHandler.privateDealDataFormate(dealVolume)
            if dealVolume == ""{
                dealVolume = "--"
            }
        }
        
        rose = dictContains("rose")
        
        if rose.contains("-"){
            rose = rose.replacingOccurrences(of: "-", with: "")
            rose = NSString.init(string: rose).multiplying(by: "100", decimals: 2)
            rose = self.dealRose(rose)
            rose = "-" + rose
            if let r = Int(rose) , r == 0{
                rose = rose.replacingOccurrences(of: "-", with: "")
            }
        }else{
            rose = NSString.init(string: rose).multiplying(by: "100", decimals: 2)
            rose = self.dealRose(rose)
        }
        
        if let rose1 = Float(self.rose){
            if rose1 == 0{
                rose = "0.00" + "%"
                backColor = UIColor.ThemeLabel.colorMedium
                color = UIColor.ThemeLabel.colorMedium
            }else if rose1 < 0{
                rose =  rose + "%"
                backColor = UIColor.ThemekLine.down
                color = UIColor.ThemekLine.down
            }else{
                rose = "+" + rose + "%"
                backColor = UIColor.ThemekLine.up
                color = UIColor.ThemekLine.up
            }
            self.rose1 = rose1
        }
        if dictContains("rose") == ""{
            rose = "--"
        }
        nameAttrWidth = nameAttr().boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14), options: .usesLineFragmentOrigin, context: nil).width + 36
        symbolWidth = symbol.aliasName().textSizeWithFont(UIFont.ThemeFont.HeadBold, width: .greatestFiniteMagnitude).width + 36
    }
    
    //Process rose
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

class HomeAssetsEntity : EXBaseModel {
    var name = ""
    
    var assetSymbol = ""
    
    var assetsCount = ""
    {
        didSet{
            //If the empty string returned in the background is also changed to 0
            if assetsCount == ""{
                assetsCount = "0"
            }
            let decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(assetSymbol)
            let btc = NSString.init(string: assetsCount).decimalString(decimal)
            assetsCount = btc ?? "0"
            self.assetsAtt = assetsAtt.add(string: assetsCount, attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite , NSAttributedString.Key.font : UIFont.init().themeHNMediumFont(size: 16)]).add(string: " " + assetSymbol, attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium , NSAttributedString.Key.font : UIFont.init().themeHNMediumFont(size: 12)])
            
            let rate = EXAppMarketManager.sharedInstance.getCoinExchangeRate(assetSymbol)
            self.rmb = "≈" + rate.0 + NSString.init(string: assetsCount).multiplying(by: rate.1, decimals: rate.2,holdZeor: true)
        }
    }
    
    var assetsAtt = NSMutableAttributedString.init()
    
    var rmb = ""
    
    var bool = false
}

class HomeGOTO : NSObject{
    
    var coinMap = ""
    
    weak var vc : UIViewController?
    
    //0. webView 1. coinmap_ Market 2. Coinmap_ Trading Currency Pair Trading Page 3. Coinmap_ Details Coin Pair Details Page 4. otc_ Buy OTC - Purchase 5. OTC_ Sell Off the Counter - Sell 6. Order_ Record order record 7. account_ Transfer account transfer 8. otc_ Account assets - off exchange account 9. coin_ Account Asset Currency Account 10.safe_ Set Security Settings 11. safe_ Money Security Settings - Fund Password 12. personal_ Information Personal Data 13. personal_ Invitation Profile - Invitation Code 14. Collection_ Way payment method 15. real_ Name real name authentication
    
    func gotoVC(_ vc : UIViewController? = nil , tnativeUrl : String , httpUrl : String, title:String  = ""){
        var nativeUrl = tnativeUrl
        if vc == nil{
            return
        }
        self.vc = vc
        
        if nativeUrl == ""{
            //I'm not sure why I added it here. WebVC also has to unify it as urlQueryAllowed
            //Supplementary, in order to prevent escape from losing parameters at the routing layer
            let charSet = CharacterSet.alphanumerics
            if let encodingURL = httpUrl.addingPercentEncoding(withAllowedCharacters: charSet) {
                EXNavigationHandler.sharedHandler.commonJumpCommand("web", encodingURL,title)
            }
        }else{
            let arr = nativeUrl.components(separatedBy: "?")
            if arr.count > 1{
                nativeUrl = arr[0]
                coinMap = arr[1]
            }else if arr.count > 0{
                nativeUrl = arr[0]
            }
            EXNavigationHandler.sharedHandler.commonJumpCommand(nativeUrl,coinMap)
        }
    }
}

class EXHomeAssetModel: EXBaseModel {
    
    var assetSymbol = "BTC"
    
    var futuresTotalBalance = ""
    var totalBalanceSymbol = ""
    var totalBalance = ""
    {
        didSet{
            //If the empty string returned in the background is also changed to 0
            if totalBalance == ""{
                totalBalance = "0"
            }
            let btc = totalBalance.formatAmount(assetSymbol)
            if btc.isEmpty {
                totalBalance = "0"
            }else {
                totalBalance = btc
            }
            let rate = EXAppMarketManager.sharedInstance.getCoinExchangeRate(assetSymbol)
            self.rmb = "≈" + rate.0 + NSString.init(string: totalBalance).multiplying(by: rate.1, decimals: rate.2)
            createAssetsAtt()
        }
    }
    
    var assetsAtt = NSMutableAttributedString.init()
    var rmb = ""

    func createAssetsAtt() {
       self.assetsAtt = assetsAtt.add(string: totalBalance, attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite , NSAttributedString.Key.font : UIFont.init().themeHNMediumFont(size: 16)]).add(string: " " + assetSymbol, attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium , NSAttributedString.Key.font : UIFont.init().themeHNMediumFont(size: 12)])
    }
    
    func updateTotalBalanceWithCoBalance(cobalance:String) {
        
        let decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(assetSymbol)
        let btc = NSString.init(string: totalBalance).adding(cobalance, decimals: decimal)
        self.assetsAtt = NSMutableAttributedString.init()
        self.totalBalance = btc ?? "0"
    }
    
    func makeAssetsAttr() -> NSMutableAttributedString {
        let attr = NSMutableAttributedString.init()
        attr.add(string: totalBalance, attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.white , NSAttributedString.Key.font : UIFont.init().themeHNMediumFont(size: 28)]).add(string: " " + rmb, attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.white.withAlphaComponent(0.6) , NSAttributedString.Key.font : UIFont.init().themeHNMediumFont(size: 12)])
        return attr
    }
}

