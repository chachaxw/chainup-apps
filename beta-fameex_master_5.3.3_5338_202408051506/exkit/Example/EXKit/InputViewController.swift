//
//  InputViewController.swift
//  EXKit_Example
//
//  Created by cwd on 2023/6/9.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EXKit
import YYText
import YYWebImage

class InputViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .Ex.fill2
        // Do any additional setup after loading the view.
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(stackView)
        let inset = UIEdgeInsets(top: 16, left: 16, bottom: EXSafeAreaBottom, right: 16)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(inset)
            make.width.equalToSuperview().offset(-inset.left - inset.right)
        }
        test()
        return
    }
    
    lazy var stackView: EXStackView = {
        let stackView = EXStackView()
        stackView.separatorConfiguration = .init(color: .Ex.fall1, height: 2)
        stackView.spacing = 30
        stackView.axis = .vertical
        return stackView
    }()

}


extension InputViewController {
    
    func test() {
        testTextField()
        testSelector()
        testCard()
    }
    
    func test(with updaters:[()->Void]) {
        var vals = updaters
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let _ = self else { return }
            if vals.isEmpty {
                timer.invalidate()
                return
            }
            vals.first?()
            vals.removeFirst()
        }
    }
}

extension InputViewController {
    
    func testCard() {
        testCard1()
        testCard2()
    }
    
    func testCard1() {
        let card = EXCardView()
        card.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.addArrangedSubview(card)
        //
        let label1 = YYLabel()
        label1.numberOfLines = 0
        label1.preferredMaxLayoutWidth = Device_W - 84
        label1.font = .Ex.medium(12)
        label1.textColor = .Ex.text1
        label1.text = "ChainUp-DOT"
        label1.attributedText = label1.ex_NSAttributedString()
        label1.isUserInteractionEnabled = false
        //
        let attributedText = label1.ex_NSAttributedString()?.ex_mutableCopy()
        for idx in 1...Int.random(in: 5...10) {
            attributedText?.append(NSAttributedString.yy_attachmentString(withContent: CALayer(), contentMode: .center, attachmentSize: CGSize(width: 5, height: 5), alignTo: label1.font, alignment: .center))
            let tagView = EXInsetLabel(text: "ERC2O_\(idx)", font: .Ex.regular(10), textColor: .Ex.text4, alignment: .center)
            tagView.edgeInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            tagView.backgroundColor = .Ex.main1
            tagView.corneradius = 2
            tagView.frame = CGRect(origin: .zero, size: tagView.intrinsicContentSize)
            attributedText?.append(NSAttributedString.yy_attachmentString(withContent: tagView, contentMode: .center, attachmentSize: tagView.intrinsicContentSize, alignTo: label1.font, alignment: .center))
        }
        label1.attributedText = attributedText?.ex_lineSpacing(5)
        //
        let label2 = UILabel(text: "7832hhfew834h20u9rdj32uerdh3289y4ehnddrdj32uerdh3289y4ehndd", font: .Ex.medium(14), textColor: .Ex.text1, alignment: .left)
        label2.numberOfLines = 0
        let label3 = UILabel(text: "MEMOMEMOMEMOMEMO", font: .Ex.regular(12), textColor: .Ex.text2, alignment: .left)
        card.contentView.addArrangedSubviews([label1,label2,label3])
        card.rx.controlEvent(.touchUpInside).subscribe(onNext: {
            card.isSelected = !card.isSelected
        }).disposed(by: disposeBag)
    }
    
