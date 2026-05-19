//
//  EXOTCManagerVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//Otc Advertising management page

import UIKit
import RxSwift
import EXKit 

class EXOTCManagerVC: NavCustomVC ,EXEmptyDataSetable{
    
    lazy var mainView : EXOTCManagerView = {
        let view = EXOTCManagerView()
        view.extUseAutoLayout()
        return view
    }()
    
    var hasPaymentType:Bool = false //Check if there are any open payment methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.contentView.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.xscrollView = mainView.tableView
        self.exEmptyDataSet(mainView.tableView)
    }
    
    override func setNavCustomV() {
        
        let advertisingBtn = UIButton()
        advertisingBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
        advertisingBtn.setTitle("otc_publish_advertise".localized(), for: UIControl.State.normal)
        advertisingBtn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        advertisingBtn.extSetAddTarget(self, #selector(releaseAd))
        self.setTitle(LanguageTools.getString(key: "my_ads".localized()))
        navCustomView.addSubview(advertisingBtn)
        advertisingBtn.snp.makeConstraints { (make) in
            make.right.equalTo(navCustomView).offset(-15)
            make.width.lessThanOrEqualTo(200)
            make.centerY.equalTo(self.navCustomView.popBtn)
            make.height.equalTo(14)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkPayment()
    }
    
    func checkPayment(){
        otcApi.hideAutoLoading()
        otcApi.rx.request(.paymentFind(isOpen: "1"))
            .MJObjectMap(CommonAryModel.self,false)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.handelUserPayments(model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    func handelUserPayments(_ model:CommonAryModel){
        hasPaymentType = model.dictAry.count > 0
    }
    
    //Advertising
    @objc func releaseAd(){
        //1. Determine nickname real name authentication Google binding
        //2. Determine the fund password payment method
        if EXOTCSafetyCheckVm.manager.checkOTCBasicRequire(self) && EXOTCSafetyCheckVm.manager.checkOTCSafeRequire(self,hasPayment:hasPaymentType){
            self.wantredDetailCheck()
        }
    }
    
    //Verification before advertising
    func wantredDetailCheck(){
        otcApi.rx.request(OTCAPIEndPoint.wantedDetailCheck).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: {[weak self] (model) in
            let vc = EXPublishAdvertiseMarkVc.init(nibName: "EXPublishAdvertiseMarkVc", bundle: nil)
            vc.block = {(type,id , isSell) in
                let sellType = self?.mainView.type == "sell"
                if type == .publisAdvertise && sellType == isSell{
                    self?.mainView.loadHeadDatas()
                }
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }) { (error) in
            
        }.disposed(by: disposeBag)
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

