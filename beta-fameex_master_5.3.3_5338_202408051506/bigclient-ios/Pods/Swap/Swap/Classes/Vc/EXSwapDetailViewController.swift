//
//  EXSwapDetailViewController.swift
//  Chainup
//
//  Created by ZYJ on 2023/6/11.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

let showLeverAndMarginVc = true
///合约信息详情页面 English: /Contract Information Details Page
class EXSwapDetailViewController: ContentBaseViewController {
    var segmentSelectedIndex: Int = 0
    //保证金币种 English: Guarantee coin type
    var depositCoinList = EXSwapPublicInfo.shared.marginCoinList
    var viewModel : EXSwapDataViewModel = EXSwapDataViewModel()
    let infoVC = EXContractInfoTableViewController()
    let leverAndMarginVc = EXLeverageAndMarginInfoVc()
    let fundsRateVC = EXSwapNewFundsRateViewController()
    let insurFundVc = EXSwapInsuranceFundViewController()
    
    lazy var contractMenuBtn : EXSNaviDrawerView = {
        let v = EXSNaviDrawerView()
        v.btnClick = { [weak self] in
            self?.coinBtnClick()
        }
        return v
    }()
    
    override func setNavCustomV() {
        self.navtype = .non
        self.navCustomView.backView.addSubview(contractMenuBtn)
        contractMenuBtn.snp.makeConstraints { (make) in
            //make.top.equalToSuperview().offset(35)
            make.centerY.equalToSuperview() //(navCustomView.popBtn)
            make.height.equalTo(35)
            make.width.equalTo(160)
            make.left.equalToSuperview().offset(16)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        infoVC.currentItemModel = viewModel.itemModel
        contractMenuBtn.titleLabel.text = viewModel.itemModel?.ex_contractInfo?.showName()
        
        
        var titles = ["cp_contract_info_text2".ex_localized(), "cp_overview_text26".ex_localized(), "cp_contract_info_text4".ex_localized()]
        
       // 合约参数 Contract_Parameter English: Contract parameters_ Parameter
        
        controllers.append(infoVC)
        controllers.append(fundsRateVC)
        controllers.append(insurFundVc)
        
        if showLeverAndMarginVc {
            titles.insert("LvrgnMg".ex_localized(), at: 1)
            controllers.insert(leverAndMarginVc, at: 1)
        }
        
        self.setDatasourceTitles(titles)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func segmentedViewSelected(index: Int) {
        //
        //print(" selected = \(index)")
        if index == segmentSelectedIndex{
            return
        }
        segmentSelectedIndex = index
        
        if showLeverAndMarginVc{
            if index == 0{
                infoVC.currentItemModel = viewModel.itemModel
            }else if index == 1 {
                leverAndMarginVc.viewModel = viewModel
            }else if index == 2 {
                fundsRateVC.viewModel = viewModel
            }else if index == 3 {
                insurFundVc.viewModel =  viewModel
            }
        }else{
            if index == 0{
                infoVC.currentItemModel = viewModel.itemModel
            }else if index == 1 {
                fundsRateVC.viewModel = viewModel
            }else if index == 2 {
                insurFundVc.viewModel =  viewModel
            }
        }
        if index == controllers.count - 1 {
            self.contractMenuBtn.line.isHidden = true
            self.contractMenuBtn.titleLabel.isHidden = true
            self.contractMenuBtn.chooseBtn.isHidden = true
        }else{
            self.contractMenuBtn.line.isHidden = false
            self.contractMenuBtn.titleLabel.isHidden = false
            self.contractMenuBtn.chooseBtn.isHidden = false
        }
    }
    
}

//MARK: action
extension EXSwapDetailViewController{
    
    // 点击选择合约按钮 English: Click the Select Contract button
    @objc func coinBtnClick(){
        self.view.isUserInteractionEnabled = false
        let vc = EXSDrawerVC()
        let list = EXDrawContainerVC()
//        list.fromKline =  true
        list.vm.eventSubject.subscribe(onNext: {[weak self,weak vc] event in
            guard let mySelf = self else{return}
            switch event{
            case .selectFinsh(let item):
                vc?.pullAnimation()
                mySelf.refreshData(item: item)
            default:
                break
            }
        }).disposed(by: disposeBag)
        vc.pullBlock = {[weak self] in
            self?.view.isUserInteractionEnabled = true
        }
        vc.contentVc = list
        vc.addVC(list)
    }
    
    
    func refreshData(item :EXSwapItemModel){
        contractMenuBtn.titleLabel.text = item.ex_contractInfo?.showName()
        viewModel.itemModel = item
        if showLeverAndMarginVc {
            if segmentSelectedIndex == 0 {
                infoVC.currentItemModel = viewModel.itemModel
            }else if segmentSelectedIndex == 1 {
                leverAndMarginVc.viewModel = viewModel
            }else if segmentSelectedIndex == 2 {
                fundsRateVC.viewModel = viewModel
            }else{
                insurFundVc.viewModel = viewModel
            }
        }else{
            if segmentSelectedIndex == 0 {
                infoVC.currentItemModel = viewModel.itemModel
            }else if segmentSelectedIndex == 1 {
                fundsRateVC.viewModel = viewModel
            }else{
                insurFundVc.viewModel = viewModel
            }
        }
        
       
    }
}

