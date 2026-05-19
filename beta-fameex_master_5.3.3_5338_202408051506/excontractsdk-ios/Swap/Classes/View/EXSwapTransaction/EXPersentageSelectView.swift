//
//  EXPersentageSelectView.swift
//  Chainup
//
//  Created by ZYJ on 2023/12/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXPersentageSelectView: EXSNibBaseView {
    @IBOutlet var stepStacks: UIStackView!
    @IBOutlet var steps: [UIButton]!
    var selectIdx:Int = -1 {
        didSet {
            for (idx,btn) in steps.enumerated() {
                if let layer = btn.layer.sublayers?.first as? CAShapeLayer {
                    
                    if selectIdx  >= 0 {
                        if selectIdx == 0 {
                            if idx == 1 {
                                
                                self.setClearColor(layer)
                            }else {
                                self.setBorderColor(layer)
                            }
                        }else if selectIdx == 1 {
                            if idx == 1 || idx == 2 {
                                self.setClearColor(layer)
                            }else {
                                self.setBorderColor(layer)
                            }
                        }else if selectIdx == 2 {
                            if idx == 2 || idx == 3 {
                                self.setClearColor(layer)
                            }else {
                                self.setBorderColor(layer)
                            }
                        }else {
                            if idx == 3 {
                                self.setClearColor(layer)
                            }else {
                                self.setBorderColor(layer)
                            }
                        }
                    }else {
                        self.setBorderColor(layer)
                    }
                }
            }
        }
    }
//    var clickBtnBlock:EXPersentageSelectViewBtnClickBlock?
    override func onCreate() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.ThemeView.border.cgColor
        layer.cornerRadius = 2
        for (index,btn) in steps.enumerated() {
            if index > 0 {
                let layer = CAShapeLayer()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to:CGPoint(x:0, y:30))
                path.lineWidth = 0.5
                layer.path = path.cgPath
                layer.strokeColor = UIColor.ThemeView.border.cgColor
                btn.layer.addSublayer(layer)
            }
        }

    }
    func emptyPersentage() {
        for btn in steps {
            btn.backgroundColor = UIColor.clear
            btn.layer.cornerRadius = 2
            btn.layer.masksToBounds = true
            btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        }
        selectIdx = -1
        
    }
    
    func getPersent(_ byTag:Int) -> String {
        let arr = ["0.1","0.2","0.5","1"]
        if arr.count > byTag {
            return arr[byTag]
        }else {
            return ""
        }
    }
    @IBAction func onTapStep(_ sender: UIButton) {
//        clickBtnBlock?(getPersent(sender.tag))
        selectIdx = sender.tag
        for btn in steps {
            if btn == sender {
                btn.backgroundColor = UIColor.Ex.main3
                btn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .normal)
            }else {
                btn.backgroundColor = UIColor.clear
                btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
            }
        }
    }
//    override func draw(_ rect: CGRect) {
//        let width = rect.size.width
//        let height = rect.size.height
//        let stepWidth = width/4
//
//        for idx in 1...3 {
//            let path = UIBezierPath()
//            path.move(to: CGPoint(x: stepWidth*CGFloat(idx), y: 0))
//            path.addLine(to:CGPoint(x:stepWidth*CGFloat(idx), y:height))
//            path.lineWidth = 0.5
//
////            if selectIdx  >= 0 {
////                if selectIdx == 0 {
////                    if idx == 1 {
////                        self.setClearColor()
////                    }else {
////                        self.setBorderColor()
////                    }
////                }else if selectIdx == 1 {
////                    if idx == 1 || idx == 2 {
////                        self.setClearColor()
////                    }else {
////                        self.setBorderColor()
////                    }
////                }else if selectIdx == 2 {
////                    if idx == 2 || idx == 3 {
////                        self.setClearColor()
////                    }else {
////                        self.setBorderColor()
////                    }
////                }else {
////                    if idx == 3 {
////                        self.setClearColor()
////                    }else {
////                        self.setBorderColor()
////                    }
////                }
////            }else {
////            }
//            self.setBorderColor()
//            path.stroke()
//        }
//    }
    
    func setClearColor(_ layer:CAShapeLayer) {
        layer.strokeColor = UIColor.clear.cgColor
    }
    
    func setBorderColor(_ layer:CAShapeLayer){
        layer.strokeColor = UIColor.ThemeView.border.cgColor
    }
}
