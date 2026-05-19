//
//  PopoverViewController.swift
//  EXKit_Example
//
//  Created by cwd on 2023/6/14.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EXKit
class PopoverViewController: UIViewController {
    let popbtn = EXButton()
    let popbtn1 = EXButton()
    let popbtn2 = EXButton()
    let popbtn3 = EXButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Ex.fill1
        
       
        let waring = EXNoticeBarView()
        waring.content = "After changing the password 48 hours limit gold After changing the password 48 hours limit gold After changing the password 48 hours limit gold"
        self.view.addSubview(waring)
        waring.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        popbtn.setTitle("pop 弹框操作", for: .normal)
        popbtn.addTarget(self, action: #selector(pop), for: .touchUpInside)
        self.view.addSubview(popbtn)
        popbtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.left.equalToSuperview().offset(50)
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        
//        let popbtn1 = EXButton()
        popbtn1.setTitle("引导0", for: .normal)
        popbtn1.addTarget(self, action: #selector(popGuide), for: .touchUpInside)
        self.view.addSubview(popbtn1)
        popbtn1.snp.makeConstraints { make in
            make.top.equalTo(popbtn.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        
//        let popbtn2 = EXButton()
        popbtn2.setTitle("引导1", for: .normal)
        self.view.addSubview(popbtn2)
        popbtn2.snp.makeConstraints { make in
            make.top.equalTo(popbtn1.snp.bottom).offset(30)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        popbtn3.setTitle("引导2", for: .normal)
        self.view.addSubview(popbtn3)
        popbtn3.snp.makeConstraints { make in
            make.top.equalTo(popbtn2.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(50)
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
    }
    
    @objc func pop(){
        
        let v = EXPopMenuView.shared
        let top = PopMenuItem()
        top.name = "置顶"
        top.type = .top
        
        let  delete = PopMenuItem()
        delete.name = "删除"
        delete.type = .delete
        v.pop(fromView: popbtn,acionItem: [top,delete]) { menu in
            print(menu.type)
        }
        v.dismissend = { 
            print("消失")
        }
        
        
        
    }
    @objc func popGuide(){
        
        var guides = [PopGuideItem]()
        
        let itemPop = PopGuideItem()
        itemPop.title = "More actions after long pressm More actions after long press More actions after long press"
        itemPop.subTitle = "i see"
        itemPop.maxWidth = 350
        itemPop.tilteFont = UIFont.ThemeFont.BodyBold
        itemPop.subtitleFont = UIFont.ThemeFont.SecondaryBold
        itemPop.popoverType = .up
        itemPop.formView = popbtn1
        guides.append(itemPop)
        
        
        let itemPop1 = PopGuideItem()
        itemPop1.title = "More actions after long press"
        itemPop1.subTitle = "i see"
        itemPop1.tilteFont = UIFont.ThemeFont.BodyBold
        itemPop1.subtitleFont = UIFont.ThemeFont.SecondaryBold
        itemPop1.popoverType = .down
        itemPop1.formView = popbtn2
        guides.append(itemPop1)
        
        let itemPop2 = PopGuideItem()
        itemPop2.title = "More actions after long press"
        itemPop2.subTitle = "i see"
        itemPop2.tilteFont = UIFont.ThemeFont.BodyBold
        itemPop2.subtitleFont = UIFont.ThemeFont.SecondaryBold
        itemPop2.popoverType = .down
        itemPop2.formView = popbtn3
        guides.append(itemPop2)
        
        let m = EXPopGuidManger.shared
        m.guideItems = guides
        m.strartPop()
        m.finshCallBack = { [weak self] in
            print("结束")
        }
    }

}
