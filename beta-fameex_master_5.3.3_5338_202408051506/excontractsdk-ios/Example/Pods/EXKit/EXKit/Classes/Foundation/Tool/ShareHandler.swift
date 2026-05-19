//
//  ShareTool.swift
//  EXKit
//
//  Created by liuxuan on 2022/7/12.
//

import UIKit

public class ShareHandler: NSObject {
    public class func share(_ vc : UIViewController , text : String = "", url : String = "",image : UIImage? = nil ,completionHandler : @escaping (() -> ()) ){
        //初始化一个UIActivity
        let activity = UIActivity()
        var activityItems : [Any] = []
        if text != ""{
            activityItems.append(text)
        }
        if url != "" , let shareUrl = URL.init(string: url){
            activityItems.append(shareUrl)
        }
        if image != nil{
            activityItems.append(image ?? UIImage())
        }
        let activities = [activity]
        //初始化UIActivityViewController
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
        //排除一些服务：例如复制到粘贴板，拷贝到通讯录
        activityController.excludedActivityTypes = [.copyToPasteboard,.assignToContact]
        //iphone中为模式跳转
        activityController.modalPresentationStyle = .fullScreen
        vc.present(activityController, animated: true) { () -> Void in
        }
        //结束后执行的Block，可以查看是那个类型执行，和是否已经完成
        activityController.completionWithItemsHandler = {activityType, completed, returnedItems, activityError in
            if activityError == nil , completed == true{
            }else{
                NSLog("失败")
            }
            completionHandler()
        }
        //        activityController.completionHandler = { activityType, error in
        //            if error == false{
        //            }
        //        }
    }
}
