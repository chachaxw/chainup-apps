//
//  EXFlutterKLine.swift
//  Chainup
//
//  Created by 尤彬 on 2023/5/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import Flutter
import FlutterPluginRegistrant
import EXKit
import SnapKit
import EXFlutterKLineKit


class EXContractFlutterKLine: EXView{
    
    var viewModel: EXContractFlutterKLineChartViewModel?
    
    var invokeChannel: FlutterMethodChannel?
    
    var callbackChannel: FlutterMethodChannel?
    
    var flutterController: FlutterViewController?
    
    var isBottom: Bool = false
    
    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXContractFlutterKLineChartViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        var waterLogoPath: String? = nil
        if EXThemeManager.current == .dayKlinenight || EXThemeManager.current == .night {
            waterLogoPath = EXSwapPlatformSDK.shared.app_img_night
        } else {
            waterLogoPath = EXSwapPlatformSDK.shared.app_img
        }
        var para: [String:Any] = [
//            "exToken" : UserInfoEntity.sharedInstance().token,
//            "domain"  : EXAppConfigManager.sharedInstance.companyDomain(),
            "lan"     : LanguageHandler.phoneLanguage,
            "riseFallTrend": EXTheme.KLineTrend.current == .reversed ? 1 : 0,
            "theme"   : EXThemeManager.isNight() ? "dark" : "light",
            "main1": UIColor.Ex.main1.rgbString ?? "",
            "main2": UIColor.Ex.main2.rgbString ?? "",
            "main3": UIColor.Ex.main3.rgbString ?? "",
            "main4": UIColor.Ex.main4.rgbString ?? "",
            "text4": UIColor.Ex.text4.rgbString ?? "",
            "needSubWs" : false,
            "isContractKline": true,
            "waterPath":waterLogoPath,
        ]
#if DEBUG
        para["isDebug"] = "1"
#endif
        let str  = toJsonString(with: para)
        if str  == nil{return}
        let flutterEngine = FlutterEngine(name: "smallKline flutter engine")
        flutterEngine.run(withEntrypoint: nil, initialRoute: "kline?\(str!)")
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        let _flutterController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        addSubview(_flutterController.view)
        _flutterController.view.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.callbackChannel   = EXFlutterKineChannel.createCallbackChannel(messenger: _flutterController.binaryMessenger)
        self.invokeChannel     = EXFlutterKineChannel.createInvokeChannel(messenger: _flutterController.binaryMessenger)
        self.flutterController = _flutterController
    }
    
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.flutterController?.setFlutterViewDidRenderCallback { [weak self] in
            guard let self = self else { return }
            self.dealWithFlutterDidRender()
        }
        
        self.callbackChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            self.dealWithKLine(with: call, with: result)
        }
        
        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            self.dealWithKLine(with: event)
        }).disposed(by: self.disposeBag)
        
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window != nil {
            guard let controller        = self.yy_viewController else { return  }
            guard let flutterController = self.flutterController else { return  }
            controller.addChild(flutterController)
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


// MARK:dict -> JsonString
extension EXContractFlutterKLine {
    internal func toJsonString(with dict: [String: Any]) -> String?{
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        if let _data = data {
            return String(data: _data, encoding: .utf8)
        }
        return nil
    }
}

// MARK: flutter did render
extension EXContractFlutterKLine {
    func dealWithFlutterDidRender() {
        self.backgroundColor = isBottom ? .Ex.fill2 : .clear
        let klineColor       = isBottom ? String(format: "#%@", UIColor.Ex.fill2.rgbString ?? "00000000") : "#00000000"
        if let _jsonString   = toJsonString(with: ["KlineBgColor": klineColor]) {
            self.invokeChannel?.invokeMethod("setKlineBgColor", arguments: _jsonString)
        }
        if let _jsonString = toJsonString(with: ["VolStateIndex": 1]) {
            self.invokeChannel?.invokeMethod("setKlineVolState", arguments: _jsonString)
        }
        if let _jsonString = toJsonString(with: ["SubStateIndex": 4]) {
            self.invokeChannel?.invokeMethod("setKlineSecondaryState", arguments: _jsonString)
        }

        guard let _entity = self.viewModel?.currentItemModel else { return }
        self.viewModel?.resetEntity(_entity)
    }
}

// MARK: flutter - 原生 English: MARK: Flutter - Native
extension EXContractFlutterKLine {
    func dealWithKLine(with call: FlutterMethodCall, with result: FlutterResult) {
        guard let method = EXKlineCallbackMethod(rawValue: call.method) else { return }
        let arguments    = call.arguments
        switch method {
        case .kline_switch_time_index:
            guard let _arguments   = arguments as? [String : Any] else { return }
            guard let _mklineScale = _arguments["mklineScale"] as? String else { return }
//            self.scaleKey = _mklineScale.uppercased() == "line".uppercased() ? "Line" : _mklineScale
//            let scaleKey = self.menuModel.scaleKey
//            handleScale(key: scaleKey)
            self.viewModel?.wsService.lastId = nil
        case .more_history_kline:
            guard let _arguments = arguments as? [String: Any],
                  let _endIdx    = _arguments["endIdx"] else { return }
            self.viewModel?.loadMoreHistoryKLine.onNext(_endIdx)
//        case .kline_scroll:
//            break
        case .reload_kline:
            self.viewModel?.reloadKLineSubject.onNext(true)
        default:
            break
        }
    }
}

// MARK: deal with K-line events
extension EXContractFlutterKLine {
    func dealWithKLine(with event: EXContractSmallFlutterKLineEvent) {
        let isLine = self.viewModel?.isLine ?? false
        let mSymbolPricePrecision = Int(self.viewModel?.currentItemModel?.ex_contractInfo?.coinResultVo.symbolPricePrecision ?? "2") ?? 2
        switch event {
        case .KLineChangedEntity:
            self.setCoinInfoToFlutter()
            break
        case .KLineData(let item):
            if self.viewModel?.isExpand == false {
                return
            }
            let dict: [String: Any] = ["mSymbolPricePrecision": mSymbolPricePrecision, "isLine": isLine, "mKlineData": item]
            guard let jsonString    = self.toJsonString(with: dict) else { return }
            self.invokeChannel?.invokeMethod("setNewKlineData", arguments: jsonString)
            
        case .KLineHistory(let item, let isMore):
            if self.viewModel?.isExpand == false {
                return
            }
            let dict: [String: Any] = ["mSymbolPricePrecision": mSymbolPricePrecision,"isLine": isLine,"isMore": isMore,"mKlineData": item]
            guard let jsonString    = self.toJsonString(with: dict) else { return }
            self.invokeChannel?.invokeMethod("setHistoryKlineData", arguments: jsonString)
        case .KLineHistoryFinish(_): break
        case .timeKeyChange(let timekey):
            let dict: [String: Any] = ["scale": timekey]
            guard let jsonString    = self.toJsonString(with: dict) else { return }
            self.invokeChannel?.invokeMethod("nativeClickKTimeChange", arguments: jsonString)
            //同步到大K线 English: Synchronize to the large K-line
            EXFlutterEngine.shared.invokeMethod(method: .nativeClickKTimeChange, arguments: jsonString)
            break
        //小k线同步大k线指标 English: Small K-line synchronization with large K-line indicators
        case .updateMainIndexVisible:
            let map = EXFlutterKlineCache.shared.klineUsePreference
            guard let data = map.toJsonString() else{
                return
            }
            self.invokeChannel?.invokeMethod(EXInvokeFlutterMethod.updateMainIndexVisible.rawValue, arguments: data)
            setCoinInfoToFlutter() //更新 English: update
        default:
            break
        }
    }
    
    
    func syncKline(timekey: String){
        let dict: [String: Any] = ["scale": timekey]
        guard let jsonString    = self.toJsonString(with: dict) else { return }
        self.invokeChannel?.invokeMethod("nativeClickKTimeChange", arguments: jsonString)
        //同步大K线 English: Synchronous K-line
        EXFlutterEngine.shared.invokeMethod(method: .nativeClickKTimeChange, arguments: jsonString)
    }
    
    private func setCoinInfoToFlutter() {
         //0符号 1汇率 2位数 English: 0 symbol 1 exchange rate 2 digits
        let isCoin = EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
        let facevalue = self.viewModel?.currentItemModel?.ex_contractInfo?.face_value
        let marginCoinPrecision = Int(self.viewModel?.currentItemModel?.ex_contractInfo?.coinResultVo.marginCoinPrecision ?? "2") ?? 2
        let coinDict: [String: Any] = [
                                       "isCoin":isCoin,
                                       "mMultiplier": facevalue ?? "1",
                                       "marginCoinPrecision":marginCoinPrecision
        ]

        if let jsonString = coinDict.toJsonString() {
            self.invokeChannel?.invokeMethod("setCoinInfo", arguments: jsonString)
        }
    }
}


