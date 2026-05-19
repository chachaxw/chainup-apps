//
//  EXImagePicker.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI
import MobileCoreServices
import EXKit
@objc protocol EXOldImagePickerDelegate {

    @objc optional func selectImageFinished(_ image:UIImage)
}

typealias cameraSuccess   = (_ imagePickerController:UIImagePickerController)  -> Void


class EXOldImagePicker: NSObject {
    private var imagePickerController:UIImagePickerController!
    private var image:UIImage?
    weak var delegate:EXOldImagePickerDelegate?

    
    deinit{
        print("dealloc : \(self)")
    }
    
    override init() {
        super.init()
        prepareCamera()
    }
    
    func prepareCamera() {
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
    }
    
    //MARK: Taking pictures from a camera
    func selectImageFromCameraSuccess(_ closure:@escaping cameraSuccess,Fail failClosure:(() -> Void)? = nil){
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .restricted || authStatus == .denied{
            if failClosure != nil {
                failClosure!()
                DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.4) {
                    EXCameraAlert.popAuthAlert()
                }
            }
            return
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            imagePickerController.mediaTypes = [kUTTypeImage as String]
//            imagePickerController.cameraCaptureMode = .photo
            closure(imagePickerController)
        }
    }
    
    //MARK: Taking pictures from a camera
    func selectImageFromAlbumSuccess(_ closure:@escaping cameraSuccess,Fail failClosure:(() -> Void)? = nil){
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .restricted || authStatus == .denied{
            if failClosure != nil {
                DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.4) {
                    EXCameraAlert.popAuthAlert()
                }
                failClosure!()
            }
            return
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePickerController.sourceType = .savedPhotosAlbum
            imagePickerController.mediaTypes = [kUTTypeImage as String]
            closure(imagePickerController)
        }
    }
    
}

extension EXOldImagePicker : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let img = info[.originalImage] as? UIImage else { return }
        self.image = img
        self.delegate?.selectImageFinished?(image!)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EXOldImagePicker : UINavigationControllerDelegate {
    
}

