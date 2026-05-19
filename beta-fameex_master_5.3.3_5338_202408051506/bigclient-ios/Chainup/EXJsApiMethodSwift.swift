

import Foundation
import EXKit

typealias JSCallback = (String, Bool)->Void
class JSModel : EXBaseModel{
    var routerName = ""
    var symbol = ""
    var code = ""
    var result = ""
}

class JSKolShareDialogModel: EXBaseModel {
    var profit_rate = ""
    var win_rate_week = ""
    var win_rate = ""
    var user_name = ""
}

//{\"routerName\":\"share_dialog\",\"instrument_id\":11,\"side\":2,\"kol_name\":\"183******054\",\"avg_cost_px\":33186,\"rate\":31.22,\"symbol\":\"BTC-USDT\"}"

class JSShareDialogModel: EXBaseModel {
    var instrument_id = ""
    var side = ""
    var kol_name = ""
    var avg_cost_px = ""
    var rate = ""
    var symbol = ""
}

class EXJsApiMethodSwift: NSObject {
    
    //Arg is the parameter JSON string handler callback passed from h5
    @objc func exchangeInfo( _ arg:String, handler: JSCallback) {
        let dic = [
           "exchange_token":XUserDefault.tokenValue ?? "",
           "exchange_lan":LanguageHandler.priviatePhoneLanguage,
           "exchange_skin":EXThemeManager.isNight() ? "night" : "day"]
        handler(JSONSerialization.jsonDataFromDictToString(dic),true)
    }
    
    
    @objc func exchangeRouter(_ routerName : String , handler : JSCallback){
        
        
        print("routerName = \(routerName)")
       
        if let model = JSModel.mj_object(withKeyValues: routerName){
            print("model.code = \(model.code) + \(model.result)")
            
            
            if model.routerName == "kolShare_dialog" || model.routerName == "share_dialog" {
                self.handleNative(model, routerName)
            }
            else {
                self.handleNative(model)
            }
        }
    }
    
    func handleNative(_ model:JSModel, _ parameter:String = "") {
        
        if model.routerName == "login" {
//            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
//            }
        }else {
            if model.routerName == "singpasscancel" {
                //Singpass not authorized
                EXAppUIDefines.firstVCDismiss()
                EXAlert.showWarning(msg: "common_text_cancelkyc".localized())
            }else if model.routerName ==  "kyccomplete" {
                //KYC Complete Certification
                EXAppUIDefines.firstVCDismiss()
                if let topVc = EXAppUIDefines.getFirstVC(){
                    let userInfo = EXRealNameThreeVC()
                    EXAlert.showVc(controller: userInfo,ratio: 0.9)
//                    topVc.navigationController?.pushViewController(userInfo, animated: true)
                }
            }else if model.routerName ==  "native_close" {
                self.cyl_tabBarController.popBack(true, true)
            }else if model.routerName ==  "choosekycfirst" {
                //KYC Select Template 1 (App Local Template)
                EXAppUIDefines.firstVCDismiss()
                if let topVc = EXAppUIDefines.getFirstVC(){
                    let userInfo = EXRealNameOneVC()
                    userInfo.mainView.regionEntity = RegionManager.sharedInstance.regionEntity
                    topVc.navigationController?.pushViewController(userInfo, animated: true)
                }
            }else if model.routerName == "kolShare_dialog" {
                if let model = JSKolShareDialogModel.mj_object(withKeyValues: parameter) {
                    let alert = EXContractDocumentaryShareView.init(model: model)
                    if let window = UIApplication.shared.delegate?.window {
                        window?.addSubview(alert)
                        alert.snp.makeConstraints { (maker) in
                            maker.edges.equalToSuperview()
                        }
                    }
                    alert.endCaptureImage = { image, idx in
                        if idx == 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveImg(image:didFinishSavingWithError:contextInfo:)), nil)
                            }
                        }
                        else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                ShareHandler.share(AppService.topViewController(), image: image, completionHandler: {
                                })
                            }
                        }
                    }
                }
            }
            else if model.routerName == "share_dialog" {
                if let model = JSShareDialogModel.mj_object(withKeyValues: parameter) {
                    let alert = EXShareSheet.createShareViewWithShareDialog(model)
                    alert.alertCallback = { [weak self] (idx, image) in
                        if idx == 2 {
                            let activity = UIActivity()
                            var activityItems : [Any] = []
                            if image == nil {
                                return
                            }
                            activityItems.append(image!)
                            let activities = [activity]
                            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
                            activityController.excludedActivityTypes = [.copyToPasteboard,.assignToContact]
                            activityController.modalPresentationStyle = .fullScreen
                            let vc = AppService.topViewController()
                            vc?.present(activityController, animated: true) { () -> Void in
                            }
                            activityController.completionWithItemsHandler = {activityType, completed, returnedItems, activityError in
                                if activityError == nil , completed == true{
                                }else{
                                }
                            }
                        } else if idx == 1 {
                            if image != nil {
                                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self?.saveImg(image:didFinishSavingWithError:contextInfo:)), nil)
                            }
                        }
                    }
                    alert.show()
                }
            }
            else {
                var router = ""
                if model.routerName == "idAuth" {
                    router = EXRouterActionKey.AuthRealName.rawValue
                }else if model.routerName == "modifySettings" {
                    router = EXRouterActionKey.SafeMoney.rawValue
                }else {
                    router = model.routerName
                }
                EXNavigationHandler.sharedHandler.commonJumpCommand(router,model.symbol)
            }
        }
    }
    
    @objc func saveImg(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil{
            EXAlert.showFail(msg: "common_tip_saveImgFail".localized())
            return
        }
        EXAlert.showSuccess(msg: "common_tip_saveImgSuccess".localized())
    }
}



class EXCLoundFlartJsApiMethodSwift: NSObject {
    
    var successTokenCallBack: EXComStringBlock?
    var errorCallBack: EXComVoidBlock?
    //Arg is the parameter JSON string handler callback passed from h5
    @objc func exchangeInfo( _ arg:String, handler: JSCallback) {
        let dic = [
           "exchange_token":XUserDefault.tokenValue ?? "",
           "exchange_lan":LanguageHandler.priviatePhoneLanguage,
           "exchange_skin":EXThemeManager.isNight() ? "night" : "day"]
        handler(JSONSerialization.jsonDataFromDictToString(dic),true)
    }
    
    
    @objc func exchangeRouter(_ routerName : String , handler : JSCallback){
        
        
        print("routerName = \(routerName)")
       
        if let model = JSModel.mj_object(withKeyValues: routerName){
            print("model.code = \(model.code) + \(model.result)")
            if model.code == "0" && model.result.isEmpty == false{
                self.successTokenCallBack?(model.result)
            }else{
                self.errorCallBack?()
            }
        }
    }
}

