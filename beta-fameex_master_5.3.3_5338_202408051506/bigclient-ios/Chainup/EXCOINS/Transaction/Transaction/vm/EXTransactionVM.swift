//
//  EXTransactionVM.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EXTransactionVM: NSObject {
    var wsDepthChannel:String = ""
    var ws24HourChannel:String = ""
    fileprivate let wsDepthKey = "manager.wsDepthKey"
    fileprivate let ws24HourPriceKey = "manager.ws24HourPriceKey"
    
    let closePriceSubject : PublishSubject<PriceTick> = PublishSubject.init()
    let buysSubject : PublishSubject<([String],[String],String)> = PublishSubject.init()
    let sellsSubject : PublishSubject<([String],[String],String)> = PublishSubject.init()
    
    var lstep = "0"//depth
    var priceDecimal :Int = 8
    var coinSymbol:String = "" {
        didSet {
            wsDepthChannel = "market_\(coinSymbol.lowercased())_depth_step\(lstep)"
            ws24HourChannel = "market_\(coinSymbol.lowercased())_ticker"
        }
    }
    
    
    //If Done 
    lazy var contractWsManager : XWebSocketManager = {
        let ws = XWebSocketManager()
        ws.key = wsDepthKey
        ws.webSocketDelegate = self
        return ws
    }()
    
    //Transaction price
    lazy var contractPriceManager : XWebSocketManager = {
        let ws = XWebSocketManager()
        ws.key = ws24HourPriceKey
        ws.webSocketDelegate = self
        
        return ws
    }()
}

