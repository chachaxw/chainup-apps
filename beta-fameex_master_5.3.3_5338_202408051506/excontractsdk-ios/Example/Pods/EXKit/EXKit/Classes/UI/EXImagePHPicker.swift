//
//  EXImagePHPicker.swift
//  Chainup
//
//  Created by ZYJ on 2020/9/28.
//  Copyright © 2020 ChainUP. All rights reserved.
//

import UIKit
import PhotosUI

@available(iOS 14, *)

public typealias PHPickerSuccess = (_ image:UIImage)  -> Void

@available(iOS 14, *)

public class EXImagePHPicker: NSObject {
      
    static var picker = EXImagePHPicker()
    open class var shared: EXImagePHPicker {
        return picker
    }
    var pickerSuccess:PHPickerSuccess?
    var pickerFail:EXComVoidBlock?
    //MARK:从相机拍摄图片
    public func selectImageFromAlbumSuccess(_ closure:@escaping PHPickerSuccess, Fail failClosure:(() -> Void)? = nil){
        
        pickerSuccess = closure
        
        LBXPermissions.authorizePhotoWith {  (granted) in
            
            if granted {
                
                //                        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: strongSelf)
                var config = PHPickerConfiguration()
                config.filter = PHPickerFilter.images
//                config.selectionLimit = 1
                //PHPickerViewController
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self

                AppService.topViewController().present(picker, animated: true, completion: {
                    
                })

            } else {
                LBXPermissions.jumpToSystemPrivacySetting()
            }
        }
    }
}

@available(iOS 14, *)
extension EXImagePHPicker : PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        DispatchQueue.main.async {
            
            picker.dismiss(animated: true, completion: nil)
        }
        if results.count == 0 {
            return
        }
        let provider = results.first?.itemProvider
        provider?.loadObject(ofClass: UIImage.self, completionHandler: { (obj, error) in
            if  let img = obj as? UIImage {
                //返回图片
                
                self.pickerSuccess?(img)
                return;
            }
            self.pickerFail?()
//            EXKitAlert.showFail(msg:EXUIDatasource.shared.scan_fail_msg)
        })
    }
}
