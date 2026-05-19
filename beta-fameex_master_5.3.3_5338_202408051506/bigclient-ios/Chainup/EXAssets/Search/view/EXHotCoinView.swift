//
//  EXHotCoinView.swift
//  Chainup
//
//  Created by wangdong on 2023/11/2.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXHotCoinView: NibBaseView{
    
    @IBOutlet weak var titleLabel: CMLocalizedLabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var selectedIndex: ((Int) -> ())?
    class func getHeight(data:Int)->CGFloat{
        let topTitle:CGFloat = 15+21+15 //Title and spacing
        let lines = (data+2)/3 //Number of rows
         //Title+cell+cell spacing+bottom spacing 20
        return topTitle + CGFloat(30) * CGFloat(lines) + CGFloat(lines - 1) * 10 + 20
       
    }
    override func onCreate() {
        titleLabel.textColor = .Ex.text1
    }
    func insert(labels: Array<String>) {
        
        let lines: Int = Int(ceil(Double(labels.count) / 3.0))
                
        for line in 0..<lines {
                        
            let cell = EXHotCoinCell()
            
            cell.leftButton.extSetAddTarget(self, #selector(clickHiddenBtn(_:)))
            cell.middleButton.extSetAddTarget(self, #selector(clickHiddenBtn(_:)))
            cell.rightButton.extSetAddTarget(self, #selector(clickHiddenBtn(_:)))
            
            stackView.addArrangedSubview(cell)
            
            cell.snp.makeConstraints { (maker) in
                maker.height.equalTo(30)
            }
            
            let start = line * 3
            var end = line * 3 + 2
            
            if end >= labels.count {
                end = end - (lines * 3 - labels.count)
            }
            
            let slice = labels[start...end]
            
            cell.leftButton.tag = start
            cell.middleButton.tag = start + 1
            cell.rightButton.tag = start + 2
            
            cell.setData(Array(slice))
        }
    
    }
    
    @objc func clickHiddenBtn(_ btn : UIButton){
        selectedIndex?(btn.tag)
    }
}

