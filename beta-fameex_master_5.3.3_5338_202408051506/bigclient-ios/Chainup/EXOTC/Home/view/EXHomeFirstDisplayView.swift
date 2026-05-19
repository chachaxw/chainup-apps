//
//  EXHomeFirstDisplayView.swift
//  Chainup
//
//  Created by ljw on 2023/12/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXHomeFirstDisplayView: UIView {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var readLab: UILabel!
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var scollView: UIScrollView!
    @IBOutlet weak var scollViewHCon: NSLayoutConstraint!
    @IBOutlet weak var contentLab: UILabel!
    @IBOutlet weak var bottomBtn: UIButton!
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        self.backView.backgroundColor = UIColor.ThemeView.bg
        self.backView.layer.cornerRadius = 1.5
        self.backView.layer.masksToBounds = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.contentLab.textColor = UIColor.ThemeLabel.colorLite
        self.bottomBtn.setTitle("alert_common_iknow".localized(), for: UIControl.State.normal)
        self.chooseBtn.setImage(UIImage.themeImageNamed(imageName: "unchecked"), for: UIControl.State.normal)
        self.chooseBtn.setImage(UIImage.themeImageNamed(imageName: "selected"), for: UIControl.State.selected)
        self.chooseBtn.isSelected = true
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(tap))
        let gesture1 = UITapGestureRecognizer.init(target: self, action: #selector(tap))
        self.readLab.addGestureRecognizer(gesture1)
        self.chooseBtn.addGestureRecognizer(gesture)
        self.readLab.text = "common_has_known".localized()
        
    }
    
    @objc func tap() {
        self.chooseBtn.isSelected = !self.chooseBtn.isSelected
    }
    
    @IBAction func btnClick(_ sender: UIButton) {
        if !self.chooseBtn.isSelected {
            return
        }
        UserDefaults.standard.set(true, forKey: "EXHomeFirstDisplayView")
        self.removeFromSuperview()
    }
    
    class func needShow() ->Bool {
        let flag = UserDefaults.standard.bool(forKey: "EXHomeFirstDisplayView")
        let msg = EXAppConfigManager.sharedInstance.homePopWindowTxt()
        if !flag && msg.count > 0{
            return true
        }else {
            return false
        }
    }
    
    class func show() {
        if self.needShow(){
            let msg = EXAppConfigManager.sharedInstance.homePopWindowTxt()
            let view = Bundle.main.loadNibNamed("EXHomeFirstDisplayView", owner: nil, options: nil)?.first as? EXHomeFirstDisplayView
            if let displayView = view {
                displayView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                displayView.contentLab.text = msg
                var isFind = false
                if let subViews = UIApplication.shared.keyWindow?.subviews {
                    for view in subViews {
                        if view.isKind(of: EXHomeFirstDisplayView.self) {
                            isFind = true
                        }
                    }
                }
                if !isFind {
                    UIApplication.shared.keyWindow?.addSubview(displayView)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let str = self.contentLab.text
        if let str1 = str {
            let font = self.contentLab.font ?? UIFont.init()
            let height = str1.boundingRect(with: CGSize.init(width: UIScreen.main.bounds.size.width-80, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size.height + 1
            scollViewHCon.constant = height
            if height > 155 {
                scollViewHCon.constant = 155
            }
            self.scollView.contentSize = CGSize.init(width: 0, height: height)
        }
    }
}
