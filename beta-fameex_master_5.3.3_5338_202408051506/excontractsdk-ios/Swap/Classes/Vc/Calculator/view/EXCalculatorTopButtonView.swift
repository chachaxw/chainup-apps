//
//  EXCalculatorTopButtonView.swift
//  Chainup
//
//  Created by cwd on 2022/11/14.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

typealias CalculatorBtnBlock = (_ type: EXSwapTransationViewShowType) -> ()
//MARK: 头部的开多 / 卖空 的头部 English: MARK: Head of long/short selling
class EXCalculatorTopButtonView: EXCOCustomBaseView {
    override class var viewHeight: CGFloat{
        return 50
    }
    override func setSubView() {
        configSubView()
    }
    var btnClick: CalculatorBtnBlock?
    var transactionShowType: EXSwapTransationViewShowType = .showOpen
    var btnArr = [UIButton]()
    //MARK: lazy
    lazy var orderBuyBtn:UIButton = {
        let btnBuy = UIButton.init(type: .custom)
        btnBuy.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btnBuy.setTitle("cp_overview_text13".ex_localized(), for: .normal)
        btnBuy.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btnBuy.setTitleColor(UIColor.white, for: .selected)
        let normalImage = UIImage.exs_themeImageNamed(imageName: "contract_openpositions")
        let selectedImage = UIImage.exs_themeImageNamed(imageName: "contract_openlong")
        let newNormalImage = normalImage.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 30),resizingMode: .stretch)
        let newSelectedImage = selectedImage.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 30),resizingMode: .stretch)
        btnBuy.setBackgroundImage(newNormalImage, for: .normal)
        btnBuy.setBackgroundImage(newSelectedImage, for: .selected)
        btnBuy.addTarget(self, action: #selector(onOrderActionChanged(_:)), for: .touchUpInside)
        btnBuy.isSelected = true
        return btnBuy
    }()
    lazy var orderSellBtn:UIButton = {
        let btnSell = UIButton.init(type: .custom)
        btnSell.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btnSell.setTitle("cp_overview_text14".ex_localized(), for: .normal)
        btnSell.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btnSell.setTitleColor(UIColor.white, for: .selected)
        btnSell.isSelected = false
        let normalImage = UIImage.exs_themeImageNamed(imageName: "contract_unwind")
        let selectedImage = UIImage.exs_themeImageNamed(imageName: "contract_sellshort")
        let newNormalImage = normalImage.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 30),resizingMode: .stretch)
        let newSelectedImage = selectedImage.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 30),resizingMode: .stretch)
        btnSell.setBackgroundImage(newNormalImage, for: .normal)
        btnSell.setBackgroundImage(newSelectedImage, for: .selected)
        btnSell.addTarget(self, action: #selector(onOrderActionChanged(_:)), for: .touchUpInside)
        return btnSell
    }()
}
extension EXCalculatorTopButtonView {
    
    @objc func onOrderActionChanged(_ sender:UIButton) {
        if sender.isSelected == true{
            return
        }
        for btn in btnArr {
            btn.isSelected = false
        }
        sender.isSelected = true
        
        
        if sender == orderBuyBtn {
            transactionShowType = .showOpen
        }else if sender == orderSellBtn {
            transactionShowType = .showClose
        }
        self.btnClick?(transactionShowType)
    }
    
    
    func configSubView(){
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(orderBuyBtn)
        self.addSubview(orderSellBtn)
        btnArr.append(orderBuyBtn)
        btnArr.append(orderSellBtn)
        let buyBtnHeight = 30
        orderBuyBtn.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.equalTo(16)
            make.height.equalTo(buyBtnHeight)
            make.right.equalTo(orderSellBtn.snp.left)
            make.width.equalTo(orderSellBtn.snp_width)
        }
        
        orderSellBtn.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(orderBuyBtn)
            make.left.equalTo(orderBuyBtn.snp.right)
            make.width.equalTo(orderSellBtn.snp_width)
        }
    }
    
    
}

