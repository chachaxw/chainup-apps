//
//  ButtonViewController.swift
//  EXKit_Example
//
//  Created by 尤彬 on 2023/6/14.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EXKit

class ButtonViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .Ex.fill1
        
        // Do any additional setup after loading the view.
        createUI()
    }
    
    func createUI() {
        test()
        
        testSwitch()
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


extension ButtonViewController {
    
    func test() {
        promptLabel()
        baseButton()
    }
    
    func promptLabel() {

        let label = EXInsetLabel()
        label.edgeInset = .init(top: 10, left: 16, bottom: 10, right: 16)
        label.font = .Ex.regular(12)
        label.textColor = .Ex.text1
        label.numberOfLines   = 0
        label.text = "点击\"basic\"按钮执行选中状态切换\n点击\"enable\"执行\"basic\"按钮的使能状态切换\n点击\"change style\"执行\"basic\"按钮的选中样式切换"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(128)
            make.left.right.equalToSuperview()
        }
    }
    
    func baseButton() {
        let container = UIView()
        
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
      
        
        var selectStyle = EXButtonStyles.up
        
        let baseBtn = EXButton(type: .custom)
        baseBtn.selectStyle = selectStyle
        baseBtn.setFont(.Ex.Harmony(size: 12, weight: .medium))
        baseBtn.setTitle("basic", for: .normal)
        container.addSubview(baseBtn)
        baseBtn.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        let enabledBtn = EXButton(type: .custom)
        enabledBtn.setFont(.Ex.Harmony(size: 12, weight: .medium))
        enabledBtn.setTitle("enable", for: .normal)
        container.addSubview(enabledBtn)
        enabledBtn.snp.makeConstraints { make in
            make.left.equalTo(baseBtn.snp.right).offset(8)
            make.top.bottom.equalToSuperview()
        }
        
        let styleBtn = EXButton(type: .custom)
        styleBtn.setFont(.Ex.Harmony(size: 12, weight: .medium))
        styleBtn.setTitle("change style", for: .normal)
        container.addSubview(styleBtn)
        styleBtn.snp.makeConstraints { make in
            make.left.equalTo(enabledBtn.snp.right).offset(8)
            make.right.equalToSuperview()
            make.centerY.height.width.equalTo(enabledBtn)
        }
        
        baseBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { _ in
            baseBtn.isSelected = !baseBtn.isSelected
        }).disposed(by: self.disposeBag)
        
        enabledBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { _ in
            baseBtn.isEnabled = !baseBtn.isEnabled
            enabledBtn.setTitle(baseBtn.isEnabled ? "enable" : "disabled", for: .normal)
        }).disposed(by: self.disposeBag)
        
        styleBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: { _ in
            selectStyle.next()
            baseBtn.selectStyle = selectStyle
        }).disposed(by: self.disposeBag)
    }
    
    
    
    
    func testSwitch() {
    
        let block = { (value:Bool) in
            print("switch state updated ----> \(value)")
        }
        
        let v = EXSwitchV6()
        v.isOn = true
        v.onValueChangeCallback = block
        
        
        let largeSwitch = EXSwitchV6(style: .large)
        largeSwitch.onValueChangeCallback = block
        
        let v1 = EXSwitchV6()
        v1.isOn = false
        v1.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(51, 31))
        }
        v1.onValueChangeCallback = block
        
        
        let stackView = UIStackView(arrangedSubviews: [v,largeSwitch,v1])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.distribution = .fill
        stackView.alignment = .leading
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(280)
            make.left.equalTo(16)
        }
        
        // test compression
        let switchCompression = EXSwitchV6()
        switchCompression.rx.controlEvent(.valueChanged).subscribe { _ in
            print("switch state valueChanged ----> \(switchCompression.isOn)")
        }.disposed(by: disposeBag)
        view.addSubview(switchCompression)
        switchCompression.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.left.equalTo(16)
        }
        
        let labelCompression = UILabel(text: "[compression]甘迪给你打个相关都看不到闺女韩国续不度过对吧大V不错不存不存续", font: .Ex.regular(12), textColor: .Ex.text1)
        labelCompression.layer.borderColor = UIColor.red.cgColor
        labelCompression.layer.borderWidth = EX_Pixel_One
        view.addSubview(labelCompression)
        labelCompression.snp.makeConstraints { make in
            make.top.equalTo(switchCompression)
            make.left.equalTo(switchCompression.snp.right).offset(10)
            make.right.equalTo(-16)
        }
        
        // test hugging
        let switchHugging = EXSwitchV6(style: .large)
        switchHugging.rx.controlEvent(.valueChanged).subscribe { _ in
            print("switch state valueChanged ----> \(switchCompression.isOn)")
        }.disposed(by: disposeBag)
        view.addSubview(switchHugging)
        switchHugging.snp.makeConstraints { make in
            make.top.equalTo(switchCompression.snp.bottom).offset(40)
            make.left.equalTo(16)
        }
        
        let labelHugging = UILabel(text: "[hugging]this label will be hugging", font: .Ex.regular(12), textColor: .Ex.text1)
        labelHugging.layer.borderColor = UIColor.red.cgColor
        labelHugging.layer.borderWidth = EX_Pixel_One
        view.addSubview(labelHugging)
        labelHugging.snp.makeConstraints { make in
            make.top.equalTo(switchHugging)
            make.left.equalTo(switchHugging.snp.right).offset(10)
            make.right.equalTo(-16)
        }
        
    }
    
    
    
}
