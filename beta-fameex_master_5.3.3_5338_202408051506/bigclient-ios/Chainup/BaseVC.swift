//
//  BaseVC.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import SwiftEventBus
import EXKit
import Swap
class BaseVC: UIViewController {
    
    private let feedbackGenerator: Any? = {
        if #available(iOS 10.0, *) {
            let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    func light() {
        if #available(iOS 10.0, *), let generator = feedbackGenerator as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
    }
    
    var emptyNetworkView = EXEmptyNetworkView()
//    lazy var emptyNetworkView : EXEmptyNetworkView = {
//        var view = EXEmptyNetworkView()
//        view.refreshBtn.addTarget(self, action: #selector(refreshNetAction), for: .touchUpInside)
//        return view
//    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        if EXThemeManager.isNight() == true{
            return .lightContent
        }else{
            return .default
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Ex.fill2
        handleApplicationNotifi()
        addConstraint()
        setDatas()
        _ = LanguageBase.getSubjectAsobsever().subscribe({[weak self] (event) in
            guard let mySelf = self else{return}
            mySelf.ModifyLanguage()
        })
        creatNoticationCenter()
    }
    
    @objc func handleApplicationNotifi() {
        _ = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.userGoHomeScreen(false)
            })
        
        _ = NotificationCenter.default.rx
            .notification(UIApplication.willResignActiveNotification)
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.userGoHomeScreen(true)
            })
    }
    
    func userGoHomeScreen(_ to:Bool) {
        
    }
    //
    //MARK: Received notification to modify text
    @objc func ModifyLanguage(){
        
    }
    
    //MARK: Set data
    public func setDatas(){
        
    }
    
    //MARK: adding constraints
    public func addConstraint(){
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func defineCurrentVcIsTopVc() -> Bool {
        guard let top = AppService.topViewController() else {return false }
        if top == self  {
            return true
        }else {
            return false
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
//Network anomaly
extension BaseVC {
    func creatNoticationCenter(){
        SwiftEventBus.onMainThread(self, name: EXReachabilityKey.onNetworkConnected) {[weak self] (result) in
            self?.hiddenNonetWork()
        }
        SwiftEventBus.onMainThread(self, name: EXReachabilityKey.onNetworkLostConnection) {[weak self] (result) in
            self?.showNodataView()
        }
    }
    
    func showNodataView(){
        let window = UIApplication.shared.keyWindow;
        
        //Prevent duplicate addition of pages without a network
        if let window = window {
            if window.subviews.last?.isKind(of: EXEmptyNetworkView.self) ?? false{
                return;
            }
            
          
            var view = EXEmptyNetworkView()
            view.refreshBtn.addTarget(self, action: #selector(refreshNetAction), for: .touchUpInside)
            self.emptyNetworkView = view
            window.addSubview(self.emptyNetworkView)
            self.emptyNetworkView.snp.makeConstraints { (make) in
                make.top.equalTo(window.snp.top).offset(0);
                make.size.equalTo(UIScreen.main.bounds.size);
                make.centerX.equalTo(window.snp.centerX);
            }
        }
    }
    func hiddenNonetWork(){
        self.emptyNetworkView.removeFromSuperview()
    }
    
    @objc func refreshNetAction(){
        if EXNetworkReachabilityManager.sharedManager.netWorkIsOn(){
            self.hiddenNonetWork()
        }
    }
}

extension UIViewController {
    func showLoading() {
        view.showLoading1()
    }
    
    func dismissLoading() {
        view.hideLoading1()
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait {
    public func autoShowLoadingOnController(context: UIViewController) -> Single<Element> {
        return self.do(onSuccess: { _ in
            DispatchQueue.main.async {
                context.dismissLoading()
            }
        }, onError: { _ in
            DispatchQueue.main.async {
                context.dismissLoading()
            }
        }, onSubscribe: {
            DispatchQueue.main.async {
                context.showLoading()
            }
        }, onSubscribed: {
            
        }) {
            DispatchQueue.main.async {
                context.dismissLoading()
            }
        }
    }
    
    func autoShowLoadingOnButton(button: EXButton?) -> Single<Element> {
        return self.do(onSuccess: { _ in
            DispatchQueue.main.async {
                button?.isUserInteractionEnabled = true
                button?.hideLoading()
            }
        }, onError: { _ in
            DispatchQueue.main.async {
                button?.isUserInteractionEnabled = true
                button?.hideLoading()
            }
        }, onSubscribe: {
            DispatchQueue.main.async {
                button?.isUserInteractionEnabled = false
                button?.showLoading()
            }
        }, onSubscribed: {
            
        }) {
            DispatchQueue.main.async {
                button?.isUserInteractionEnabled = true
                button?.hideLoading()
            }
        }
    }
}


