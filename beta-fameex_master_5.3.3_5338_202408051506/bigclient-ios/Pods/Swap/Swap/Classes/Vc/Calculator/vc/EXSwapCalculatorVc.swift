//  EXSwapCalculatorVc.swift
//  Chainup
//
//  Created by ZYJ on 2023/6/7.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import JXPagingView
import JXSegmentedView
import EXKit
class EXSwapCalculatorVc: ContentBaseViewController {
    var viewModel : EXSwapDataViewModel = EXSwapDataViewModel()
    var vcTypes: [CalculatorVCType] = [.profirt,.forceClose,.close]
    var openMode: EXContractOpenMode = .isolated
    var forceVc = EXCalculatorBaseVc()
    lazy var contractMenuBtn : EXSNaviDrawerView = {
        let v = EXSNaviDrawerView()
        v.isFromKLine = false
        v.btnClick = { [weak self] in
            self?.coinBtnClick()
        }
        return v
    }()
    
   lazy var contractModeBtn: EXSDirectionButton = {
        let b = EXSDirectionButton()
        b.container.backgroundColor = UIColor.Ex.fill3
        b.arrowAnimator = false
        b.spaceBetweenImageAndTitle = 12
        b.paddingleftRight = 12
        b.alighment = .marginCenter
        b.titleLabel.font = .Ex.medium(14)
        b.addTarget(self, action: #selector(changeMode), for: .touchUpInside)
        b.isHidden = true
        return b
    }()
    
    override func setNavCustomV() {
        self.navtype = .non
        self.navCustomView.backView.addSubview(contractMenuBtn)
        contractMenuBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview() //(navCustomView.popBtn)
            make.height.equalTo(35)
            make.width.equalTo(160)
            make.left.equalToSuperview().offset(16)
        }
        self.navCustomView.backView.addSubview(contractModeBtn)
        contractModeBtn.text(content: self.openMode.describe)
        contractModeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(27)
            make.centerY.equalTo(contractMenuBtn)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.contractModeBtn.exs_roundCorners(corners: .allCorners, radius: 4)
        }
        
    }
    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubView()
        self.setDatasourceTitles(["cp_calculator_text2".ex_localized(), "cp_calculator_text4".ex_localized(), "cp_calculator_text3".ex_localized()])
        for type in self.vcTypes{
            let v = EXCalculatorBaseVc()
            v.vcType = type
            if type == .forceClose{
                forceVc = v
            }
            controllers.append(v)
        }
        if let item = viewModel.itemModel{
            refreshData(item: item)
        }
    }
    
    func configSubView(){
        segmentedView.snp.remakeConstraints { make in

            make.top.equalToSuperview() //.offset(28)
//            make.top.equalTo(contractMenuBtn.snp.bottom).offset(28)
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(44)
        }
        listContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(segmentedView.snp.bottom)
            make.bottom.equalToSuperview().offset(-(EX_TABBAR_BOTTOM))
        }
        linev.snp.remakeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    //Hide  buttons
    override func segmentedViewSelected(index: Int){
        super.segmentedViewSelected(index: index)
        let type = vcTypes[index]
        self.contractModeBtn.isHidden = !(type == .forceClose)
    }
    
}

//MARK: action
extension EXSwapCalculatorVc{
    
    //Update the opening mode of the contract
    
    @objc func changeMode(){
        let titles = EXContractOpenMode.allCases.map { item in
            return item.describe
        }
        let idx = titles.firstIndex(of: self.openMode.describe) ?? 0
        let sheet = EXActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let `self` = self else { return }
            self.openMode = EXContractOpenMode.allCases[idx]
            self.contractModeBtn.text(content: self.openMode.describe)
            self.forceVc.openMode = self.openMode
        }
        sheet.actionCancelCallback =  {[weak self]() in
            guard let mySelf = self else{return}
        }
        sheet.configButtonTitles(buttons: titles, selectedIdx: idx)
        EXAlert.showSheet(sheetView: sheet)
    }
   
    
    @objc func clickBtn(){
        self.coinBtnClick()
    }
    // 点击选择合约按钮 English: Click the Select Contract button
    @objc func coinBtnClick(){
        self.view.isUserInteractionEnabled = false
        let vc = EXSDrawerVC()
        let list = EXDrawContainerVC()
        list.vm.eventSubject.subscribe(onNext: {[weak self,weak vc] event in
            guard let mySelf = self else{return}
            switch event{
            case .selectFinsh(let item):
                vc?.pullAnimation()
                if let oldId = mySelf.viewModel.itemModel?.ex_contractInfo?.instrument_id, let newId = item.ex_contractInfo?.instrument_id{
                    if oldId == newId {
                        return
                    }
                }
                
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
    
    
    
    /// 更新币种 English: /Update Currency
    func refreshData(item :EXSwapItemModel){
        //Currency pair changes
        contractMenuBtn.titleLabel.text = item.ex_contractInfo?.showName() ?? ""
        viewModel.itemModel = item
        viewModel.fetchLadderInfo()
        viewModel.updateData = { [weak self] in
            guard let newSelf = self else{
                return
            }
            for vc in newSelf.controllers{
                if vc is EXCalculatorBaseVc{
                    let newV = vc as! EXCalculatorBaseVc
                    newV.viewModel = newSelf.viewModel
                }
            }
        }
    }
}

