//
//  EXSHistorySectionHeaderView.swift
//  Chainup
//
//  Created by cwd on 2022/11/12.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

/////委托详情cell 区头 English: /Commission details cell header
class EXSHistorySectionHeaderView: UITableViewHeaderFooterView {
    class func getViewHeight(showRonder:Bool) -> CGFloat{
        var h: CGFloat = 32 + 20 + 10
        if showRonder{
            h += 5
        }
        return h
    }
    var showTopRounder: Bool = false{
        didSet{
            view.isHidden = !showTopRounder
        }
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var view = UIView()
    func configSubView(){
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(32)
            make.height.equalTo(20)
        }
        self.addSubview(view)
        view.backgroundColor = UIColor.ThemeView.newbg
        view.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(12.5)
            make.right.equalToSuperview().offset(-12.5)
        }
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        view.roundCorners(corners: [.topLeft,.topRight], radius: 4)
    }
    lazy var tipLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
}

/////委托详情cell 区头 English: /Commission details cell header
class EXSHistorySectionRounderView: UITableViewHeaderFooterView {
    class var viewHeight: CGFloat{
        return 5
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var view = UIView()
    func configSubView(){
        self.backgroundColor = .clear //UIColor.ThemeView.bg
        self.contentView.backgroundColor =  .clear//UIColor.ThemeView.bg
        let v = UIView()
        v.backgroundColor =  UIColor.ThemeView.newbg
        self.addSubview(v)
//        if #available(iOS 11.0, *) {
//            self.backgroundView?.backgroundColor = .clear
//        }
        v.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12.5)
            make.right.equalToSuperview().offset(-12.5)
            make.top.bottom.equalToSuperview()
        }
        view = v
      
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        view.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 4)
        if #available(iOS 11.0, *) {
            backgroundView?.frame = CGRect(x: 0, y: -100, width: frame.width, height: 100)
        }
    }
}

