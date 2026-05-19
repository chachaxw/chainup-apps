//
//  EXAnnouncementDetailsVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import Alamofire
import EXKit

class EXAnnouncementDetailsVC: WebVC {

    var entity = EXAnnouncementEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        self.setTitle(self.entity.title)
        let dayType = EXThemeManager.isNight() ? "1" : "0"
        let server = EXNetworkDoctor.sharedManager.getAppAPIHost()
        let url = NetManager.sharedInstance.url(server, model: NetDefine.noticeDetail, action: "") + "?id=\(entity.id)&dayType=\(dayType)&lan=\(LanguageHandler.priviatePhoneLanguage)"
//        var param : [String:Any] = [:]
//        param["id"] = entity.id
//        param["dayType"] = EXThemeManager.isNight() ? "0" : "1"
//        param["lan"] = LanguageTools.phoneLanguage
        NetManager.sharedInstance.sendRequest(url, parameters: nil,mothed:HTTPMethod.get,isShowLoading : false ,success: { (result, response, nil) in
            if let dict = result as? [String:Any]{
                if let urlDict = dict["data"] as? [String:Any]{
                    if let url = urlDict["html"] as? String{
                        self.loadUrl(url)
                    }
                }
            }
        }, fail: { (state , error,nil) in
            
        })
        
        
        // Do any additional setup after loading the view.
    }
    
    override func setNavCustomV() {
        super.setNavCustomV()
        self.setTitle(LanguageTools.getString(key: "personal_text_notice"))
        self.lastVC = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
