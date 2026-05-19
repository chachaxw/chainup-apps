//
//  EXAlertTableView.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/14.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
typealias AlertCallback = (SafetyTypes) -> ()
class EXOTCSafetyAlert: EXView {
    var hasPayment: Bool = false
    var alertCallback : AlertCallback?
    var items = [SafeSetItem]()
    var safeSet: Bool = true //Is it set up safely
    
    ///Title
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    ///Subtitle
    lazy var subtitleLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var cancelbtn:UIButton = {
        let btnBuy = UIButton(type: .custom)
        btnBuy.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btnBuy.setTitle("common_text_btnCancel".localized(), for: .normal)
        btnBuy.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btnBuy.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .selected)
        btnBuy.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        btnBuy.isSelected = true
        btnBuy.setEnlargeEdgeWithTop(10, left: 30, bottom: 10, right: 30)
        return btnBuy
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 0
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.register(EXAlertCheckCell.self)
        tableView.register(EXAlertSetingCell.self)
        return tableView
    }()
    
    
    
    override func setupView(){
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubViews([titleLabel,subtitleLabel,cancelbtn,tableView])
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
            make.height.equalTo(28)
            make.right.lessThanOrEqualToSuperview()
        }
        cancelbtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
//            make.width.equalTo(60)
            make.height.equalTo(20)
            make.centerY.equalTo(titleLabel)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp_bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
        
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        roundCorners(corners: [.topLeft, .topRight], radius: 10)
        roundCorners(corners: .allCorners, radius: 10)
    }
    
    
    @objc func cancel(){
        EXAlert.dismiss()
    }
    
    
    
    func configAlert(title:String,
                     message:String,
                     safeItems:[SafetyTypes],
                     passiveBtnTitle:String = "common_text_btnCancel".localized(),
                     positiveBtnTitle:String = "common_text_btnConfirm".localized())
    {
        //Set
        titleLabel.text = title
        subtitleLabel.text = message
        cancelbtn.setTitle(passiveBtnTitle, for: .normal)
        cancelbtn.setTitle(passiveBtnTitle, for: .selected)
        self.items = SafeSetItem.getItemList(safeItems: safeItems)
        self.tableView.reloadData()
        var subTitleH = message.getHeightline(width: SCREEN_WIDTH - 100, font: 14, lineH: 1)
        if subTitleH < 25 {
            subTitleH = 25
        }
        var totalH:CGFloat = 16 + 28 + 12 + subTitleH + 20
        if self.safeSet {
            
            for item in items {
                totalH += EXAlertSetingCell.getCellHeight(content: item.title)
            }
            
//            totalH += CGFloat(self.items.count) * EXAlertSetingCell.cellHeight // + 60 - 15
        }else{
            totalH += CGFloat(self.items.count) * EXAlertCheckCell.cellHeight  + 20
        }
        self.snp.updateConstraints { (make) in
            make.height.equalTo(totalH)
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
}
extension EXOTCSafetyAlert: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if safeSet == true {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXAlertSetingCell
            cell.item = self.items[indexPath.row]
            cell.alertCallback = { [weak self] t in
                EXAlert.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.alertCallback!(t)
                }
                
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXAlertCheckCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if safeSet == true {
            let item  = self.items[indexPath.row]
            return EXAlertSetingCell.getCellHeight(content: item.title)
        }else{
            return EXAlertCheckCell.cellHeight
        }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = self.items[indexPath.row]
//        self.alertCallback?(item.type)
//    }
}
///Nickname settings
class EXAlertSetingCell: UITableViewCell,EXReusableView{
    static func getCellHeight(content: String) -> CGFloat {
        let w = Device_W - 16 * 2 - 50
        var h = content.textSizeWithFont(UIFont.ThemeFont.BodyRegular, width: w).height
        h += 30
        if h < 60 {
            h = 60
        }
        return h
    }
    var alertCallback : AlertCallback?
    var item: SafeSetItem? {
        didSet{
            guard let it = item else{
                return
            }
            nameLabel.text = it.title
            let btntilte = it.isDone ? "personal_Center_text16".localized(): "personal_Center_text17".localized()
            let width = btntilte.getTextWidth(font: 14) + 10
            let color = it.isDone ? UIColor.ThemeLabel.colorMedium : UIColor.Ex.main4
            setBtn.setTitle(btntilte, for: .normal)
            setBtn.setTitleColor(color, for: .normal)
            setBtn.setTitle(btntilte, for: .selected)
            setBtn.setTitleColor(color, for: .selected)
            setBtn.snp.updateConstraints { make in
                make.width.equalTo(width)
            }
        }
    }
    ///Option Name
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var setBtn:UIButton = {
        let btnBuy = UIButton(type: .custom)
        btnBuy.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btnBuy.addTarget(self, action: #selector(setbtnClick), for: .touchUpInside)
        return btnBuy
    }()
    
    lazy var container: UIView = {
        let horLineView = UIView()
        horLineView.ext_UseAutoLayout()
        horLineView.backgroundColor = UIColor.ThemeNav.bg
        return horLineView
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = UIColor.ThemeView.bg
        setSubView()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubView(){
        contentView.addSubViews([container])
        container.snp_makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
        container.addSubViews([nameLabel,setBtn])
        nameLabel.snp_makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-50)
        }
        setBtn.snp_makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(45)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.roundCorners(corners: .allCorners, radius: 4)
    }
    
    @objc func setbtnClick(){
        if self.item!.isDone {
            return
        }
        self.alertCallback?(self.item!.type)
    }
}

///语言列表 //
class EXAlertCheckCell: UITableViewCell,EXReusableView{
    
    static var cellHeight: CGFloat = 52
    ///Option Name
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var checkImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
//        arrowImmg.image = UIImage(named: "")
//        arrowImmg.backgroundColor = .red
        return arrowImmg
    }()
    
    
    lazy var line: UIView = {
        let horLineView = UIView()
        horLineView.ext_UseAutoLayout()
        horLineView.backgroundColor = UIColor.ThemeView.bgGap
        return horLineView
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = UIColor.ThemeView.bg
        setSubView()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubView(){
        contentView.addSubViews([nameLabel,checkImg,line])
        nameLabel.snp_makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        checkImg.snp_makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        line.snp_makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
}

