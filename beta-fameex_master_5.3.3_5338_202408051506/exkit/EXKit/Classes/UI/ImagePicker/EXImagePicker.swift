//
//  EXImagePicker.swift
//  EXKit
//
//  Created by zq on 2023/10/26.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI

public class EXImagePicker : NSObject {
    @available(*, unavailable) override init() {}
    
    /// Source for picker image
    public enum `Type` {
        case camera
        case photo
    }
    
    
    /// Show the image picker to get an image from the specified type
    /// - Parameters:
    ///   - controller: The view controller to present the picker viewController
    ///   - types: Sources to pick the image
    ///   - completion: This block will be invoked after get the image, the type is the source of this image
    public class func show(from controller:UIViewController, types:[`Type`] = [.camera,.photo], completion:@escaping (UIImage, `Type`)->Void) {
        guard !types.isEmpty else { return }
        if types.count == 1 {
            showPicker(from: controller, type: types[0], completion: completion)
        }else{
            let sheet = EXActionSheetView()
            sheet.actionIdxCallback = {idx in
                showPicker(from: controller, type: types[idx], completion: completion)
            }
            let titles = types.map({
                switch $0 {
                    case .camera: return "noun_camera_takephoto".localized()
                    case .photo:  return "noun_camera_takeAlbum".localized()
                }
            })
            sheet.configButtonTitles(buttons:titles)
            EXKitAlert.showSheet(sheetView: sheet)
        }
    }
    
    /// Show the image picker to get an image from the specified type
    /// - Parameters:
    ///   - controller: The view controller to present the picker viewController
    ///   - types: Source to pick the image
    ///   - completion: This block will be invoked after get the image, the type is the source of this image
    public class func showPicker(from controller:UIViewController,type:`Type`, completion:@escaping (UIImage, `Type`)->Void) {
        let completionHandler = { image in completion(image, type) }
        switch type {
            case .camera:
                showCameraPicker(from: controller, completion: completionHandler)
            case .photo:
                showPhotoPicker(from: controller, completion: completionHandler)
        }
    }
    
    /// Use the camear to take a photo
    /// - Parameters:
    ///   - controller: The view controller to present the camera
    ///   - completion: This block will be invoked after get the image
    public class func showCameraPicker(from controller:UIViewController, completion:@escaping (UIImage)->Void) {
        EXAuthorization.authorize(.camera) { [weak controller] in
            guard let controller = controller else { return }
            let delegate = EXImagePickerDelegate { image in completion(image) }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = delegate
            objc_setAssociatedObject(picker, &EXImagePickerDelegate.delegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            controller.present(picker, animated: true)
        }
    }
    
    /// Get a photo from the album
    /// - Parameters:
    ///   - controller: The view controller to present the photo picker
    ///   - completion: This block will be invoked after get the image
    public class func showPhotoPicker(from controller:UIViewController, completion:@escaping (UIImage)->Void) {
        EXAuthorization.authorize(.photo) { [weak controller] in
            guard let controller = controller else { return }
            let delegate = EXImagePickerDelegate { image in completion(image) }
            if #available(iOS 14, *) {
                var config = PHPickerConfiguration()
                config.filter = .images
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = delegate
                objc_setAssociatedObject(picker, &EXImagePickerDelegate.delegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                controller.present(picker, animated: true)
            } else {
                let picker = UIImagePickerController()
                picker.delegate = delegate
                objc_setAssociatedObject(picker, &EXImagePickerDelegate.delegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                picker.sourceType = .photoLibrary
                controller.present(picker, animated: true)
            }
        }
    }
    
    
    /// Save image to system album
    /// - Parameters:
    ///   - image: The image to save
    ///   - completion: This block will be invoked after save action invoked, see
    ///   `PHPhotoLibrary.performChanges(changeBlock, completionHandler)`
    public class func saveImageToAlbum(image:UIImage,completion:((Bool,Error?)->Void)? = nil) {
        EXAuthorization.authorize(.savePhoto) {
            DispatchQueue.global(qos: .background).async {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if let completion = completion {
                            completion(success,error)
                        }else{
                            if success {
                                EXKitAlert.showSuccess(msg: "common_tip_saveImgSuccess".localized())
                            }else{
                                EXKitAlert.showFail(msg: "common_tip_saveImgFail".localized())
                            }
                        }
                    }
                }
            }
        }
    }
}

private class EXImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    ///
    static var delegateKey:UInt8 = 0
    ///
    let completion:(UIImage)->Void
    ///
    required init(completion:@escaping (UIImage) -> Void) {
        self.completion = completion
    }
    ///
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let completion = self.completion
        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        picker.dismiss(animated: true)
        guard let image = image else { return }
        completion(image)
    }
    ///
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

@available(iOS 14.0, *)
extension EXImagePickerDelegate : PHPickerViewControllerDelegate {
    ///
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let completion = self.completion
        let itemProvider = results.first?.itemProvider
        picker.dismiss(animated: true)
        guard let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        itemProvider.loadObject(ofClass: UIImage.self, completionHandler: {(image, error) in
            guard let image = image as? UIImage else { return }
            DispatchQueue.main.async {
                completion(image)
            }
        })
    }
}
