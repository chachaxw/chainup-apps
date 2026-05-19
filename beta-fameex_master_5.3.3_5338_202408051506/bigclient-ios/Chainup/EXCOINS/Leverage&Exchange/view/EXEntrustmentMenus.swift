 //
 //  EXEntrustmentMenus.swift
 //  Chainup
 //
 //  Created by liuxuan on 2023/12/16.
 //  Copyright © 2023 Chainup. All rights reserved.
 //


 import UIKit
 import EXKit

 enum EXEntrustMenuAction {
     case mixCoinMap//Transaction pair screening
     case entrustmentType//Delegate Type
     case orderType//Buying and selling type
     case orderState//Order Status
     case none
 }

 class EXEntrustMenuItem:EXBaseModel {
     var title:String = ""
     var action:EXEntrustMenuAction = .none
     var paramKey:String = ""
     
    static func getMenuItems() ->[EXEntrustMenuItem] {
         let menuA = EXEntrustMenuItem.init()
         menuA.title = "common_action_allTradingPairs".localized()
         menuA.action = .mixCoinMap
         menuA.paramKey = "symbol"
         let menuB = EXEntrustMenuItem.init()
         menuB.title = "common_action_alltypes".localized()
         menuB.action = .orderType
         menuB.paramKey = "side"
         let menuC = EXEntrustMenuItem.init()
         menuC.title = "common_action_sendall".localized()
         menuC.action = .entrustmentType
         menuC.paramKey = "type"
         let menuD = EXEntrustMenuItem.init()
         menuD.title = "common_action_allstatus".localized()
         menuD.action = .orderState
         menuD.paramKey = "status"
         return [menuA,menuC,menuB,menuD]
     }

     static func getMenuIdxByAction(action :EXEntrustMenuAction) -> Int {
         let menus = EXEntrustMenuItem.getMenuItems()
         var menuIdx = 0
         for (idx,menu) in menus.enumerated() {
             if menu.action == action {
                 menuIdx = idx
                 break
             }
         }
         return menuIdx
     }
     
     
     static func getSheetValueActions(action:EXEntrustMenuAction) -> [String]{
         if action == .orderType {
             return ["","BUY","SELL"]
         }else if action == .orderState {
             return ["","2","4"]
         }else if action == .entrustmentType {
             return ["","1","2"]
         }
         return []
     }
     
     static  func getSheetTitleByActions(action:EXEntrustMenuAction) -> [String] {
         if action == .orderType {
             return ["common_action_alltypes".localized(),
                     "contract_action_buy".localized(),
                     "contract_action_sell".localized()]
         }else if action == .orderState {
             return ["common_action_allstatus".localized(),
                     "contract_text_orderComplete".localized(),
                     "contract_text_orderCancel".localized()]
         }else if action == .entrustmentType {
             return ["common_action_sendall".localized(),
                     "exchange_order_normal_entrusts".localized(),
                     "exchange_order_price_entrusts".localized()]
         }
         return []
     }
     
 }

 class EXEntrustmentMenus: UIView {
     
     typealias EntrustmentMenuAction = (EXEntrustMenuItem)->()
     var onMenuActionCallback:EntrustmentMenuAction?
     
     var titles:[EXEntrustMenuItem]
     var menuItems:[EXDirectionSelector] = []

     lazy var topSeperator:UIView = {
         let seperator = UIView()
         seperator.backgroundColor = .Ex.fill4
         return seperator
     }()
     
     lazy var container:UIStackView = {
         let stack = UIStackView.init()
         stack.axis = .horizontal
         stack.distribution = .fillEqually
         stack.spacing = 0.5
         return stack
     }()
     
     lazy var bottomSeperator:UIView = {
         let seperator = UIView()
         seperator.backgroundColor = .Ex.fill4
         return seperator
     }()
     
     required init(menus:[EXEntrustMenuItem]) {
         self.titles = menus
         super.init(frame: CGRect.zero)
         configMenu()
     }

     required init?(coder aDecoder: NSCoder) {
         self.titles = []
         super.init(coder: aDecoder)
         configMenu()
     }
     
     func configMenu() {
         if self.titles.count == 0 { return }
         self.addSubview(container)
         self.addSubview(topSeperator)
         self.addSubview(bottomSeperator)

         topSeperator.snp.makeConstraints { (make) in
             make.top.equalToSuperview()
             make.left.equalToSuperview()
             make.right.equalToSuperview()
             make.height.equalTo(0.5)
         }
         
         container.snp.makeConstraints { (make) in
             make.top.equalTo(topSeperator.snp.bottom)
             make.left.equalToSuperview()
             make.width.equalToSuperview()
             make.height.equalTo(35.5)
         }
         
         bottomSeperator.snp.makeConstraints { (make) in
             make.top.equalTo(container.snp.bottom)
             make.left.equalToSuperview()
             make.right.equalToSuperview()
             make.height.equalTo(0.5)
         }
         
         for (idx,title) in titles.enumerated(){
             let menuBtn = EXDirectionSelector()
             menuBtn.backgroundColor = .Ex.fill2
             menuBtn.semanticContentAttribute = .forceRightToLeft
             menuBtn.iconSize = .init(width: 10, height: 10)
             menuBtn.icon.image = EXKitBundle.image(named: "public_arrow_down")
             menuBtn.titleLabel.text = title.title
             menuBtn.titleLabel.font = .Ex.medium(12)
             menuBtn.titleLabel.textColor = .Ex.text2
             menuBtn.textAlignment = .center
             menuBtn.tag = idx

             menuBtn.addTarget(self, action: #selector(menuDidTap(_:)), for: .touchUpInside)
             menuBtn.contentInsets = .zero
             menuBtn.snp.makeConstraints { make in
                 make.width.equalTo(menuBtn.preferedSize.width)
             }
             menuBtn.contentAlignment = .center
             container.addArrangedSubview(menuBtn)
             self.menuItems.append(menuBtn)
         }

         if let lastItem = menuItems.last {
             lastItem.isHidden = true
         }
     }
     
     func showLastMenu() {
         if menuItems.count > 2 {
             let limitBtn = menuItems[1]
             limitBtn.isUserInteractionEnabled = true
             limitBtn.icon.isHidden = false
             limitBtn.iconSize = .init(width: 10, height: 10)
             limitBtn.icon.image = EXKitBundle.image(named: "public_arrow_down")
             let titleItem = EXEntrustMenuItem.getSheetTitleByActions(action: EXEntrustMenuAction.entrustmentType)[0]
             limitBtn.titleLabel.text = titleItem
             
         }
         if let lastItem = menuItems.last {
             UIView.animate(withDuration: 0.3) {
                 lastItem.isHidden = false
                 self.container.layoutIfNeeded()
             }
         }
     }
     
     func hideLastMenu() {
         if menuItems.count > 2 {
             let limitBtn = menuItems[1]
             limitBtn.isUserInteractionEnabled = false
             limitBtn.icon.image = EXKitBundle.image(named: "")
             let titleItem = EXEntrustMenuItem.getSheetTitleByActions(action: EXEntrustMenuAction.entrustmentType)[1]
             limitBtn.titleLabel.text = titleItem
  
         }
         if let lastItem = menuItems.last {
             UIView.animate(withDuration: 0.3) {
                 lastItem.isHidden = true
                 self.container.layoutIfNeeded()
             }
         }
     }

     @objc func menuDidTap(_ sender:EXDirectionSelector) {
         sender.setOn(true, animated: true)
         let model = self.titles[sender.tag]
         self.onMenuActionCallback?(model)
     }
     
     func updateMenuTitle(title:String,idx:Int) {
         if menuItems.count > idx {
             let btn = self.menuItems[idx]
             btn.titleLabel.text = title
         }
     }
     
 }



 