    func testCard2() {
        let card = EXCardView()
        card.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.addArrangedSubview(card)
        card.isCheckMarkInline = true
        //
        let label1 = YYLabel()
        label1.numberOfLines = 0
        label1.preferredMaxLayoutWidth = Device_W - 84
        label1.font = .Ex.medium(12)
        label1.textColor = .Ex.text1
        label1.text = "ChainUp-DOT"
        label1.attributedText = label1.ex_NSAttributedString()
        label1.isUserInteractionEnabled = false
        //
        let attributedText = label1.ex_NSAttributedString()?.ex_mutableCopy()
        for idx in 1...Int.random(in: 2...4) {
            attributedText?.append(NSAttributedString.yy_attachmentString(withContent: CALayer(), contentMode: .center, attachmentSize: CGSize(width: 5, height: 5), alignTo: label1.font, alignment: .center))
            let tagView = EXInsetLabel(text: "ERC2O_\(idx)", font: .Ex.regular(10), textColor: .Ex.text4, alignment: .center)
            tagView.edgeInset = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
            tagView.backgroundColor = .Ex.main1
            tagView.corneradius = 2
            tagView.frame = CGRect(origin: .zero, size: tagView.intrinsicContentSize)
            attributedText?.append(NSAttributedString.yy_attachmentString(withContent: tagView, contentMode: .center, attachmentSize: tagView.intrinsicContentSize, alignTo: label1.font, alignment: .center))
        }
        label1.attributedText = attributedText?.ex_lineSpacing(5)
        //
        let label2 = UILabel(text: "7832hhfew834h20u9rdj32uerdh3289y4ehnddrdj32uerdh3289y4ehndd", font: .Ex.medium(14), textColor: .Ex.text1, alignment: .left)
        label2.numberOfLines = 0
        let label3 = UILabel(text: "MEMOMEMOMEMOMEMO", font: .Ex.regular(12), textColor: .Ex.text2, alignment: .left)
        card.contentView.addArrangedSubviews([label1,label2,label3])
        card.rx.controlEvent(.touchUpInside).subscribe(onNext: {
            card.isSelected = !card.isSelected
        }).disposed(by: disposeBag)
    }
}

extension InputViewController {
    //
    func testBasicSelector(selector:EXBasicSelector) {
        selector.rx.controlEvent(.valueChanged).subscribe(onNext: {
            selector.endEditing(true)
            if selector.isOn {
                print("basic isOn")
            } else {
                print("basic isOff")
            }
        }).disposed(by: disposeBag)
        selector.title = "test123"
    }
    //
    func testCommonSelector(selector:EXCommonSelector) {
        selector.topLabel.text = "selector Amount"
        selector.bottomLabel.text = "selector Available 23.923823123BTC"
        testBasicSelector(selector: selector.basicSelector)
    }
    //
    func testSelector() {
        //
        let basicSelector = EXBasicSelector()
        stackView.addArrangedSubview(basicSelector)
        //
        let commonSelector = EXCommonSelector()
        stackView.addArrangedSubview(commonSelector)
        //
        testBasicSelector(selector: basicSelector)
        testCommonSelector(selector: commonSelector)
    }
}


