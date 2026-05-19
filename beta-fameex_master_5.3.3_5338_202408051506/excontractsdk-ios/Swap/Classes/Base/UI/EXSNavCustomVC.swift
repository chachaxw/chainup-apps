//
//  NavCustomVC.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

public enum EXSNavType {
    case non
    case normal//ordinary
    case list//form 
    case listtitle//Form title
    case notitle//No title
    case nopopback//No return button
}

public class EXSNavCustomVC: EXSBaseVC, UIGestureRecognizerDelegate {
    
    var lastVC = false
    {
        didSet{
            navCustomView.backgroundColor = UIColor.ThemeView.bg
        }
    }
    
    var navtype = EXSNavType.normal
    {
        didSet{
            switch navtype {
            case .non:
                navCustomView.popBtn.isHidden = true
                navCustomView.middleTitle.isHidden = true
            case .list:
                navCustomView.snp.remakeConstraints { (make) in
                    make.top.left.right.equalTo(self.view)
                    make.height.equalTo(EX_NAV_SCREEN_HEIGHT + 62)
                }
                navCustomView.middleTitle.snp.remakeConstraints { (make) in
                    make.top.equalTo(navCustomView.popBtn.snp.bottom).offset(24)
                    make.height.equalTo(40)
                    make.left.equalToSuperview().offset(15)
                    make.width.lessThanOrEqualTo(EXSCREEN_WIDTH - 100)
                }
                navCustomView.middleTitle.font = UIFont.ThemeFont.H1Bold
            case .listtitle:
                navCustomView.middleTitle.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()//(navCustomView.popBtn)
                    make.height.equalTo(33)
                    make.centerX.equalToSuperview()
                    make.width.lessThanOrEqualTo(EXSCREEN_WIDTH - 100)
                }
                navCustomView.snp.remakeConstraints { (make) in
                    make.top.left.right.equalTo(self.view)
                    make.height.equalTo(EX_NAV_SCREEN_HEIGHT)
                }
                navCustomView.middleTitle.font = UIFont.ThemeFont.H3Bold
            case .notitle:
                self.navCustomView.middleTitle.isHidden = true
            case .nopopback:
                navCustomView.middleTitle.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()// (navCustomView.popBtn)
                    make.height.equalTo(25)
                    make.left.equalToSuperview().offset(15)
                    make.width.lessThanOrEqualTo(EXSCREEN_WIDTH - 100)
                }
                self.navCustomView.popBtn.isHidden = true
            default:
                break
            }
        }
    }
    
    var xscrollView = UIScrollView()
    {
        didSet{
//            xscrollView.rx.contentOffset.subscribe(onNext: { (point) in
//                //do something
//                let y = point.y
//                if self.navtype == .list{
//                    if y > 0{
//                        self.navtype = .listtitle
//                    }
//                }else if self.navtype == .listtitle{
//                    if y < 0{
//                        self.navtype = .list
//                    }
//                }
//            }).disposed(by: exs_disposeBag)
//            self.navtype = .list
        }
    }
    
    //Top navigation bar
    lazy var navCustomView : EXSNavCustomView = {
        let view = EXSNavCustomView()
        view.ext_UseAutoLayout()
        view.clickPopBtnBlock = {[weak self]() in
            guard let mySelf = self else{return}
            mySelf.navBack()
        }
        return view
    }()
    
    //Unified view
    lazy var contentView : UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    //Empty Page
//    lazy var voidView : EmptyPageView = {
//        let view = EmptyPageView()
//        view.ext_UseAutoLayout()
//        view.isHidden = true
//        return view
//    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setNavCustomV()
        // Do any additional setup after loading the view.
        contentView.backgroundColor = UIColor.ThemeView.bg
        setNavLeft()
    }
    
    func setNavLeft(){
        if (self.navigationController != nil && (self.navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)))!) {
            self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        XHUDManager.sharedInstance.dismissWithDelay {
//
//        }
    }
    
    public override func addConstraint() {
        super.addConstraint()
        view.exs_addSubViews([contentView,navCustomView])
//        contentView.addSubview(voidView)
        navCustomView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.height.equalTo(EX_NAV_SCREEN_HEIGHT)
        }
//        bottomLine.snp.makeConstraints { (make) in
//            make.bottom.equalTo(navCustomView)
//            make.height.equalTo(0.5)
//            make.left.right.equalTo(self.view)
//        }
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(navCustomView.snp.bottom)
            make.bottom.left.right.equalTo(self.view)
        }
//        voidView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer{
            if let count = self.navigationController?.viewControllers.count , count < 2 || self.navigationController?.visibleViewController == self.navigationController?.viewControllers[0]{
                return false
            }
        }
        return true
    }
    
    public func tobecomeFirstResponder(){
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(setEndEditing))
        self.contentView.addGestureRecognizer(tap)
    }
    
    open func forbidMoveFromScreenLeft(){
        //The root controller of the navigation controller prohibits left sliding, otherwise left sliding may cause jamming
        let screenPan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(rightSliderScreen))
        screenPan.edges = UIRectEdge.left
        self.view.addGestureRecognizer(screenPan)
        
    }
    
    @objc open func rightSliderScreen(_ pan : UIScreenEdgePanGestureRecognizer){
        //do nothing
    }
    
    //End Editing
    @objc func setEndEditing(){
        self.contentView.endEditing(true)
    }
    
    @objc public func setNavCustomV(){
        
    }
    //todo
//    public func setVoidViewHidden(_ hidden : Bool){
//        voidView.isHidden = hidden
//    }
    
    //MARK: Set title
    public func setTitle(_ title : String , color : UIColor = UIColor.ThemeLabel.colorLite , font : CGFloat = 18){
        navCustomView.middleTitle.text = title
    }
    
    //MARK: Set whether to display navbar lines and whether to display lines
    public func showNavBar(_ showNav : Bool = true){
        navCustomView.isHidden = !showNav
//        bottomLine.isHidden = !showNavBottomLine
    }
    
    //MARK: Set the button on the right
    public func setRightModule(_ views : [UIView]){
        navCustomView.setRightModule(views)
    }
    
    //MARK: Set the button on the left
    public func setLeftModule(_ views : [UIView] , _ showPopBtn : Bool = true){
        navCustomView.setLeftModule(views,showPopBtn)
    }
    
    //MARK: Reset colors
    public func reloadNavbackgroundColor(){
        //TODO: Color
        navCustomView.backgroundColor = UIColor.white
    }
    
    //MARK: Location of custom contentview
    public func contentViewBottom(_ bottom : CGFloat = 0){
        contentView.snp.updateConstraints { (make) in
            make.bottom.equalTo(view).offset(-bottom)
        }
    }
    //todo
    func navBack(){
        self.ex_popBack()
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func ex_popBack(_ animated : Bool = true, _ backToRoot:Bool = false ){
        if let vcs = self.navigationController?.viewControllers ,  vcs.count > 1 {
            if backToRoot {
                self.navigationController?.popToRootViewController(animated: animated)
            }else {
                self.navigationController!.popViewController(animated: animated)
            }
        } else {
            self.dismiss(animated: animated, completion: nil)
        }
    }
}

extension EXSNavCustomVC : UIScrollViewDelegate{
    
}

