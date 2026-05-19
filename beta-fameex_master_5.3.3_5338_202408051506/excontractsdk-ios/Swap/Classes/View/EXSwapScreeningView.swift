//
//  EXSwapScreeningView.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
public class EXSwapScreeningView: UIView {
    
    public var screeningValueChanged: ((Int, Int, Int) -> Void)?
    var swapNameValueChanged:(()->())?

    public var orderTypeArray: [String] = [] {
        didSet {
            self.orderTypeButton.text(content: self.orderTypeArray.first ?? "-")
            self.reloadBtn()
        }
    }

    var orderTypeIndex: Int {
        get {
            var idx = 0
            for i in 0..<self.orderTypeArray.count {
                if self.orderTypeArray[i] == self.orderTypeButton.titleLabel.text {
                    idx = i
                    break
                }
            }
            return idx
        }
    }
    lazy var orderTypeButton: EXSDirectionButton = {
        let button = EXSDirectionButton()
        button.alighment = .marginCenter
        button.spaceBetweenImageAndTitle = 12
        button.paddingleftRight = 12
        button.container.corneradius = 4
        button.container.backgroundColor = .Ex.special2
        button.titleLabel.font = UIFont.Ex.medium(14)
        button.text(content: "OpenOrder_text2".ex_localized())
        button.addTarget(self, action: #selector(clickSwapTypeButton), for: .touchUpInside)
        return button
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.Ex.fill2
        self.exs_addSubViews([orderTypeButton])
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func initLayout() {
        self.orderTypeButton.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.width.equalTo(64)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}


// MARK: - Click Events

extension EXSwapScreeningView {

    @objc func clickSwapTypeButton() {
        let sheet = EXActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let `self` = self else { return }
            self.orderTypeButton.titleLabel.text = self.orderTypeArray[idx]
            self.reloadBtn()
            self.orderTypeButton.checked(check: false)
            self.valueChanged()
        }
        sheet.actionCancelCallback = {[weak self]() in
            guard let mySelf = self else { return }
            mySelf.orderTypeButton.checked(check: false)
        }
        sheet.configButtonTitles(buttons: self.orderTypeArray, selectedIdx: self.orderTypeIndex)
        EXAlert.showSheet(sheetView: sheet)
    }
    func reloadBtn(){
        let width = self.orderTypeButton.updateSubView()
        self.orderTypeButton.snp.remakeConstraints { (make) in
            make.height.equalTo(24)
            make.width.equalTo(width)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    private func valueChanged() {
        guard let screeningValueChanged = screeningValueChanged else {
            return
        }
        screeningValueChanged(0, 0, self.orderTypeIndex)
    }
    private func swapNameValueHasChanged() {
        swapNameValueChanged?()
    }
}

