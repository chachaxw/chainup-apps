//
//  EXContractPositionSheet.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/17.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

class EXContractPositionSheet: NibBaseView {

    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var containers: UIStackView!
    @IBOutlet var inputTextField: EXTextField!
    @IBOutlet var confirmBtn: EXButton!
    @IBOutlet var input: EXTextField!
    @IBOutlet var selectionTitleBar: EXSelectionTitleBar!
    @IBOutlet var positionNumberTitle: UILabel!
    @IBOutlet var assignedPositionTitle: UILabel!
    @IBOutlet var avaliablePositionTitle: UILabel!
    @IBOutlet var positonNumberValue: UILabel!
    @IBOutlet var assignedPositionValue: UILabel!
    @IBOutlet var avaliablePositionValue: UILabel!
    
    
    private var isIncreaseMargin:Bool = true
    private var changeVolume:String = ""
    
    typealias PositionVolumeCallback = (String,Bool)->()
    var onPositionCallback:PositionVolumeCallback?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    
    override func onCreate() {
        input.enableTitleModel = true
        input.input.keyboardType = UIKeyboardType.decimalPad
        cancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
        confirmBtn.setTitle("common_text_btnConfirm".localized(),for:.normal)
        cancelBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        selectionTitleBar.setSelected(atIdx: 0)
        selectionTitleBar.bindTitleBar(with: ["contract_action_increaseMargin".localized(),"contract_action_decreaseMargin".localized()])
        selectionTitleBar.titleBarCallback = {[weak self] tag in
            if tag == 0 {
                self?.increaseMargin()
            }else if tag == 1 {
                self?.decreaseMargin()
            }
        }
        increaseMargin()
        confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        
       input.input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .map({ text in
                return (text.count > 0)
            })
            .bind(to:confirmBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        input.input.rx.text.orEmpty.asObservable()
        .distinctUntilChanged()
            .subscribe(onNext: {[weak self] text in
                self?.changeVolume = text
            }).disposed(by: self.disposeBag)
        
        self.snp.makeConstraints { (make) in
            make.height.equalTo(334)
        }
    }
    
    @objc func confirmBtnAction() {
        onPositionCallback?(changeVolume,isIncreaseMargin)
        self.dismiss()
    }
    
    func increaseMargin() {
        isIncreaseMargin = true
        input.setTitle(title: "contract_text_increaseMarginVolume".localized())
        input.setPlaceHolder(placeHolder: "contract_text_increaseMarginVolume".localized())
    }
    
    func decreaseMargin() {
        isIncreaseMargin = false
        input.setTitle(title: "contract_text_decreaseMarginVolume".localized())
        input.setPlaceHolder(placeHolder: "contract_text_decreaseMarginVolume".localized())
    }
    
    func bindInfos(contractPositionNumber:String,assignedPosition:String,avaliablePosition:String,symbol:String) {
//        position_assigned,position_available,contract_text_positionNumber
        positionNumberTitle.text = "contract_text_positionNumber".localized() + "(\("contract_text_volumeUnit".localized()))"
        positonNumberValue.text = contractPositionNumber
        assignedPositionTitle.text = "contract_text_assignedMargin".localized() + "(\(symbol))"
        avaliablePositionTitle.text = "contract_text_availableMargin".localized() + "(\(symbol))"
        avaliablePositionValue.text = avaliablePosition
        assignedPositionValue.text = assignedPosition
        input.setExtraText(symbol)
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.dismiss()
    }
    
    func dismiss(){
        EXAlert.dismiss()
    }
}
