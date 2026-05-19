//
//  EXAssetsPieChartAlert.swift
//  Chainup
//
//  Created by wangdong on 2023/9/9.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import PieCharts
import EXKit
class EXAssetsPieChartData {
    
    var title: String
    var value: Double
    var colorHexString: String
    var valueString: String {
        let b = "\(value)"
        let c = b.bigMul("100")
        let d = c.formatAmountUseDecimal("2") + "%"
        return d
    }
    init(title: String, value: Double, colorHexString: String = "") {
        self.title = title
        self.value = value
        self.colorHexString = colorHexString
    }
}

class EXAssetsPieChartAlert: NibBaseView {

    @IBOutlet weak var pieChart: PieChart!
    @IBOutlet weak var actionItemsStackView: UIStackView!
    var actionCollection: Array<EXAssetsPieChartActionView> = []
    var selectedIndex: Int?
    var data: Array<EXAssetsPieChartData> = []
    
    @IBOutlet weak var pieChartTopLabel: UILabel!
    @IBOutlet weak var pieChartBottomLabel: UILabel!
    
    override func onCreate() {
        pieChart.delegate = self
        pieChart.strokeColor = UIColor.ThemeView.alertBg
    }
    
    func setData(_ data: Array<EXAssetsPieChartData>) {
        
        self.data = data
        
        var pieSliceModel: Array<PieSliceModel> = []
        
        let line = Int(ceil(Double(data.count) / 2.0))
        
        for _ in 0..<line {
            createSection()
        }
        
        
        for i in 0..<data.count {
            
            let d = data[i]
            
            var value = d.value
            
            if value <= 0.005 {
                value = 0.005 * 2
            } else if (value > 0.005 && value < 0.01) {
                value = 0.01
            } else {}
            
            let model = PieSliceModel(value: value, color: UIColor.extColorWithHex(d.colorHexString))
            
            pieSliceModel.append(model)
            
            let action = actionCollection[i]
            action.mainView.isHidden = false
        
            action.didTapAction = { [weak action, weak self] in
                guard let weakAction = action, let self = `self` else { return }
                self.resetSelect(except: weakAction)
                weakAction.selected = !weakAction.selected
                self.pieChart.setSelectedIndex(index: i, selected: weakAction.selected)
            }
             
            action.colorView.backgroundColor = UIColor.extColorWithHex(d.colorHexString)
            action.leftLabel.text = d.title
            action.rightLabel.text = d.valueString
        }
        
        pieChart.models = pieSliceModel
        
        self.pieChart.setSelectedIndex(index: 0, selected: true)
    }
    
    func resetSelect(except: EXAssetsPieChartActionView?) {
        for action in actionCollection {
            if let exceptAction = except, exceptAction == action  {
                continue
            }
            action.selected = false
        }
    }
    
    func createSection() {
        let section = UIView.init(frame: CGRect.zero)
         let item1 = EXAssetsPieChartActionView()
         let item2 = EXAssetsPieChartActionView()
         
         section.addSubview(item1)
         section.addSubview(item2)
         
         actionItemsStackView.addArrangedSubview(section)
         
         item1.snp.makeConstraints { (maker) in
            maker.top.bottom.left.equalToSuperview()
            maker.height.equalTo(28.0)
            maker.right.equalTo(item2.snp.left).offset(-15.0)
         }
         
         item2.snp.makeConstraints { (maker) in
             maker.top.bottom.right.equalToSuperview()
             maker.height.equalTo(item1)
             maker.width.equalTo(item1)
         }
        
        item1.mainView.isHidden = true
        item2.mainView.isHidden = true
        
        actionCollection.append(contentsOf: [item1, item2])
    }
    
    @IBAction func onCloseAction(_ sender: Any) {
        EXAlert.dismiss()
    }
}

extension EXAssetsPieChartAlert: PieChartDelegate {
    func onSelected(slice: PieSlice, selected: Bool) {

        
        if selectedIndex == slice.data.id {
            selectedIndex = nil
        }
        else {
            
            if selectedIndex != nil {
                let slice = pieChart.slices[selectedIndex!]
                slice.view.selected = false
            }
            
            if selected {
                selectedIndex = slice.data.id
            }
        }
 
        
        let index = slice.data.id
        let action = actionCollection[index]
        action.selected = selected
        
        if selected {
            let dataValue = data[index]
            pieChartTopLabel.textColor = UIColor.extColorWithHex(dataValue.colorHexString)
            pieChartTopLabel.text = dataValue.title
            pieChartBottomLabel.text = dataValue.valueString;
//            String.init(format: "%.2f", dataValue.value) + "%"
        }
        else {
            pieChartTopLabel.text = ""
            pieChartBottomLabel.text = ""
        }
    }
}
