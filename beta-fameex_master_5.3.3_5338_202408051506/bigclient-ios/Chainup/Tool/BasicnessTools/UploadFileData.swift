//
//  UploadFileData.swift
//  ChoinUp-ExChange
//
//  Created by zewu wang on 2023/8/23.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import EXKit
import AliyunOSSiOS
class UploadFileData: NSObject {
    var failTestIndex: Int = 0 //test

    var client = OSSClient.init()
    
    var credential = OSSStsTokenCredentialProvider.init()
    
    var array = NSMutableArray.init()
    
    //MARK: Single Example
    public static var sharedInstance : UploadFileData{
        struct Static {
            static let instance : UploadFileData = UploadFileData()
        }
        return Static.instance
    }
    
}

extension UploadFileData{
    
    //Upload images
    func uploadImg(_ params : [String : Any]) -> Observable<[String : Any]>{
        
        return Observable.create({ (observer) -> Disposable in
            let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.common, action: NetDefine.upload_img)
            
            let param = NetManager.sharedInstance.handleParamter(params)
            NetManager.sharedInstance.sendRequest(url, parameters: param,isShowLoading: false, success: { [weak self] (result, respose, nil) in
                    guard let s = self else{return}
//                if s.failTestIndex%3 != 2{ //fail
//                    observer.onNext(["data":["":""]])
//                    observer.onCompleted()
//                }else {
                   
                    if let result = result as? [String : Any]{
//                        print("Upload image= (result)")
                        observer.onNext(result)
                    }else{
                        observer.onNext(["data":["":""]])
                        
                    }
//                }
                observer.onCompleted()
            }, fail: { (state, error, nil) in
                observer.onNext(["data":["":""]])
                observer.onCompleted()
            })
            
            return Disposables.create()
        })
        
    }
    
    //Upload images
    func new_uploadfile(_ params : [String : Any]) -> Observable<[String : Any]>{
        
        return Observable.create({ (observer) -> Disposable in
            let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.temp, action: NetDefine.new_upload_File)
            
            let param = NetManager.sharedInstance.handleParamter(params)
            NetManager.sharedInstance.sendRequest(url, parameters: param,isShowLoading: false, success: { [weak self] (result, respose, nil) in
                    guard let s = self else{return}
//                if s.failTestIndex%3 != 2{ //fail
//                    observer.onNext(["data":["":""]])
//                    observer.onCompleted()
//                }else {
                   
                    if let result = result as? [String : Any]{
//                        print("Upload image= (result)")
                        observer.onNext(result)
                    }else{
                        observer.onNext(["data":["":""]])
                        
                    }
//                }
                observer.onCompleted()
            }, fail: { (state, error, nil) in
                observer.onNext(["data":["":""]])
                observer.onCompleted()
            })
            
            return Disposables.create()
        })
        
    }
    func otcUploadImg(_ params : [String : Any]) -> Observable<[String : Any]>{
        
        return Observable.create({ (observer) -> Disposable in
            
//            let url = NetManager.sharedInstance.url(NetDefine.http_host_url, model: NetDefine.otc_upload_qrcode, action: "")
            let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.otc_upload_qrcode, action: "")

            let param = NetManager.sharedInstance.handleParamter(params)
            NetManager.sharedInstance.sendRequest(url, parameters: param, success: { (result, respose, nil) in
                if let result = result as? [String : Any]{
                    observer.onNext(result)
                }
                observer.onCompleted()
            }, fail: { (state, error, nil) in
                
            })
            
            return Disposables.create()
        })
    }
}

extension UploadFileData{
    
    func getTokenAndUrl(_ eentity : UploadFileTokenEntity , type : String = "2") {
        self.getTokenAndUrl(eentity, rstSuccess: nil)
    }
    //Type 1 Real name authentication 2 Other
    
    func getTokenAndUrl(_ eentity : UploadFileTokenEntity , type : String = "2",rstSuccess: ((Bool) -> ())?) {
        
//        ProgressHUDManager.showStatus("loading...", maskType: SVProgressHUDMaskType.clear)
        
//        let url = NetManager.sharedInstance.url(NetDefine.http_host_url, model: NetDefine.common, action: NetDefine.get_image_token)
        let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost(), model: NetDefine.common, action: NetDefine.get_image_token)

        let param = NetManager.sharedInstance.handleParamter(["operate_type" : type])
        
        NetManager.sharedInstance.sendRequest(url, parameters: param, isShowLoading : false,success: {[weak self] (result, response, nil) in
            guard let mySelf = self else{return}
            if let dict = result as? [String : Any]{
                if let data1 = dict["data"] as? [String : Any]{
//                    let entity = UploadFileTokenEntity()
//                    entity.setEntityWithDict(data1)
                    eentity.setEntityWithDict(data1)
                    rstSuccess?(true)
                }
            }
        }) { (state, error, nil) in
            rstSuccess?(false)
            if (error as? NSError)?.code == 101118{
                return
            }
            EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_imgUploadFail"))
        }
    }
    
