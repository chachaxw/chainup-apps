//
//  EXGuideMaskView.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/20.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

enum GuideViewAliemnts {
    case bottomLeft
    case bottomRight
}

class EXGuideMaskView: UIView {
    var countNum:Int = 0
    
    var transparentPaths:[UIBezierPath] = []
    var viewItemArr:[EXHomeGuideBase] = []
    var aliemnts:[GuideViewAliemnts] = []
    var transparentRects:[CGRect] = []
    var transInsids:[UIEdgeInsets] = []

    var clickIdx:Int = 0
    var isOneByOne:Bool = true
    var isGuding:Bool = false
    
    typealias GuideShowCallback = () -> ()
    var guideCallback : GuideShowCallback?
    
    lazy var fillLayer:CAShapeLayer = {
        let flayer = CAShapeLayer()
        flayer.frame = self.bounds
        return flayer
    }()
    
    lazy var overlayPath:UIBezierPath = {
        let path = UIBezierPath.init(rect: self.bounds)
        path.usesEvenOddFillRule = true
        return path
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        self.backgroundColor = UIColor.clear
        self.clickIdx = 0
        self.isOneByOne = true
        self.fillLayer.path = self.overlayPath.cgPath
        self.fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        self.fillLayer.fillColor = UIColor.ThemeView.mask.cgColor
        self.layer.addSublayer(fillLayer)

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapClickMask))
        self.addGestureRecognizer(tapGesture)
    }
    
    //Tooltip for viewitems
    //Transparantitems hollowing out view
    //OrderArray display order, total equal to the total number of viewitems
    func handleGuides(viewitems:[EXHomeGuideBase],transparentItems:[UIView],aligments:[GuideViewAliemnts],transItemInsets:[UIEdgeInsets] = []){
        if viewitems.count == 0 || transparentItems.count == 0 {
            return
        }
        if viewitems.count != transparentItems.count ||
            viewitems.count != aligments.count {
            return
        }
        if isGuding {
            return
        }

        if transItemInsets.count == 0 {
            for _ in 0..<viewitems.count {
                self.transInsids.append(UIEdgeInsets.zero)
            }
        }else {
            if viewitems.count != transItemInsets.count {
                return
            }
            self.transInsids = transItemInsets
        }
        isGuding = true
        viewItemArr = viewitems
        self.aliemnts = aligments
        self.transparentRects = transparentItems.enumerated().map({ (idx,view) -> CGRect in
            let inset = transInsids[idx]
            let rect = view.convert(view.bounds, to: self.yy_viewController?.view)
            print(self.yy_viewController?.view)
            print(rect)
            return CGRect(x: rect.origin.x + inset.left,
                          y: rect.origin.y + inset.top,
                          width: rect.width - (inset.left + inset.right),
                          height: rect.height - (inset.top + inset.bottom))
        })
        
        for rect in transparentRects {
            let bezier = UIBezierPath.init(roundedRect: rect,
                                           cornerRadius: 4)
            transparentPaths.append(bezier)
        }
        addGuideView(withIdx: 0)
        addTransparentPath(path: transparentPaths[0])
    }
    
    func addGuideView(withIdx:Int) {
        
        let withItem = viewItemArr[withIdx]
        let rect = transparentRects[withIdx]
        let aliment = self.aliemnts[withIdx]
        self.addSubview(withItem)
        
        if viewItemArr.count - 1 == withIdx {
            withItem.nextBtn.setTitle("market_text_custom_finish".localized(), for: .normal)
        }
        
        withItem.skipBtn.setTitle("common_guide_skip_hint".localized() + "(\(withIdx+1)/\(viewItemArr.count))", for: .normal)
        withItem.skipBtn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        withItem.nextBtn.addTarget(self, action: #selector(tapClickMask), for: .touchUpInside)
        if aliment == .bottomLeft {
            withItem.snp.makeConstraints { (make) in
                make.width.equalTo(withItem.configWidth)
                make.top.equalTo(rect.maxY + withItem.yOffset + 5)
                make.left.equalTo(rect.origin.x + withItem.xOffset)
            }
        }else if aliment == .bottomRight {
            withItem.snp.makeConstraints { (make) in
                make.width.equalTo(withItem.configWidth)
                make.top.equalTo(rect.maxY + withItem.yOffset + 5)
                make.left.equalTo(rect.maxX - withItem.configWidth + withItem.xOffset)
            }
        }

        withItem.alpha = 0
        UIView.animate(withDuration: 0.3) {
            withItem.alpha = 1.0
        }
        
    }
    
    func addTransparentPath(path:UIBezierPath) {
        self.overlayPath.append(path)
        self.fillLayer.path = self.overlayPath.cgPath
    }
}

extension EXGuideMaskView {
    
    @objc func tapClickMask() {
        clickIdx += 1
        if isOneByOne {
            if clickIdx < viewItemArr.count {
                refreshMask()
                self.addTransparentPath(path: transparentPaths[clickIdx])
                self.subviews.forEach { (v) in
                    UIView.animate(withDuration: 0.3) {
                        v.alpha = 0.0
                    }completion: { (Bool) in
                        v.removeFromSuperview()
                    }
                }
                self.addGuideView(withIdx: clickIdx)
            }else {
                dismiss()
            }
        }else {
            dismiss()
        }
    }
    
    func refreshMask() {
        let path = UIBezierPath.init(rect: self.bounds)
        path.usesEvenOddFillRule = true
        self.overlayPath = path
    }
    
    func showGuideView() {
        self.alpha = 0
        if let window = UIApplication.shared.keyWindow {
            for v in window.subviews {
                if v is EXGuideMaskView {
                    v.removeFromSuperview()
                }
            }
        }
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { (finished) in
            self.guideCallback?()
            self.removeFromSuperview()
        }
    }
}

