//
//  EXAnswersVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/6/10.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXAnswersVc: BaseVC,NavigationPlugin {
    
    typealias AnwserCallback = () -> ()
    var onAnwserback:AnwserCallback?
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self,customHandleBack: false)
        return nav
    }()
    
    var currentIdx:Int = 0
    
    lazy var options:[[String]] = {
        let allAnswers =  ["etf_question_anwsersa".localized(),
                           "etf_question_anwsersb".localized(),
                           "etf_question_anwsersc".localized(),
                           "etf_question_anwsersd".localized(),
                           "etf_question_anwserse".localized()]
        var rsts:[[String]] = []
        for a in allAnswers {
            let q = a.components(separatedBy: "&")
            rsts.append(q)
        }
        return rsts
    }()
    
    lazy var anwsers :[Int] = {
        return [0,1,1,0,2]
    }()
    
    lazy var questions:[String] = {
        return ["etf_question_a".localized(),
                "etf_question_b".localized(),
                "etf_question_c".localized(),
                "etf_question_d".localized(),
                "etf_question_e".localized()]
    }()
    
    lazy var titleQuestion:UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = UIFont.ThemeFont.HeadMedium
        l.textColor = UIColor.ThemeLabel.colorMedium
        return l
    }()
    
    lazy var nextBtn:EXButton = {
        let btn = EXButton.init(type: .custom)
        btn.layer.cornerRadius = 4
        btn.setTitle("etf_question_next".localized(), for: .normal)
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
        return btn
    }()
    
    lazy var optionsBg:UIStackView = {
        let stack = UIStackView.init()
        stack.spacing = 12
        stack.axis = .vertical
        return stack
    }()
    
    var items:[AnswerItem] = []
    
    func configNavi() {
        self.navigation.isLastNavigationStyle = true
        self.navigation.setTitle(title: "etf_question_title".localized())
        self.navigation.setdefaultType(type: .listtitle)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configNavi()
        self.view.addSubview(titleQuestion)
        self.view.addSubview(nextBtn)
        self.view.addSubview(optionsBg)
        titleQuestion.snp.makeConstraints { make in
            make.top.equalTo(navigation.snp.bottom).offset(26)
            make.left.equalTo(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        optionsBg.snp.makeConstraints { make in
            make.top.equalTo(titleQuestion.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.right.equalToSuperview().offset(-12)
        }
        
        nextBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
            make.left.equalTo(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        
        configQuestions()
    }
    
    func configQuestions() {
        if currentIdx == questions.count - 1 {
            nextBtn.setTitle("common_start_trade".localized(), for: .normal)
        }
        if questions.count > currentIdx {
            let titleNumber = "(\(currentIdx + 1)/\(questions.count))"
            let titleMsg = questions[currentIdx]
            let att = NSMutableAttributedString().add(string: titleNumber,
                                                      attrDic:[
                                                        NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium,
                                                        NSAttributedString.Key.font : UIFont.ThemeFont.HeadMedium
                                                      ]).add(string: titleMsg,
                              attrDic: [NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite,
                                        NSAttributedString.Key.font : UIFont.ThemeFont.HeadMedium])
            titleQuestion.attributedText =  att
        }
        if optionsBg.arrangedSubviews.count > 0 {
            optionsBg.removeAllArrangedSubviews()
        }
        if self.options.count > currentIdx,anwsers.count > currentIdx {
            let anwser = anwsers[currentIdx]
            let opts = options[currentIdx]
            for (idx,opt) in opts.enumerated() {
                let item = AnswerItem.init(isCorrect: anwser == idx)
                item.addTarget(self, action: #selector(didSelectAction(sender:)), for: .touchUpInside)
                item.titleLabel.text = opt
                optionsBg.addArrangedSubview(item)
                items.append(item)
            }
        }else {
            self.popBack()
            self.onAnwserback?()
        }
    }
    
    @objc func didSelectAction(sender:AnswerItem) {
        for item in items {
            if item == sender {
                item.isSelected = !sender.isSelected
                nextBtn.isEnabled = (item.isCorrect && item.isSelected)
            }else {
                item.isSelected = false
            }
        }
    }
    
    @objc func nextQuestion() {
        currentIdx += 1
        self.configQuestions()
        nextBtn.isEnabled = false
    }
}


class AnswerItem : UIControl {

    lazy var titleLabel:UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        title.font = UIFont.ThemeFont.HeadMedium
        title.textColor = UIColor.ThemeLabel.colorLite
        return title
    }()
    
    lazy var bg:UIView = {
        let bg = UIView.init()
        bg.isUserInteractionEnabled = false
        bg.backgroundColor = UIColor.ThemeNav.bg
        bg.layer.borderWidth = 0.5
        bg.layer.borderColor = UIColor.ThemeNav.bg.cgColor
        bg.layer.cornerRadius = 4
        return bg
    }()
    
    
    lazy var selectedIcon:UIImageView = {
        let icon = UIImageView()
        return icon
    }()
    
    override var isSelected:Bool {
        didSet {
            updateState()
        }
    }
    
    func updateState() {
        if self.isSelected {
            if isCorrect {
                let rightC = UIColor.extColorWithHex("#00AB8D")
                titleLabel.textColor = rightC
                bg.layer.borderColor = rightC.cgColor
                selectedIcon.image = UIImage.themeImageNamed(imageName: "etf_correct")
            }else {
                let wrongC = UIColor.extColorWithHex("#D1425E")
                titleLabel.textColor = wrongC
                bg.layer.borderColor = wrongC.cgColor
                selectedIcon.image = UIImage.themeImageNamed(imageName: "etf_error")
            }
            selectedIcon.isHidden = false
        }else {
            titleLabel.textColor = UIColor.ThemeLabel.colorLite
            bg.layer.borderColor = UIColor.ThemeNav.bg.cgColor
            selectedIcon.isHidden = true
        }
    }
    
    var isCorrect:Bool
    
    required init(isCorrect:Bool){
        self.isCorrect = isCorrect
        super.init(frame: CGRect.zero)
        configSubviews()
    }
    
    func configSubviews() {
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(bg)
        bg.addSubview(titleLabel)
        self.addSubview(selectedIcon)
        bg.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(SCREEN_WIDTH - 32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(12)
            make.right.lessThanOrEqualToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        selectedIcon.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(bg.snp.top)
            make.width.height.equalTo(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