//    //Type 1 Real name authentication 2 Other
//    func getTokenAndUrl(_ data : Data , f : @escaping (([String : Any]) -> ()) , type : String){
//
//        ProgressHUDManager.showStatus("loading...", maskType: SVProgressHUDMaskType.clear)
//
//        let url = NetManager.sharedInstance.url(NetDefine.http_host_url, model: NetDefine.common, action: NetDefine.get_image_token)
//        let param = NetManager.sharedInstance.handleParamter(["operate_type" : type])
//
//        NetManager.sharedInstance.sendRequest(url, parameters: param, isShowLoading : false,success: {[weak self] (result, response, nil) in
//            guard let mySelf = self else{return}
//            if let dict = result as? [String : Any]{
//                if let data1 = dict["data"] as? [String : Any]{
//                    let entity = UploadFileTokenEntity()
//                    entity.setEntityWithDict(data1)
//                    mySelf.uploadOSS(data , uploadFileTokenEntity: entity ,f : f)
//                }
//            }
//        }) { (state, error, nil) in
//            ProgressHUDManager.dismissWithDelay {
//                EXAlert.showFail(LanguageTools.getString(key: "toast_upload_pic_failed"))
//            }
//        }
//
//    }

    //Upload OSS
    func uploadOSS(_ data : Data , uploadFileTokenEntity :UploadFileTokenEntity,f : @escaping (([String : Any]) -> ()),b : @escaping (() -> ()) ,isshowloading : Bool = false){
        if isshowloading == true{
            XHUDManager.sharedInstance.loading()
        }
        
        credential = OSSStsTokenCredentialProvider.init(accessKeyId: uploadFileTokenEntity.AccessKeyId, secretKeyId: uploadFileTokenEntity.AccessKeySecret, securityToken: uploadFileTokenEntity.SecurityToken)
        //Warehouse directory
        let uploadPart = OSSPutObjectRequest.init()
        uploadPart.bucketName = uploadFileTokenEntity.bucketName//
//        //Image Name
//        var arc = ""
//        for _ in 0..<6{
//            arc = arc + "\(arc4random()%10)"
//        }
        let imageName = AppService.md5(data.base64EncodedString())  + ".png"
        uploadPart.objectKey = uploadFileTokenEntity.catalog + imageName
//        uploadPart.contentType = "image/png"
        uploadPart.uploadingData = data//Data data of images
        
        client = OSSClient.init(endpoint: uploadFileTokenEntity.ossUrl , credentialProvider: credential)
        
        let putTask = client.putObject(uploadPart)
        array.add(putTask)
        putTask.continue ({[weak self] (task) -> Any? in
            guard let mySelf = self else{return nil}
            if task.error == nil{
                DispatchQueue.main.async {
                    EXAlert.showSuccess(msg: LanguageTools.getString(key: "common_tip_imgUploadSuccess"))
                    var h = ""
                    if uploadFileTokenEntity.ossUrl.contains("http://"){
                        h = "http://"
                        uploadFileTokenEntity.ossUrl = uploadFileTokenEntity.ossUrl.replacingOccurrences(of: "http://", with: "")
                    }else if uploadFileTokenEntity.ossUrl.contains("https://"){
                        h = "https://"
                        uploadFileTokenEntity.ossUrl = uploadFileTokenEntity.ossUrl.replacingOccurrences(of: "https://", with: "")
                    }
                    let allImgUrl = h + uploadPart.bucketName + "." + uploadFileTokenEntity.ossUrl + uploadPart.objectKey
                    let imgUrl = uploadPart.objectKey
                    f(["imgUrl" : imgUrl , "allImgUrl" : allImgUrl])
                }
            }else{
                DispatchQueue.main.async {
                    EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_imgUploadFail"))
                }
                b()
            }
            if mySelf.array.contains(putTask){
                mySelf.array.remove(putTask)
            }
            return nil
        })
        
    }
    
}

class UploadFileTokenEntity: SuperEntity {
    
    var AccessKeyId = "" //Account
    var AccessKeySecret = ""//password
    var Expiration = ""//Expiration time
    var SecurityToken = ""//Upload image token
    var catalog = ""//Upload image secondary directory
    var ossUrl = "" //Upload image URL
    var bucketName = ""//Warehouse name
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        AccessKeyId = dictContains("AccessKeyId")
        AccessKeySecret = dictContains("AccessKeySecret")
        Expiration = dictContains("Expiration")
        SecurityToken = dictContains("SecurityToken")
        catalog = dictContains("catalog")
        bucketName = dictContains("bucketName")
        ossUrl = dictContains("ossUrl")
    }
    
}

extension UploadFileData{
    func uploadFile(_ params : Data) -> Observable<[String : Any]>{
        return Observable.create({ (observer) -> Disposable in
            
            let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getAppAPIHost() , model: "", action:NetDefine.upload_File)
            var header = [String: String]()
            header["Content-Type"] = "multipart/form-data"
            header["Content-Disposition"] = "form-data; name=\"file\"; filename=\"log.zip\""
            header["Content-Length"] = String(params.count)
            let newHeader = HTTPHeaders(header)
            AF.upload( params, to: url,method:.post, headers:newHeader).validate().response { (DDataRequest) in
                if let acceptData = DDataRequest.data {
                    debugPrint(String.init(data: acceptData, encoding: String.Encoding.utf8)!)
                }
                if DDataRequest.error != nil {
//                    print("Upload failed!!!")
                }
            }
            
            return Disposables.create()
        })
    }
}

