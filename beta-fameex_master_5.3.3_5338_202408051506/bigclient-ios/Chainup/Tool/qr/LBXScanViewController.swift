//
//  LBXScanViewController.swift
//  swiftScan
//
//  Created by lbxia on 15/12/8.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

public protocol LBXScanViewControllerDelegate: class {
     func scanFinished(scanResult: LBXScanResult, error: String?)
}

public protocol QRRectDelegate {
    func drawwed()
}

open class LBXScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
 //Return the scanning result, or you can override the handleCodeResult method by inheriting this controller
   open weak var scanResultDelegate: LBXScanViewControllerDelegate?
    
    open var delegate: QRRectDelegate?
    
   open var scanObj: LBXScanWrapper?
    
   open var scanStyle: LBXScanViewStyle? = LBXScanViewStyle()
    
   open var qRScanView: LBXScanView?

    
    //Activate area recognition function
   open var isOpenInterestRect = false
    
    //Type of identification code
   public var arrayCodeType:[AVMetadataObject.ObjectType]?
    
    //Do you need the current image after recognition
   public  var isNeedCodeImage = false
    
    //Camera startup prompt text
    public var readyString:String! = "loading"

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
              // [self.view addSubview:_qRScanView];
        self.view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }
    
    open func setNeedCodeImage(needCodeImg:Bool)
    {
        isNeedCodeImage = needCodeImg;
    }
    //Set intra frame recognition
    open func setOpenInterestRect(isOpen:Bool){
        isOpenInterestRect = isOpen
    }
 
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        drawScanView()
        
        perform(#selector(LBXScanViewController.startScan), with: nil, afterDelay: 0.3)
    }
    
    @objc open func startScan()
    {
   
        if (scanObj == nil)
        {
            var cropRect = CGRect.zero
            if isOpenInterestRect
            {
                cropRect = LBXScanView.getScanRectWithPreView(preView: self.view, style:scanStyle! )
            }
            
            //Specify several identification codes
            if arrayCodeType == nil
            {
                arrayCodeType = [AVMetadataObject.ObjectType.qr as NSString ,AVMetadataObject.ObjectType.ean13 as NSString ,AVMetadataObject.ObjectType.code128 as NSString] as [AVMetadataObject.ObjectType]
            }
            
            scanObj = LBXScanWrapper(videoPreView: self.view,objType:arrayCodeType!, isCaptureImg: isNeedCodeImage,cropRect:cropRect, success: { [weak self] (arrayResult) -> Void in
                
                if let strongSelf = self
                {
                    //Stop scanning animation
                    strongSelf.qRScanView?.stopScanAnimation()
                    
                    strongSelf.handleCodeResult(arrayResult: arrayResult)
                }
             })
        }
        
        //End camera waiting prompt
        qRScanView?.deviceStopReadying()
        
        //Start scanning animation
        qRScanView?.startScanAnimation()
        
        //Camera operation
        scanObj?.start()
    }
    
    open func drawScanView()
    {
        if qRScanView == nil
        {
            qRScanView = LBXScanView(frame: self.view.frame,vstyle:scanStyle! )
            self.view.addSubview(qRScanView!)
            delegate?.drawwed()
        }
        qRScanView?.deviceStartReadying(readyStr: readyString)
        
    }
   
    
    /**
To process the scanning result, if it inherits from this controller, you can rewrite this method and make corresponding processing, or set delegate to make corresponding processing
     */
    open func handleCodeResult(arrayResult:[LBXScanResult])
    {
        if let delegate = scanResultDelegate  {
            
            self.navigationController? .popViewController(animated: true)
            let result:LBXScanResult = arrayResult[0]
            
            delegate.scanFinished(scanResult: result, error: nil)

        }else{
            
            for result:LBXScanResult in arrayResult
            {
                print("%@",result.strScanned ?? "")
            }
            
            let result:LBXScanResult = arrayResult[0]
            
            showMsg(title: result.strBarCodeType, message: result.strScanned)
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        qRScanView?.stopScanAnimation()
        
        scanObj?.stop()
    }
    
    open func openPhotoAlbum()
    {
        LBXPermissions.authorizePhotoWith { [weak self] (granted) in
            
            let picker = UIImagePickerController()
            
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            picker.delegate = self;
            
            picker.allowsEditing = true
            
           self?.present(picker, animated: true, completion: nil)
        }
    }
    
    //MARK: ------ Image recognition QR code for album selection (barcode not found system method)
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        var image:UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if (image == nil )
        {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if(image != nil)
        {
            let arrayResult = LBXScanWrapper.recognizeQRImage(image: image!)
            if arrayResult.count > 0
            {
                handleCodeResult(arrayResult: arrayResult)
                return
            }
        }
      
        showMsg(title: nil, message: NSLocalizedString("Identify failed", comment: "Identify failed"))
    }
    
    func showMsg(title:String?,message:String?)
    {
        
        let alertController = UIAlertController(title: nil, message:message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertAction.Style.default) { (alertAction) in
                
//                if let strongSelf = self
//                {
//                    strongSelf.startScan()
//                }
            }
        
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
    }
    deinit
    {
//        print("LBXScanViewController deinit")
    }
}

