//
//  EXDrawerVC.swift
//  Chainup
//
//  Created by zewu wang on2020/4/1.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit
import SnapKit

let dr_Width = 280 / 375 * min(Device_W, Device_H)

public class EXDrawerVC: UIViewController {
    
    public typealias PullBlock = () -> ()
    public var pullBlock : PullBlock?
    var isOpen:Bool = false
    
    //背景
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.alpha = 0
        view.backgroundColor = UIColor.ThemeView.mask
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(pullAnimation))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    //抽屉背景
    lazy var drawerV : UIView = {
        let view = UIView.init(frame: CGRect.init(x: -dr_Width, y: 0, width: dr_Width, height: max(Device_H, Device_W)))
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view.addSubViews([backView,drawerV])
        backView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        //导航控制器根控制器禁止左滑 否则 左滑 易出现卡顿现象
        let screenPan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(rightSliderScreen))
        screenPan.edges = UIRectEdge.left
        self.view.addGestureRecognizer(screenPan)
        //
        let swipLeft = UISwipeGestureRecognizer(target: self, action: #selector(pullAnimation))
        swipLeft.direction = .left
        view.addGestureRecognizer(swipLeft)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
    }
    
    @objc open func rightSliderScreen(_ pan : UIScreenEdgePanGestureRecognizer){
        //do nothing
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置抽屉的位置
    private func makeDrawerV(_ push : Bool){
        if push == true{
            drawerV.frame = CGRect.init(x: 0, y: 0, width: dr_Width, height: max(Device_H, Device_W))
        }else{
            drawerV.frame = CGRect.init(x: -dr_Width, y: 0, width: dr_Width, height: max(Device_H, Device_W))
        }
    }
    
    //推出动画
    public func pushAnimation(){
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
            self.makeDrawerV(true)
            self.backView.alpha = 1
        }) { (b) in
            if b == true{
                self.isOpen = true
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    //收回动画
    @objc public func pullAnimation(){
        if self.isOpen == false {return}
        view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
             self.makeDrawerV(false)
             self.backView.alpha = 0
        }) { (b) in
            if b == true{
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.isOpen = false
                self.pullBlock?()
            }
        }
    }
    
    @objc public func pullAnimationCallback(callb: @escaping ()->()) {
        if self.isOpen == false {return}
        view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
             self.makeDrawerV(false)
             self.backView.alpha = 0
        }) { (b) in
            if b == true{
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.isOpen = false
                callb()
            }
        }
    }
    
    //添加到window
    private func addWindow(){
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        for vc in appDelegate.window??.rootViewController?.children ?? []{
            if vc.classForCoder == EXDrawerVC.classForCoder(){
                return
            }
        }
        UIApplication.shared.keyWindow?.addSubview(self.view)

//        appDelegate.window??.rootViewController?.addChildViewController(self)
//        appDelegate.window??.rootViewController?.view.addSubview(self.view)
    }
}

public extension EXDrawerVC{
    
    //如果是view 用这个方法
    func addView(_ view : UIView){
        if isOpen {
            return
        }
        view.extUseAutoLayout()
        drawerV.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        addWindow()
        pushAnimation()
    }
    
    //如果是vc 用这个方法
    func addVC(_ vc : UIViewController){
        addChild(vc)
        addView(vc.view)
    }
    
}
