//
//  EXWarninglightsView.swift
//  Swap
//
//  Created by cwd on 2023/9/26.
//

import UIKit
import EXKit

class EXWarninglightsView: EXCOCustomBaseView {

    var lightsColors: [UIColor] = [.Ex.rise1,.Ex.rise1,.Ex.line4,.Ex.fall1,.Ex.fall1]
    
    var number: Int = 0 {
        didSet{
            for(index,v) in self.containView.arrangedSubviews.enumerated(){
                v.backgroundColor = .Ex.special4 //reset color
                if index < number {
                    v.backgroundColor = lightsColors[index]
                }
            }
        }
    }
    override func setSubView() {
        self.addSubview(containView)
        containView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        for i in 0..<5 {
            let v = UIView()
            v.backgroundColor = .Ex.special4
            containView.addArrangedSubview(v)
            v.snp.makeConstraints { make in
                make.width.equalTo(2)
            }
        }
    }
    lazy var containView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.spacing = 2
        stack.axis = .horizontal
        return stack
    }()
}
