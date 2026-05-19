//
//  EXDrawerVC.swift
//  Chainup
//
//  Created by zewu wang on 2019/4/1.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

let dr_Width = 250 / 375 * SCREEN_WIDTH

class EXDrawerVC: BaseVC {
    
    typealias PullBlock = () -> ()
    var pullBlock : PullBlock?
    var isOpen:Bool = false
    
    //background
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.mask
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(pullAnimation))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    //Drawer background
    lazy var drawerV : UIView = {
        let view = UIView.init(frame: CGRect.init(x: -dr_Width, y: 0, width: dr_Width, height: SCREEN_HEIGHT))
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view.addSubViews([backView,drawerV])
        backView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        //The root controller of the navigation controller prohibits left sliding, otherwise left sliding may cause jamming
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
    
    //Set the position of the drawer
    private func makeDrawerV(_ push : Bool){
        if push == true{
            drawerV.frame = CGRect.init(x: 0, y: 0, width: dr_Width, height: SCREEN_HEIGHT)
        }else{
            drawerV.frame = CGRect.init(x: -dr_Width, y: 0, width: dr_Width, height: SCREEN_HEIGHT)
        }
    }
    
    //Launch Animation
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
    
    //Retract Animation
    @objc func pullAnimation(){
        if self.isOpen == false {return}
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
             self.makeDrawerV(false)
        }) { (b) in
            if b == true{
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                self.isOpen = false
                self.pullBlock?()
            }
        }
    }
    
    @objc func pullAnimationCallback(callb: @escaping ()->()) {
        if self.isOpen == false {return}
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
             self.makeDrawerV(false)
        }) { (b) in
            if b == true{
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                self.isOpen = false
                callb()
            }
        }
    }
    
    //Add to window
    private func addWindow(){
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        for vc in appDelegate.window??.rootViewController?.childViewControllers ?? []{
            if vc.classForCoder == EXDrawerVC.classForCoder(){
                return
            }
        }
        UIApplication.shared.keyWindow?.addSubview(self.view)

//        appDelegate.window??.rootViewController?.addChildViewController(self)
//        appDelegate.window??.rootViewController?.view.addSubview(self.view)
    }
}

extension EXDrawerVC{
    
    //If it's a view using this method
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
    
    //If it's VC using this method
    func addVC(_ vc : UIViewController){
        addChildViewController(vc)
        addView(vc.view)
    }
    
}

