//
//  EXImageUploader.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit
enum ExUploadImgType {
    case direct
    case oss
}

class EXImageUploader: NSObject {
    let disposeBag = DisposeBag()
    var ossEntity = UploadFileTokenEntity()
    var image = UIImage()
    var rx_imgUrl = BehaviorRelay<String>(value:"")
    var rx_img = BehaviorRelay<UIImage>(value:UIImage())
    var imgUrl:String {
        get {
            return rx_imgUrl.value
        }
        set {
            rx_imgUrl.accept(newValue)
//            rx_img.accept(self.image)
        }
    }

    //ImgUrlType: all full path half half half path
    func uploadImage(img:UIImage,useBase64:Bool = false,type:String = "2" , imgUrlType : String = "all") {
      
        let useUploadType:ExUploadImgType = EXAppConfigManager.sharedInstance.getUploadImgType()
        let data = img.compressImage()
        let param : [String : Any] = ["imageData" : data.base64EncodedString()]
        self.image = img
        
        if useUploadType == .direct {
            //Use the base64 interface for transfer, and use it in the payment method transfer interface for legal currency
            if useBase64 {
                UploadFileData.sharedInstance.uploadImg(param)
                    .subscribe(onNext: {[weak self] (dict) in
                        guard let mySelf = self else{return}
                        guard let data = dict["data"] as? [String : Any] else{return}
                        mySelf.imgUrl = mySelf.getImageFileName(type: .direct, imgData: data , imgUrlType : imgUrlType)
                    }).disposed(by: self.disposeBag)
            }else {
                UploadFileData.sharedInstance.uploadImg(param)
                    .subscribe(onNext: {[weak self] (dict) in
                        guard let mySelf = self else{return}
                        guard let data = dict["data"] as? [String : Any] else{return}
                        mySelf.imgUrl = mySelf.getImageFileName(type: .direct, imgData: data, imgUrlType: imgUrlType)
                    }).disposed(by: self.disposeBag)
            }
        }else {
            if self.ossEntity.SecurityToken.count > 0 {
                if self.ossEntity.ossUrl.count == 0 {
                    return
                }
                UploadFileData.sharedInstance
                    .uploadOSS(data, uploadFileTokenEntity: self.ossEntity,
                               f: {[weak self] (dict) in
                                guard let mySelf = self else{return}
                                if imgUrlType == "all"{//Full path
                                    if let imgUrl = dict["allImgUrl"] as? String{
                                        mySelf.imgUrl = imgUrl
                                    }
                                }else{//Half path
                                    if let imgUrl = dict["imgUrl"] as? String{
                                        mySelf.imgUrl = imgUrl
                                    }
                                }
                        },
                               b: {[weak self] () in
                                guard let mySelf = self else{return}
                                //The token is invalid, please refresh it
                                mySelf.getTokenAndURL(type)
                        },
                               isshowloading : true)
            }else {
                //Refresh token and upload
                self.getTokenAndUpload(img,type, imgUrlType : imgUrlType)
            }
        }
    }
    
    func getImageFileName(type:ExUploadImgType,imgData:[String:Any] , imgUrlType : String)->String {
        if type == .direct {
            guard let filename = imgData["filename"] as? String else{
                EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_imgUploadFail"))
                return ""
            }
            guard let base_image_url = imgData["base_image_url"] as? String else{
                EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_imgUploadFail"))
                return ""
            }
            if let filenameStr = imgData["filenameStr"] as? String , filenameStr.count != 0{
                if imgUrlType == "all"{
                    return base_image_url + filenameStr
                }else{
                    return filenameStr
                }
            }
            if imgUrlType == "all"{
                return base_image_url + filename
            }else{
                return filename
            }
        }
        return ""
    }
    
    /*
Type=1 for identity authentication
2 Others
     */
    func getTokenAndURL(_ type:String) {
        UploadFileData.sharedInstance.getTokenAndUrl(self.ossEntity,type: type)
    }
    
    func getTokenAndUpload(_ needUploadImg:UIImage,_ type:String , imgUrlType : String) {
        UploadFileData.sharedInstance.getTokenAndUrl(self.ossEntity,type: type) {[weak self] (success) in
            if success {
                self?.uploadImage(img: needUploadImg , imgUrlType : imgUrlType)
            }
        }
    }
    
}

extension EXImageUploader{
    //ImgUrlType: all full path half half half path
//    uploader.uploadImage(img: image , type : "1" , imgUrlType : "half")
    func uploadFile(data: Data,type:String = "1" , imgUrlType : String = "half") {
//        let useUploadType:ExUploadImgType = EXAppConfigManager.sharedInstance.getUploadImgType()
        let data = data
        let param : [String : Any] = ["imageData" : data.base64EncodedString()]
        UploadFileData.sharedInstance.new_uploadfile(param)
            .subscribe(onNext: {[weak self] (dict) in
                guard let mySelf = self else{return}
                guard let data = dict["data"] as? [String : Any] else{return}
                mySelf.imgUrl = mySelf.getImageFileName(type: .direct, imgData: data, imgUrlType: imgUrlType)
            }).disposed(by: self.disposeBag)
        
    }
    
}
