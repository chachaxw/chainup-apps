//
//  EXNoviceTaskCell.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXNoviceTaskCell: EXBaseCell {
    
    var collectionRewardCallBack: ((EXTaskItemModel?) -> ())?
    var taskItem: EXTaskItemModel? {
        didSet{
            guard let taskItem = taskItem else { return }
            let logUrl = (EXTheme.current == .dark) ? taskItem.nightLogo :  taskItem.logo
            img.yy_setImage(with: URL(string: logUrl), placeholder: UIImage.themeImageNamed(imageName: "task_img"))
            amountLabel.text = taskItem.rewardAmount + " " + taskItem.rewardCoin
            amountLabel.titleResizeSize(topAndBottom: 8,leftRight: 8)
            typeLabel.text = taskItem.rewardTypeShow
            typeLabel.titleResizeSize(topAndBottom: 8,leftRight: 8)
            titleLabel.text = taskItem.taskName
            contentLabel.text = taskItem.taskInfo
            if let taskType = TaskType(rawValue: taskItem.taskType){
                self.type = taskType
            }
            timeLabel.text = taskItem.timeTitle
            if XUserDefault.isOffLine(){
                timeValueLabel.text  =  "--"
            }else{
                let interval = TimeInterval.init(taskItem.remindTime.bigDiv("1000")) ?? 0
                timeValueLabel.text  = DateTools.dateToString(interval)
            }
            btn1.isEnabled = taskItem.btnIsEnble
            btn1.setTitle(taskItem.actionBtnName, for: .normal)
            
        }
    }
    var type: TaskType = .novice {
        didSet{
            contentLabel.isHidden = type == .daily
            timerZone.isHidden = type == .daily
            if type == .daily {
                line.snp.remakeConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom).offset(24)
                    make.left.equalToSuperview().offset(16)
                    make.right.equalToSuperview().offset(-16)
                    make.height.equalTo(0.5)
                }
                
            }else{
                line.snp.remakeConstraints { make in
                    make.top.equalTo(contentLabel.snp.bottom).offset(24)
                    make.left.equalToSuperview().offset(16)
                    make.right.equalToSuperview().offset(-16)
                    make.height.equalTo(0.5)
                }
            }
            
            let btnTopMargin: CGFloat = type == .daily ? 24 : 16 + 35 + 13
            btnContainer.snp.updateConstraints { make in
                make.top.equalTo(line.snp.bottom).offset(btnTopMargin)
            }
        }
    }
    
    override func setUpView() {
        self.backgroundColor = .Ex.fill2
        self.line.backgroundColor = .clear
       
        self.contentView.addSubview(bgview)
        bgview.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        bgview.addSubViews([
            img,amountLabel,typeLabel,
            titleLabel,
            contentLabel,
            line,
            timerZone,
            btnContainer
        ])
        bgview.corneradius = 4
        bgview.layer.borderColor = UIColor.Ex.fill5.cgColor
        bgview.layer.borderWidth = 1
        //timeZone
        timerZone.addSubViews([timeLabel,timeValueLabel])
        timeLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.height.equalTo(16)
        }
        timeValueLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom)
            make.left.equalToSuperview()
        }
        //btnContainer
        
        btnContainer.addArrangedSubview(btn1)
     //   btnContainer.addArrangedSubview(btn2)
      
        
        
        //mainview
        img.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.width.height.equalTo(30)
        }
        typeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(img)
            make.width.height.equalTo(10)
        }
        amountLabel.snp.makeConstraints { make in
            make.right.equalTo(typeLabel.snp.left)
            make.width.height.equalTo(30)
            make.centerY.equalTo(img)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(img.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        timerZone.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(35)
        }
        let top:CGFloat = 16 + 35 + 13
        btnContainer.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(top)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  [weak self] in
            guard let `self` = self else { return }
            self.line.drawDashLine(lineLength: 4, lineSpacing: 4, lineColor: .Ex.fill5)
        }
    }
    
    
    
    
    
   
    
    
    //MARK: lazy
    let bgview = UIView()
    lazy var img : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    ///
    lazy var amountLabel: EXTagView = {
        let label = EXTagView(text:"", font: .Ex.medium(12), textColor: .white, alignment: NSTextAlignment.center)
        label.backgroundColor = .black
        label.corneradius = 2
        label.extUseAutoLayout()
        return label
    }()
    lazy var typeLabel: EXTagView = {
        let label = EXTagView(text:"", font: .Ex.medium(12), textColor: .Ex.text1, alignment: NSTextAlignment.center)
        label.backgroundColor = .Ex.fill3
        label.corneradius = 2
        label.extUseAutoLayout()
        return label
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(16), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.extUseAutoLayout()
        return label
    }()
    // noly novice show
    lazy var contentLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text2, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.extUseAutoLayout()
        return label
    }()
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill5
        return v
    }()
    //noly novice show
    lazy var timerZone: UIView = {
        let v = UIView()
        return v
    }()
    lazy var timeLabel: UILabel = {
        let label = UILabel(text:"", font:.Ex.medium(12), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.extUseAutoLayout()
        return label
    }()
    lazy var timeValueLabel: UILabel = {
        let label = UILabel(text:"", font:.Ex.medium(16), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.extUseAutoLayout()
        return label
    }()
    
    
    lazy var btnContainer: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.axis = .horizontal
        stack.alignment = .fill
        return stack
    }()
    
    lazy var btn1 : EXButton = {
        let btn = EXButton()
        btn.tag = 0
        btn.addTarget(self, action: #selector(clickBtn(btn:)), for: UIControl.Event.touchUpInside)
        btn.setTitleColor( .white, for: .normal)
        return btn
    }()
//    lazy var btn2 : EXButton = {
//        let btn = EXButton()
//        btn.tag = 1
//        btn.addTarget(self, action: #selector(clickBtn(btn:)), for: UIControl.Event.touchUpInside)
//        btn.setTitleColor( .white, for: .normal)
//        return btn
//    }()
    
    
    
}
extension EXNoviceTaskCell{
    
    @objc func clickBtn(btn: EXButton) {
        if XUserDefault.isOffLine(){
            BusinessTools.modalLoginVC()
            return
        }
        if taskItem?.taskStatus == .unclaimed { //go
            self.collectionRewardCallBack?(self.taskItem)
            return
        }
        
        if let category =  TaskCategory(rawValue: self.taskItem?.taskCategory ?? 0){
            var rounter = EXRouterActionKey.TransactionPage
            switch category{
            case .spot: //xianhuo
                break
            case .contract:
                rounter = EXRouterActionKey.ContractTransaction
            case .lever:
                EXNavigationHandler.sharedHandler.commandTradingCoin("", "leverBuy")
                return
            case .digitalCurrencyDeposits:
                rounter = .digitalCurrencyDeposits
                EXNavigationHandler.sharedHandler.commonJumpCommand(rounter.rawValue, "USDT")
                return
            }
            
            EXNavigationHandler.sharedHandler.commonJumpCommand(rounter.rawValue)
            
        }
    }
    
}
