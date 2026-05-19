//
//  EXActionSheetButtonItem.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXActionSheetButtonItem: NibBaseView {
    var onlyBtn: Bool = true {
        didSet{
            if onlyBtn{
                
            }else{
                self.actionBtn.setTitle("", for: .normal)
                self.actionBtn.setTitle("", for: .selected)
            }
            titleLabel.isHidden = onlyBtn
            checkImg.isHidden = onlyBtn
            
        }
    }
    @IBOutlet var actionBtn: EXButton!
    @IBOutlet weak var lineView: UIView!
    lazy var checkImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image =  EXKitBundle.svgImage(named: "public_checked")
        return arrowImmg
    }()
    
    ///
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    override func onCreate() {
        self.configure()
    }
    
    func configure() {
        self.actionBtn.clearColors()
        self.actionBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        self.actionBtn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .highlighted)
        self.actionBtn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .selected)
        
        self.addSubViews([titleLabel,checkImg])
        titleLabel.snp_makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        checkImg.snp_makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
}