extension InputViewController {
    //
    func testBasicTextField(textField:EXBasicTextField) {
        test(with: [
            {
                textField.attributedPlaceholder = NSAttributedString(string: "placeholder text", attributes: [.foregroundColor:UIColor.Ex.text3])
                textField.text = "input"
            },
            {
                YYWebImageManager.shared().cache?.diskCache.removeAllObjects()
                YYWebImageManager.shared().cache?.memoryCache.removeAllObjects()
                let imageView = UIImageView()
                imageView.corneradius = 4
                imageView.yy_setImage(with: URL(string: "https://pics2.baidu.com/feed/5d6034a85edf8db1d2af12b82675265f544e74ce.jpeg"))
                imageView.snp.makeConstraints { make in
                    make.size.equalTo(CGSize(width: 24, height: 24))
                }
                textField.leadingView.addArrangedSubview(imageView)
            },
            {
                let leftLabel = UILabel(text: "left1", font: .Ex.regular(12), textColor: .red, alignment: .left)
                leftLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
                leftLabel.setContentHuggingPriority(.required, for: .horizontal)
                textField.leadingView.addArrangedSubview(leftLabel)
            },
            {
                let rightLabel = UILabel(text: "right1", font: .Ex.regular(12), textColor: .Ex.main1, alignment: .left)
                rightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
                rightLabel.setContentHuggingPriority(.required, for: .horizontal)
                textField.trailingView.addArrangedSubview(rightLabel)
            },
            {
                let rightLabel2 = UILabel(text: "right2", font: .Ex.regular(13), textColor: .Ex.main2, alignment: .left)
                rightLabel2.setContentCompressionResistancePriority(.required, for: .horizontal)
                rightLabel2.setContentHuggingPriority(.required, for: .horizontal)
                textField.trailingView.addArrangedSubview(rightLabel2)
            },
            {
                let rightButton3 = UIButton(buttonType: .system, title: "button3", titleFont: .Ex.medium(13), titleColor: .Ex.text3)
                rightButton3.setContentCompressionResistancePriority(.required, for: .horizontal)
                rightButton3.setContentHuggingPriority(.required, for: .horizontal)
                var count = 0
                rightButton3.rx.tap.subscribe(onNext: {
                    count += 1
                    EXKitAlert.showSuccess(msg: "tapped \(count)")
                }).disposed(by: self.disposeBag)
                textField.trailingView.addArrangedSubview(rightButton3)
            },
            {
                textField.contentView.spacing = 5
            },
            {
                textField.leadingView.spacing = 8
            },
            {
                textField.trailingView.spacing = 10
            },
            {
                textField.contentInset = .zero
            },
            {
                textField.trailingView.separatorConfiguration = .init(color: .Ex.main2, height: 6)
                textField.text = "done"
            }
        ])
        //
        textField.textDidChangeSignal.subscribe { text in
            print("basic:\(text)")
        }.disposed(by: disposeBag)
    }
    
    func testCommonTextField(textField:EXCommonTextField) {
        textField.topLabel.text = "Amount"
        textField.bottomLabel.text = "Available 23.923823123BTC"
        testBasicTextField(textField: textField.basicTextField)
        textField.textDidChangeSignal.subscribe { text in
            print("common:\(text)")
        }.disposed(by: disposeBag)
    }
    
    func testTextField() {
        let basicTextField = EXBasicTextField()
        let commonTextField = EXCommonTextField()
        
        stackView.addArrangedSubview(basicTextField)
        stackView.addArrangedSubview(commonTextField)
        
        testBasicTextField(textField: basicTextField)
        testCommonTextField(textField: commonTextField)
        //
        stackView.addArrangedSubview({
            let basic = EXBasicTextField()
            basic.placeholder = "basic"
            return basic
        }())
        //
        stackView.addArrangedSubview({
            let secure = EXSecureTextField()
            secure.placeholder = "secure"
            return secure
        }())
        //
        stackView.addArrangedSubview({
            let coin = EXCoinTextField()
            coin.unit = "USDT"
            coin.placeholder = "coin"
            coin.decimal = "2"
            return coin
        }())
        //
        stackView.addArrangedSubview({
            let button = EXCountdownButton(type: .custom)
            button.rx.tap.subscribe(onNext: {[weak button] _ in
                button?.startCountdown()
            }).disposed(by: disposeBag)
            button.setTitleColor(.Ex.text1, for: .normal)
            button.backgroundColor = .Ex.fill1
            button.titleUpdater = { (button,seconds) in
                if seconds > 0 {
                    button.setTitle("\(seconds)s", for: .normal)
                }else{
                    button.setTitle("login_action_resendCode".localized(), for: .normal)
                }
            }
            button.setTitle("login_action_sendCode".localized(), for: .normal)
            button.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 200, height: 44))
            }
            button.startCountdown()
            return button
        }())
        //
        self.stackView.addArrangedSubview({
            let stepField = EXPersentageField()
            stepField.keyboardType = .decimalPad
            stepField.corneradius = 4
            stepField.decimal = "0"
            stepField.placeholder = "placeholder"
            return stepField
        }())
    }
}
