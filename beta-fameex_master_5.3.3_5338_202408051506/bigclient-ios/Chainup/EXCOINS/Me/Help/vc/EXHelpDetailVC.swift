//
//  EXHelpDetailVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import Alamofire
import EXKit
class EXHelpDetailVC: WebVC {

    var entity = EXHelpEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getData()
        self.setTitle(LanguageTools.getString(key: "personal_text_helpcenter"))
        self.view.backgroundColor = UIColor.clear
    }
    
    func getData(){
        
        //        let time = DateTools.getNowTimeInterval()
        let server = EXNetworkDoctor.sharedManager.getAppAPIHost()
        let url = NetManager.sharedInstance.url(server, model: NetDefine.kv_common, action: "")
        NetManager.sharedInstance.sendRequest(url, parameters: nil,mothed:HTTPMethod.get,isShowLoading : false , success: { (result, response, nil) in
            
            if let dict = result as? [String:Any]{
                
                if let urlDict = dict["data"] as? [String:Any]{
                    if let url = urlDict["h5_url"] as? String{
                        let h5_url = url + "/noticeDetail?id=" + self.entity.fileName + "&type=cms"
                        self.loadUrl(h5_url)
                    }
                }
            }
        }, fail: { (state , error,nil) in
            
        })

    }
    
    override func setNavCustomV() {
        super.setNavCustomV()
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
