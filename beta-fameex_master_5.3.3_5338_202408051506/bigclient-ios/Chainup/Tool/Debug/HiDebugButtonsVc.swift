//
//  HiDebugButtonsVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class HiDebugButtonsVc: UIViewController {

    @IBOutlet var highlightBtn: EXButton!
    @IBOutlet var upColorBtn: EXButton!
    @IBOutlet var downColorBtn: EXButton!
    @IBOutlet var disableBtn: EXButton!
    @IBOutlet var borderBtn: EXButton!
    @IBOutlet var directionBtn: EXDirectionButton!
    @IBOutlet var doubleTriangleBtn: EXDirectionButton!
    @IBOutlet var textBtn: EXTextButton!
    
    @IBOutlet var checkButton: EXCheckBox!
    override func viewDidLoad() {
        super.viewDidLoad()

        highlightBtn.color = UIColor.ThemeLabel.colorHighlight
        highlightBtn.highlightedColor = UIColor.ThemeLabel.colorHighlight.overlayWhite()
        
        upColorBtn.color = UIColor.ThemekLine.up
        upColorBtn.highlightedColor = UIColor.ThemekLine.up.overlayWhite()
        
        downColorBtn.color = UIColor.ThemekLine.down
        downColorBtn.highlightedColor = UIColor.ThemekLine.down.overlayWhite()
        
        disableBtn.disabledColor = UIColor.ThemeBtn.disable
        disableBtn.isEnabled = false
        // Do any additional setup after loading the view.
        borderBtn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        borderBtn.layer.cornerRadius = 1.5
        borderBtn.layer.borderColor = UIColor.ThemeView.border.cgColor
        borderBtn.layer.borderWidth = 1
        
        borderBtn.color = UIColor.clear
        borderBtn.highlightedColor = UIColor.clear.add(overlay:UIColor.ThemeView.bgTab.withAlphaComponent(0.5))
        
        textBtn.color = UIColor.ThemeView.bgTab
        
        
        checkButton.text(content: "")
        directionBtn.text(content:"sldkjfsldkfjsldkfjsdljkf")
        directionBtn.setAlighment(margin: .marginLeft)
        doubleTriangleBtn.text(content: "")
        doubleTriangleBtn.doubleTriangleStyle = true
        doubleTriangleBtn.setAlighment(margin: .marginRight)
        highlightBtn.setTitleColor(.white, for: .normal)
        highlightBtn.showLoading()

    }
    
    @IBAction func testRestart(_ sender: Any) {
        highlightBtn.showLoading()
        EXRouterHandler.shared.handleSchemeUrl("chainup://home/market?name=ETF")

    }
    
    @IBAction func actionTest(_ sender: Any) {
        EXRouterHandler.shared.handleSchemeUrl("chainup://home/slContract/detail?contractId=1")
        highlightBtn.hideLoading()
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

