//
//  BaseVC.swift
//  AppProject
//
//  Created by zewu wang on 2023/7/31.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
//
public class EXSBaseVC: UIViewController {
    deinit{
//        //print("\(self) -deinit")
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle{
        if EXThemeManager.isNight() == true{
            return .lightContent
        }else{
            return .default
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    //
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ThemeView.bg 
        addConstraint()
        setDatas()
//        _ = LanguageBase.getSubjectAsobsever().subscribe({[weak self] (event) in
//            guard let mySelf = self else{return}
//            mySelf.ModifyLanguage()
//        })
    }
    //
    //MARK:收到修改文字的通知 English: MARK: Received notification to modify text
    @objc func ModifyLanguage(){
        
    }
    
    //MARK:设置数据 English: MARK: Set data
    public func setDatas(){
        
    }
    
    //MARK:添加约束 English: MARK: adding constraints
    public func addConstraint(){
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
    
}

//extension UIViewController {
//    func showLoading() {
//        view.showLoading1()
//    }
//
//    func dismissLoading() {
//        view.hideLoading1()
//    }
//}

//extension PrimitiveSequenceType where TraitType == SingleTrait {
//    public func autoShowLoadingOnController(context: UIViewController) -> Single<ElementType> {
//        return self.do(onSuccess: { _ in
//            DispatchQueue.main.async {
//                context.dismissLoading()
//            }
//        }, onError: { _ in
//            DispatchQueue.main.async {
//                context.dismissLoading()
//            }
//        }, onSubscribe: {
//            DispatchQueue.main.async {
//                context.showLoading()
//            }
//        }, onSubscribed: {
//
//        }) {
//            DispatchQueue.main.async {
//                context.dismissLoading()
//            }
//        }
//    }
//
//    func autoShowLoadingOnButton(button: EXSButton?) -> Single<ElementType> {
//        return self.do(onSuccess: { _ in
//            DispatchQueue.main.async {
//                button?.isUserInteractionEnabled = true
//                button?.hideLoading()
//            }
//        }, onError: { _ in
//            DispatchQueue.main.async {
//                button?.isUserInteractionEnabled = true
//                button?.hideLoading()
//            }
//        }, onSubscribe: {
//            DispatchQueue.main.async {
//                button?.isUserInteractionEnabled = false
//                button?.showLoading()
//            }
//        }, onSubscribed: {
//
//        }) {
//            DispatchQueue.main.async {
//                button?.isUserInteractionEnabled = true
//                button?.hideLoading()
//            }
//        }
//    }
//}

