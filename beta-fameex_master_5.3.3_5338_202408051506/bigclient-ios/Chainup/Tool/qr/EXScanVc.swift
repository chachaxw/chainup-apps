//
//  EXScanVc.swift
//  Chainup
//
//  Created by liuxuan on 2019/5/10.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

class EXScanVc: LBXScanViewController,NavigationPlugin {
    
    typealias ScanResultCallback = (String) -> ()
    var onScanResultCallback:ScanResultCallback?
    var tipLabel:UILabel = UILabel()
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self)
        return nav
    }()
    
    func handleNavigation() {
        self.navigation.setTitle(title: "")
        self.navigation.configRightItems(["scan_text_album".localized()], isImageName: false)
        navigation.rightItemCallback = {[weak self] tag in
            self?.albumAction()
        }
        navigation.setScanClearNavi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNavigation()
    }
    
    func albumAction() {
        LBXPermissions.authorizePhotoWith { [weak self] (granted) in
            
            if granted {
                if let strongSelf = self {
                    
                    if #available(iOS 14, *) {
                        EXImagePHPicker.shared.selectImageFromAlbumSuccess { (image) in
                            strongSelf.setImage(image: image)
                        }
                    } else {
                        // Fallback on earlier versions
                        let picker = UIImagePickerController()
                        
                        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                        picker.delegate = self;
                        
                        picker.allowsEditing = true
                        strongSelf.present(picker, animated: true, completion: nil)
                    }
                }
            } else {
                LBXPermissions.jumpToSystemPrivacySetting()
            }
        }
    }
    
    public override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var image:UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if (image == nil )
        {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if(image == nil) {
            return
        }
        
        if(image != nil) {
            setImage(image: image!)
            return
        }
EXAlert. showFail (msg: "Recognition failed")
    }
    
    func setImage(image:UIImage) {
        
        let arrayResult = LBXScanWrapper.recognizeQRImage(image: image)
        if arrayResult.count > 0 {
            let result = arrayResult[0]
            if let scanned = result.strScanned {
                DispatchQueue.main.async {
                    
                    self.onScanResultCallback?(scanned)
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
            return
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set scanning area parameters
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        style.photoframeLineW = 2
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        style.colorAngle = UIColor(red: 0.0/255, green: 200.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        style.animationImage = UIImage.init(named: "qr_scan_line")
        
        self.scanStyle = style
        self.scanResultDelegate = self
        self.isOpenInterestRect = true
    }
}

extension EXScanVc :LBXScanViewControllerDelegate {
    
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        if let _ = error {
EXAlert. showFail (msg: "Recognition failed")
        }else {
            if let str = scanResult.strScanned {
                onScanResultCallback?(str)
            }else {
EXAlert. showFail (msg: "Recognition failed")
            }
        }
    }
}



