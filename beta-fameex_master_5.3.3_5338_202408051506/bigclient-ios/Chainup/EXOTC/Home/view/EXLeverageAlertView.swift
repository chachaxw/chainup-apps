
//
//  EXLeverageAlertView.swift
//  Chainup
//
//  Created by ljw on 2023/12/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXLeverageAlertView: UIView {
    typealias LeverageAlertBlock = () -> ()
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var contentLab: UILabel!
    @IBOutlet weak var cancleBtn: UIButton!
    var confirmBlock : LeverageAlertBlock?
    var cancleBlock : LeverageAlertBlock?
    
    var isTransfer = false
    
    @IBOutlet weak var confirmBtn: UIButton!
    @IBAction func confirmBtnClick(_ sender: UIButton) {
        if !self.chooseBtn.isSelected {
            return
        }
        UserDefaults.standard.set(true, forKey: "EXLeverageAlertView")
        self.removeFromSuperview()
        self.confirmBlock?()
    }
    @IBAction func cancleBtnClick(_ sender: Any) {
        self.removeFromSuperview()
        self.cancleBlock?()
    }
    override func awakeFromNib() {
        self.backView.backgroundColor = UIColor.ThemeView.alertBg
        self.backView.layer.cornerRadius = 1.5
        self.backView.layer.masksToBounds = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.chooseBtn.setImage(UIImage.themeImageNamed(imageName: "unchecked"), for: UIControl.State.normal)
        self.chooseBtn.setImage(UIImage.themeImageNamed(imageName: "selected"), for: UIControl.State.selected)
        
        
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(tap))
        let gesture1 = UITapGestureRecognizer.init(target: self, action: #selector(tap))
        let gesture2 = UITapGestureRecognizer.init(target: self, action: #selector(agree))
        self.contentLab.addGestureRecognizer(gesture1)
        self.chooseBtn.addGestureRecognizer(gesture)
        self.titleLab.addGestureRecognizer(gesture2)
        self.contentLab.text = "common_has_known".localized()
        self.cancleBtn.setTitle("common_text_btnCancel".localized(), for: UIControl.State.normal)
        self.confirmBtn.setTitle("common_start_trade".localized(), for: UIControl.State.normal)
    }
    @objc func tap() {
        self.chooseBtn.isSelected = !self.chooseBtn.isSelected
    }
    @objc func agree(){
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        let vc = WebVC()
        vc.missBlock = {
            self.isHidden = false
        }
        self.isHidden = true
        vc.setTitle("lever_trade_agreement".localized())
        vc.modalPresentationStyle = .fullScreen
        vc.loadUrl(EXAppConfigManager.sharedInstance.getLeverProtocolURL())
        appDelegate.window??.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    class  func show() -> EXLeverageAlertView?{
        let flag = UserDefaults.standard.bool(forKey: "EXLeverageAlertView")
        if !flag && EXAppConfigManager.sharedInstance.getLeverProtocolURL().count > 0{
            var isFind = false
            if let subViews = UIApplication.shared.keyWindow?.subviews {
                for view in subViews {
                    if view.isKind(of: EXLeverageAlertView.self) {
                        isFind = true
                    }
                }
            }
            if isFind {//If there is a display, it will not be created
                return nil
            }
            let view = Bundle.main.loadNibNamed("EXLeverageAlertView", owner: nil, options: nil)?.first as? EXLeverageAlertView
            if let displayView = view {
                displayView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                let str = "lever_trade_agreement".localized()
                let allStr = "lever_need_read".localized()
                let att = NSMutableAttributedString.init(string:allStr)
                att.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor:UIColor.ThemeLabel.colorLite], range: att.yy_rangeOfAll())
                att.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor:UIColor.ThemeBtn.highlight], range: (att.string as NSString) .range(of: str))
                displayView.titleLab.attributedText = att
                UIApplication.shared.keyWindow?.addSubview(displayView)
                return displayView
            }else {
                return nil
            }
            
        }else {
            return nil
        }
        
    }
}

