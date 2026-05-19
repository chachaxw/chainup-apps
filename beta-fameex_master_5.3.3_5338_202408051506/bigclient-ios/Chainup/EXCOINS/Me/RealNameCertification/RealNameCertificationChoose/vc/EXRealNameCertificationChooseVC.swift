//
//  EXRealNameCertificationChooseVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXRealNameCertificationChooseVC: NavCustomVC {

    lazy var mainView : EXRealNameCertificationChooseView = {
        let view = EXRealNameCertificationChooseView()
        view.extUseAutoLayout()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        NotificationCenter.default.rx.notification(.init("RealNameTwoNotification"))
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
            guard let self else { return }
            self.realNameTwoNotification()
            
        }).disposed(by: disposeBag)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Only displayed if the background switch is turned on
        mainView.getLanguage()
    }
    
    @objc func realNameTwoNotification(){
        self.navigationController?.popViewController(animated: false)
        self.navigationController?.popViewController(animated: false)
        DispatchQueue.main.async {
            guard let appDelegate  = UIApplication.shared.delegate else {
            return
            }
            if appDelegate.window != nil {
                let vc = EXRealNameThreeVC()
                EXAlert.showVc(controller: vc,ratio: 0.9)
            }
        }
    }
    
    override func setNavCustomV() {
        super.setNavCustomV()
        self.navtype = .listtitle
        self.setTitle("kyc_page_name".localized(), font: .Ex.medium(18))
      
        self.lastVC = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

