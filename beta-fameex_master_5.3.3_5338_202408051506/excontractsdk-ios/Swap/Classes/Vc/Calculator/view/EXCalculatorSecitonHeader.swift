//
//  EXCalculatorSecitonHeader.swift
//  Chainup
//
//  Created by cwd on 2022/11/14.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

class EXCalculatorSecitonHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configSubView(){
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubViews([tipsContent,tipsLabel])
        initLayout()
    }
    
    ///  提示内容 English: /Prompt content
    lazy var tipsContent: UILabel = {
        let label = UILabel(text: "cp_extra_text148".ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeState.warning, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    /// 结果展示 English: /Result display
    lazy var tipsLabel: UILabel = {
        let label = UILabel(text: "cp_calculator_text12".ex_localized(), font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    func initLayout() {
        tipsContent.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
        }
        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(tipsContent.snp.bottom).offset(16)
            make.height.equalTo(16)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
}

