//
//  EXStopPLView.swift
//  Chainup
//
//  Created by cwd on 2022/11/8.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXStoplossAlert: EXCOCustomBaseView{
    typealias AlertCallback = (Int) -> ()
    var alertCallback : AlertCallback?
    let cellid = "EXAlertCellListCell"
    let cellid2 = "EXAlertCheckListCell"
    var dataList = [AlertInfo]() {
        didSet{
            if dataList.count > 0 {
                tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.05) { [weak self] in
                    self?.update()
                }
                
            }
        }
    }
    
    func update(){
        var total:CGFloat = 45 + (16 + 44 + 20) //头 + 尾 English: Head+Tail
        var hasCancelBtn = false
        for item in dataList{
            total += item.getCellHeight()
            if item.cancheck {
                hasCancelBtn = true
            }
        }
        cancelbtn.isHidden = !hasCancelBtn
        if hasCancelBtn{
            total += 30
            footer.height += 30
        }
        let a = total
//        //print("contentSize.height= \(tableView.contentSize.height)")
        let b = Device_H * 0.8
        let h = min(a,b)
        if a < b {
            tableView.isScrollEnabled = false
        }
        self.snp.makeConstraints { make in
            make.height.equalTo(h)
        }
        tableView.snp_remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    var title: String = "" {
        didSet{
            titleLabel.text = title
        }
    }
    let footer = UIView(frame: CGRect(x: 0, y: 0, width: Device_W - 40, height: 16 + 44 + 20))
    override func setSubView() {
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubview(tableView)
        tableView.backgroundColor = UIColor.ThemeView.alertBg
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: Device_W - 40, height: 45))
        header.backgroundColor = UIColor.ThemeView.alertBg
        header.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(21)
            make.right.equalToSuperview().offset(-21)
            make.bottom.equalToSuperview()
        }
        tableView.tableHeaderView = header
        
        
        footer.addSubViews([surebtn,cancelbtn])
        footer.backgroundColor = UIColor.ThemeView.alertBg
        tableView.tableFooterView = footer
       
        surebtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        cancelbtn.isHidden = true
        cancelbtn.snp.makeConstraints { make in
            make.top.equalTo(surebtn.snp.bottom).offset(12)
            make.width.equalTo(surebtn)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
    }
    
    override func layoutSubviews(){
        roundCorners(corners: [.allCorners], radius: 12)
    }
    
    ///标题 English: /Title
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.H3Medium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(EXAlertCellListCell.self, forCellReuseIdentifier: cellid)
        tableView.register(EXAlertCheckListCell.self, forCellReuseIdentifier: cellid2)
        return tableView
    }()

    lazy var surebtn:UIButton = {
        let btn = EXSButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.backgroundColor = UIColor.ThemeView.alertBg
        btn.setTitleColor(UIColor.white, for:.normal)
        btn.setTitle("cp_calculator_text29".ex_localized(), for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.extSetAddTarget(self, #selector(sure))
        return btn
    }()
    
    //取消按钮 English: Cancel button
    lazy var cancelbtn : UIButton = {
        let btn = EXSButton()
        btn.clearColors()
//        btn.backgroundColor = UIColor.ThemeView.bg
        btn.setTitle("cp_overview_text56".ex_localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for:.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btn.extSetAddTarget(self, #selector(cancelClick))
        btn.setEnlargeEdgeWithTop(20, left: 20, bottom: 30, right: 20)
        return btn
    }()
    
    
    @objc func cancelClick(){
        EXAlert.dismiss()
    }
    @objc func sure(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.alertCallback?(0)
        }
        EXAlert.dismiss()
    }
    
}


extension EXStoplossAlert: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = dataList[indexPath.row]
        if info.cancheck {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellid2, for: indexPath) as! EXAlertCheckListCell
            cell.info = dataList[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath) as! EXAlertCellListCell
            cell.info = dataList[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}

class AlertInfo{
    var cancheck = false
    var title = ""
    var msg = ""
    var userAttr = false
    //提醒 English: remind
    class func getStopLPMessageNextTip() ->AlertInfo {
        let info = AlertInfo()
        info.msg = "cp_overview_text57".ex_localized()
        info.cancheck = true
        return info
    }
    /**
     info: 多语言文案 English: Info: Multilingual copy
     strike:执行价 English: Strike: strike price
     */
    class func getStopLPMessage(title:String, content:String, triggerPrice: String,volum: String, unit: String, strike: String? = "") -> AlertInfo{
        let info = AlertInfo()
        info.title = title
        var message = content
        message = message.replacingOccurrences(of: "%1$@", with:triggerPrice)
        message = message.replacingOccurrences(of: "%2$@", with:volum)
        message = message.replacingOccurrences(of: "%3$@", with:unit)
        if let strike = strike {
            message = message.replacingOccurrences(of: "%4$@", with:strike)
        }
        info.msg = message
        info.userAttr = true
        return info
    }
    
    class func getStopPLInfo() -> [AlertInfo] {
        let a = AlertInfo()
        a.title = "cp_tip_text16".ex_localized()
        a.msg = "cp_tip_text17".ex_localized()
        a.userAttr = true
        let b = AlertInfo()
        b.title = "cp_tip_text18".ex_localized()
        b.msg = "cp_tip_text19".ex_localized()
        b.userAttr = true
        let c = AlertInfo()
        c.title = "cp_tip_text20".ex_localized()
        c.msg = "cp_tip_text21".ex_localized()
        c.userAttr = true
        let d = AlertInfo()
        d.title = "cp_tip_text22".ex_localized()
        d.msg = "cp_tip_text23".ex_localized()
        d.userAttr = true
        return [a,b,c,d]
    }
    //止盈止损的确认 提交的弹框 English: Confirmation submission of stop loss and stop loss pop ups
    class func getStopPLSubmitInfo() -> [AlertInfo] {
        let a = AlertInfo()
        a.title = "cp_tip_text16".ex_localized()
        a.msg = "cp_tip_text17".ex_localized()
        a.userAttr = true
        let b = AlertInfo()
        b.title = "cp_tip_text18".ex_localized()
        b.msg = "cp_tip_text19".ex_localized()
        b.userAttr = true
        let c = AlertInfo()
        c.title = "cp_tip_text20".ex_localized()
        c.msg = "cp_tip_text21".ex_localized()
        c.userAttr = true
        let d = AlertInfo()
        d.title = "cp_tip_text22".ex_localized()
        d.msg = "cp_tip_text23".ex_localized()
        d.userAttr = true
        return [a,b,c,d]
    }
    
    func getCellHeight() -> CGFloat{
        
       
        var height:CGFloat = 16 + 18 //标题 English: title
        height += 8 //内容与标题间距 English: Content to title spacing
        height += 13 //底部间距 English: Bottom spacing
        var maxWidth = Device_W - 40 * 2
        if self.cancheck {
            height = 16
            //左边按钮 20 + 20 + 20 + 10 English: Left button 20+20+20+10
            maxWidth = Device_W - (20 + 50 + 20 + 20)
        }
        let message = NSMutableAttributedString(string: self.msg)
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 3
        message.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: message.length))
        message.addAttribute(.font, value: UIFont.ThemeFont.SecondaryMedium, range: NSRange(location: 0, length: message.length))
        // 计算内容高度 English: Calculate content height
        let contentH = message.boundingRect(with: CGSize(width: maxWidth, height: 200), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size.height
        
        height += contentH
//        //print("height = \(height)")
        return height
    }
}

class EXAlertCellListCell: UITableViewCell{
    
    var info = AlertInfo(){
        didSet{
            titleLabel.text = info.title
            contentLabel.text = info.msg
            if info.userAttr{
                let message = NSMutableAttributedString(string: info.msg)
                let para = NSMutableParagraphStyle()
                para.lineSpacing = 3
//                para.paragraphSpacing = 5
                message.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: message.length))
                contentLabel.attributedText = message
            }
            
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configSubView()
    }
    
    func configSubView(){
        contentView.addSubViews([titleLabel,contentLabel,line])
        self.backgroundColor = UIColor.ThemeView.alertBg
        selectionStyle = .none
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(18)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        line.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
    }
    ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    ///名称 English: /Name
    lazy var contentLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
}


class EXAlertCheckListCell: UITableViewCell{
    
    var info = AlertInfo(){
        didSet{
           // titleLabel.text = info.title
            contentLabel.text = info.msg
        }
    }
    
    @objc func clickBtn(){
        self.checkBtn.isSelected = !self.checkBtn.isSelected
       // //print("不再提醒 - 、\(self.checkBtn.isSelected)") English: Print ("No more reminders -, \ (self. checkBtn. isSelected)")
        EXStoreData.setStoreObjectAndKey(self.checkBtn.isSelected, key: swapTPSLComfirmAlertNotTip)
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configSubView()
    }
    
    func configSubView(){
        contentView.addSubViews([checkBtn,contentLabel])
        self.backgroundColor = UIColor.ThemeView.alertBg
        selectionStyle = .none
        checkBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(13)
            make.width.height.equalTo(20)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(checkBtn.snp.right).offset(2)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
        }
    }
    lazy var checkBtn: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_uncheck"), for: .normal)
        btn.setImage(UIImage.svg_themeImageNamed(imageName: "public_icon_check_mark"), for: .selected)
        return btn
    }()
    ///名称 English: /Name
    lazy var contentLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
}

