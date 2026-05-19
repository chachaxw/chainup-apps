//
//  HiDebugTextfieldVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class HiDebugTextfieldVc: UIViewController {
    @IBOutlet var selectionField: EXSelectionField!
    @IBOutlet var testA: EXTextField!
    
    override func viewDidLoad() {
        testA.setPlaceHolder(placeHolder: "")
        testA.hasError = true
        selectionField.hasError = true
        selectionField.setText(text: "")
        selectionField.textfieldDidTapBlock = {[weak self] in
            self?.selectionAction()
        }
    }
    
    func selectionAction() {
        let sheet = EXOldActionSheetView()
        sheet.configButtonTitles(buttons: ["按钮A","按钮B","按钮C","按钮D"],selectedIdx:3)
        sheet.actionIdxCallback = {[weak self] idx in
            print(idx)
            self?.selectionField.normalStyle()
        }
        sheet.actionCancelCallback = {[weak self] in
            self?.selectionField.normalStyle()
        }
        EXAlert.showSheet(sheetView:sheet)
    }
}

