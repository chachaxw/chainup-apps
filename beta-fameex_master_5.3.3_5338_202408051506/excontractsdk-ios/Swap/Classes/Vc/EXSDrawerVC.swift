//
//  EXDrawerVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import MapKit

let exs_dr_Width = 280 / 375 * EXSCREEN_WIDTH

class EXSDrawerVC: EXSBaseVC {
    var contentVc = EXDrawContainerVC()
    typealias PullBlock = () -> ()
    var pullBlock : PullBlock?
    var isOpen:Bool = false
    
    //背景 English: background
    lazy var backView : UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.mask
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(pullAnimation))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(pullAnimation))
        swipe.direction = .left
        view.addGestureRecognizer(swipe)
        return view
    }()
    
    //抽屉背景 English: Drawer background
    lazy var drawerV : UIView = {
        let view = UIView.init(frame: CGRect.init(x: -exs_dr_Width, y: 0, width: exs_dr_Width, height: EXS_SCREEN_HEIGHT))
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view.exs_addSubViews([backView,drawerV])
        backView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        //导航控制器根控制器禁止左滑 否则 左滑 易出现卡顿现象 English: The root controller of the navigation controller prohibits left sliding, otherwise left sliding may cause jamming phenomenon
        let screenPan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(rightSliderScreen))
        screenPan.edges = UIRectEdge.left
        self.view.addGestureRecognizer(screenPan)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
    }
    
    @objc open func rightSliderScreen(_ pan : UIScreenEdgePanGestureRecognizer){
        //do nothing
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置抽屉的位置 English: Set the position of the drawer
    private func makeDrawerV(_ push : Bool){
        if push == true{
            drawerV.frame = CGRect.init(x: 0, y: 0, width: exs_dr_Width, height: EXS_SCREEN_HEIGHT)
            contentVc.listContainerView.reloadData()
        }else{
            drawerV.frame = CGRect.init(x: -exs_dr_Width, y: 0, width: exs_dr_Width, height: EXS_SCREEN_HEIGHT)
            contentVc.vm.subCancel()
        }
    }
    
    //推出动画 English: Launch animation
    func pushAnimation(){
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
            self.makeDrawerV(true)
        }) { (b) in
            if b == true{
                self.isOpen = true
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    //收回动画 English: Retract animation
    @objc func pullAnimation(){
        if self.isOpen == false {return}
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
             self.makeDrawerV(false)
        }) { (b) in
            if b == true{
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.isOpen = false
                self.pullBlock?()
            }
        }
    }
    
    //添加到window English: Add to window
    private func addWindow(){
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        for vc in appDelegate.window??.rootViewController?.children ?? []{
            if vc.classForCoder == EXSDrawerVC.classForCoder(){
                return
            }
        }
        appDelegate.window??.rootViewController?.addChild(self)
        appDelegate.window??.rootViewController?.view.addSubview(self.view)
    }
}

extension EXSDrawerVC{
    
    //如果是view 用这个方法 English: If it's a view using this method
    func addView(_ view : UIView){
        if isOpen {
            return
        }
        view.ext_UseAutoLayout()
        drawerV.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        addWindow()
        pushAnimation()
    }
    
    //如果是vc 用这个方法 English: If VC uses this method
    func addVC(_ vc : UIViewController){
        addChild(vc)
        addView(vc.view)
    }
    
}