extension EXTransactionVM :DSWebSocketDelegate {
    
//    func wsRequestData(){
//        contractWsManager.connectSever(NetDefine.wss_host_contract)//Fifth gear
//        contractPriceManager.connectSever(NetDefine.wss_host_contract)//Transaction price
//    }
//
//    func disconnectws(){
//        contractWsManager.disconnect()
//        contractPriceManager.disconnect()
//    }
//
//    func websocketDidConnect(socket: XWebSocketManager) {
//        if socket.key == wsDepthKey {//Fifth gear
//            wsBuySellFiveData()
//        }else if socket.key == ws24HourPriceKey {//Transaction price
//            requestClinchDealData()
//        }
//    }
//
//    //Request five levels of data
//    func wsBuySellFiveData(){
//        let cb_id = ""
//        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : "sub" , "params" : ["channel" : wsDepthChannel , "cb_id" : cb_id , "asks" : "150" , "bids" : "150"]])
//        contractWsManager.sendBrandStr(string: jsonStr)
//    }
//
//    //Request transaction
//    func requestClinchDealData(){
//        let cb_id = ""
//        let jsonStr = JSONSerialization.jsonDataFromDictToString(["event" : "sub" , "params" : ["channel" : ws24HourChannel , "cb_id" : cb_id]])
//        contractPriceManager.sendBrandStr(string: jsonStr)
//    }
//
//    func websocketDidReceiveData(socket: XWebSocketManager, data: Data) {
//        let uncompress = NSData.uncompressZippedData(data)
//        if uncompress == nil{
//            return
//        }
//        do{
//            let json = try JSONSerialization.jsonObject(with: uncompress!, options: JSONSerialization.ReadingOptions.allowFragments)
//            if let dict = json as? [String : Any]{
//                if dict.keys.contains("ping"){
//                    let jsonData = try JSONSerialization.data(withJSONObject: ["pong" : dict["ping"]], options: JSONSerialization.WritingOptions.prettyPrinted)
//                    let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8)
//                    socket.sendBrandStr(string: jsonStr!)
//                }else{
////                    if socket.key == wsDepthKey {//Request five levels of data
////                        dealBuySellFiveData(dict)
////                    }else if socket.key == ws24HourPriceKey {//Transaction price
////                        handleClinchDealData(dict)
////                    }
//                }
//            }
//        }catch _ {
//
//        }
//    }
//
//    //Processing transactions
//    func handleClinchDealData(_ dict : [String : Any]){
//        if let channel = dict["channel"] as? String , channel == ws24HourChannel{
//            if let tick = dict["tick"] as? [String : Any]{
//                if let close = tick["close"]{
////                    guard let p = Int(entity.price) else{return}
////                    guard let c = NSString.init(string: String(describing: close)).decimalString(p) else{return}
////                    transactionToolView.priceLabel.text = c + " " + entity.marketName.aliasName()
////                    transactionToolView.price = c
////                    if let rmb = NSString.init(string: c).multiplyingBy1( parities.1, decimals: parities.2){
////                        transactionToolView.aboutLabel.text = "≈\(parities.0)" + rmb
////                    }
////                    //                    self.setPriceLabel("\(close)")
////                }
////                if let rose = tick["rose"]{
////                    let i = LanguageTools.handleDouble(rose)
////                    if i < 0{
////                        transactionToolView.priceLabel.textColor = UIColor.ThemekLine.down
////                    }else{
////                        transactionToolView.priceLabel.textColor = UIColor.ThemekLine.up
////                    }
////                }
//            }
//        }
//    }
//
//    //Process five levels of data
//    func dealBuySellFiveData(_ dict : [String : Any]){
//        //        NSLog("1231231231             \(dict)")
//        if let tick = dict["tick"] as? [String : Any]{
//
//            var asks : [[Any]] = []
//            var buys : [[Any]] = []
//            var max = 0.00000000001
//            //Processing sales
//            if let asks1 = tick["asks"] as? [[Any]]{
//                var asksArray : [Double] = []
//                for item in asks1{
//                    if item.count > 1{
//                        if let t = item[1] as? Double{
//                            asksArray.append(t)
//                        }
//                    }
//                }
//                asks = asks1
//
//                if let asksSum = asksArray.max(){
//                    max = asksSum > max ? asksSum : max
//                }
//            }
//            //Processing Buying
//            if let buys1 = tick["buys"] as? [[Any]]{
//                var buysArray : [Double] = []
//                for item in buys1{
//                    if item.count > 1{
//                        if let t = item[1] as? Double{
//                            buysArray.append(t)
//                        }
//                    }
//                }
//                buys = buys1
//                if let buysSum = buysArray.max(){
//                    max = buysSum > max ? buysSum : max
//                }
//            }
//
//            //Need to optimize in high frequency of refreshing pages
////            tableHeadViewV.transactionDepthVV.reloadRowDatas()
//
//            if asks.count >= 5{
//                for i in 0..<5{
//                    if asks[i].count > 1{
////                        tableHeadViewH.transactionDepthHV.tableViewRowDatas2[i].setEntity(asks[i][0], xnum: asks[i][1],color: UIColor.ThemekLine.down, depthSum: max,entityDepth : entity.depthArray[Int(lstep)])
//                    }
//                }
//            }else{
//                for i in 0..<asks.count{
//                    if asks[i].count > 1{
////                        tableHeadViewH.transactionDepthHV.tableViewRowDatas2[i].setEntity(asks[i][0], xnum: asks[i][1],color: UIColor.ThemekLine.down, depthSum: max,entityDepth : entity.depthArray[Int(lstep)])
//                    }
//                }
//            }
//
//            if asks.count >= 10{
//                for i in 0..<10{
//                    if asks[i].count > 1{
////                        tableHeadViewV.transactionDepthVV.sellTableViewRowDatas[10-i].setEntity(asks[i][0], xnum: asks[i][1],color: UIColor.ThemekLine.down, depthSum: max,entityDepth : entity.depthArray[Int(lstep)])
//                    }
//                }
//            }else{
//                for i in 0..<asks.count{
//                    if asks[i].count > 1{
////                        tableHeadViewV.transactionDepthVV.sellTableViewRowDatas[10-i].setEntity(asks[i][0], xnum: asks[i][1],color: UIColor.ThemekLine.down, depthSum: max,entityDepth : entity.depthArray[Int(lstep)])
//                    }
//                }
//            }
//
//            if buys.count >= 5{
//                for i in 0..<5{
//                    if buys[i].count > 1{
////                        tableHeadViewH.transactionDepthHV.tableViewRowDatas1[i].setEntity(buys[i][0], xnum: buys[i][1],color: UIColor.ThemekLine.down, depthSum: max,entityDepth : entity.depthArray[Int(lstep)])
//
//                    }
//                }
//            }else{
//                for i in 0..<buys.count{
//                    if buys[i].count > 1{
////                        tableHeadViewH.transactionDepthHV.tableViewRowDatas1[i].setEntity(buys[i][0], xnum: buys[i][1],color: UIColor.ThemekLine.down, depthSum: max,entityDepth : entity.depthArray[Int(lstep)])
//                    }
//                }
//            }
//            if buys.count >= 10{
//                for i in 0..<10{
//                    if buys[i].count > 1{
////                        tableHeadViewV.transactionDepthVV.buyTableViewRowDatas[i].setEntity(buys[i][0], xnum: buys[i][1],color:UIColor.ThemekLine.up, depthSum: max,entityDepth : entity.depthArray[Int(lstep)])
//                    }
//                }
//            }else{
//                for i in 0..<buys.count{
//                    if buys[i].count > 1{
////                        tableHeadViewV.transactionDepthVV.buyTableViewRowDatas[i].setEntity(buys[i][0], xnum: buys[i][1],color:UIColor.ThemekLine.up, depthSum: max,entityDepth : entity.depthArray[Int(lstep)])
//                    }
//                }
//            }
////            tableHeadViewV.transactionDepthVV.setTableViewRowDatas()
////            tableHeadViewH.transactionDepthHV.reloadDatas()
//        }
//    }
//
//    func getFmtedPrice(price:String) ->String{
//        let nsPrice = price.decimalNumberWithDouble() as NSString
//        return nsPrice.decimalString1(priceDecimal)
//    }
}

