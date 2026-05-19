//
//  EXScanVc.swift
//  Chainup
//
//  Created by liuxuan on2020/5/10.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit

public class EXScanVc: LBXScanViewController,UIGestureRecognizerDelegate {
    
    public typealias ScanResultCallback = (String) -> ()
    public var onScanResultCallback:ScanResultCallback?
    
    
    lazy var backBtn : UIButton = {
        let btn =  UIButton.init(type: .custom)
        let img = EXKitBundle.image(named: "public_return", color: .dark)
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: #selector(pop), for: .touchUpInside)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    lazy var albumBtn : UIButton = {
        let btn =  UIButton.init(type: .custom)
        btn.setTitleColor(UIColor.white, for: .normal)
        let img = EXKitBundle.image(named: "home_img_picture")
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: #selector(albumAction), for: .touchUpInside)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    lazy var albumBtnTitle : UILabel = {
        let l = UILabel()
        l.font = .Ex.medium(14)
        l.textAlignment = .center
        l.textColor = UIColor.white
        l.text = EXUIDatasource.shared.scan_photo_title
        return l
    }()
    
    public lazy var titleLabel : UILabel = {
        let label = UILabel(text: "scan_action_scan".localized(), font: .Ex.medium(16), textColor: .white)
        return label
    }()
    //底部二维码扫码提示语
    public lazy var tipLabel : UILabel = {
        let l = UILabel(text: "scan_tip_aimToScan".localized(), font: .Ex.regular(12), textColor: .white, alignment: .center)
        return l
    }()
    
        
    @objc func pop() {
        self.popBack()
    }

    //默认为白色
    override public var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
//        if EXThemeManager.isNight() == true{
//            return .lightContent
//        }else{
//            return .default
//        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configNavi()
        setNavLeft()
    }
    //侧滑返回
    func setNavLeft(){
        if (self.navigationController != nil && (self.navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)))!) {
            self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        }
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer{
            if let count = self.navigationController?.viewControllers.count , count < 2 || self.navigationController?.visibleViewController == self.navigationController?.viewControllers[0]{
                return false
            }
        }
        return true
    }
    @objc func albumAction() {
        EXImagePicker.showPhotoPicker(from: self) {[weak self] image in
            self?.setImage(image: image)
        }
    }
    
    func setImage(image:UIImage) {
        
        let arrayResult = LBXScanWrapper.recognizeQRImage(image: image)
        if arrayResult.count > 0 {
            let result = arrayResult[0]
            if let scanned = result.strScanned {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.onScanResultCallback?(scanned)
                }
            }
            return
        }else{
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                self.onScanResultCallback?("")
            }
        }
        
    }
    
    
    func configNavi() {
        if self.backBtn.superview == nil  {
            self.view.addSubViews([self.backBtn,self.titleLabel,self.albumBtn,self.albumBtnTitle,self.tipLabel])
            self.backBtn.snp.makeConstraints { make in
                make.leading.equalTo(Margin_L)
                make.width.height.equalTo(20)
                make.top.equalTo(NAV_H - 30)
            }
            self.titleLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(self.backBtn)
            }
            self.albumBtn.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-(TABBAR_H + 22))
                make.centerX.equalToSuperview()
                make.width.height.equalTo(44)
            }
            
            self.albumBtnTitle.snp.makeConstraints { make in
                make.top.equalTo(self.albumBtn.snp.bottom).offset(5)
                make.centerX.equalToSuperview()
            }
            
            //扫描底部添加提示语,
            let scanWH = Device_W - self.style.xScanRetangleOffset * 2
            let YMinRetangle = Device_H / 2.0 - scanWH/2.0 - self.style.centerUpOffset
            let YMaxRetangle = YMinRetangle + scanWH
            let tipY = YMaxRetangle + 15
            self.tipLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(tipY)
            }
            
        }
    }
    var style = LBXScanViewStyle()
    public override func viewDidLoad() {
        super.viewDidLoad()
        //设置扫码区域参数
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Outer
        style.colorAngle = .Ex.fill2
        style.photoframeLineW = 3
        style.photoframeAngleW = 16
        style.photoframeAngleH = 16
        style.isNeedShowRetangle = false
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        style.animationImage = UIImage.init(named: "qr_scan_line")
        readyString = ""
        self.scanStyle = style
        self.scanResultDelegate = self
        self.isOpenInterestRect = true
    }
}

extension EXScanVc :LBXScanViewControllerDelegate {
    
    public func scanFinished(scanResult: LBXScanResult, error: String?) {
        if let str = scanResult.strScanned {
                onScanResultCallback?(str)
        }
    }
}




