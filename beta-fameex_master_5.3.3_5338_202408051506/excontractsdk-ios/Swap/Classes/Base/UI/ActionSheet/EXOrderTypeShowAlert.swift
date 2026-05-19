//
//  EXOrderTypeShowAlert.swift
//  Chainup
//
//  Created by cwd on 2022/12/6.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit
//选择币对 English: Select currency pairs
class EXOrderTypeShowAlert: EXBaseContainView {
    var dataSouce:[EXSwapDrawerViewData] = []
    var vcs:[EXOrderTypeShowItemView] = []
    let types =  EXSwapMarketOrderType.getOrderTypes()
    
    var type: EXSwapMarketOrderType? {
        didSet{
            guard self.type != nil else{
                return
            }
            configDefaultSelectedItem(type: type!)
        }
    }
    //MARK: lifecycle
    override func setSubView() {
        super.setSubView()
        configSubView()
        let h = 316
        self.snp.makeConstraints { make in
            make.height.equalTo(h)
        }
    }
    deinit{
//        //print("销魂了")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.exs_roundCorners(corners: [.topLeft,.topRight], radius: 12)
    }
    //MARK: action
    @objc func clickCancelButton(){
        EXAlert.dismiss()
    }
    
    
    //MARK: lazy
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    /// 取消 English: /Cancel
    lazy var cancelButton: EXButton = {
        let button = EXButton(buttonType: .custom, title: "cp_overview_text56".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeLabel.colorMedium)
        button.selectStyle = .defultColor
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    
   
    

}
extension EXOrderTypeShowAlert{
    func configSubView(){
        self.backgroundColor = UIColor.ThemeView.alertBg
        for (_,type) in types.enumerated() {
            let listVc = EXOrderTypeShowItemView()
            listVc.type = type
            vcs.append(listVc)
        }
        self.addSubview(cancelButton)
        self.addSubview(self.listContainerView)
       
        self.segmentedView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(44)
            make.left.equalToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.left.equalTo(self.segmentedView.snp.right).offset(10)
            make.centerY.equalTo(self.segmentedView)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(45)
            make.height.equalTo(18)
        }
        self.segmentIndicatorType = .line
        segmentedView.listContainer = self.listContainerView
        self.listContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.segmentedView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
//MARK: 配置数据源 English: MARK: Configure data source
extension EXOrderTypeShowAlert{
    override func configTitles() -> [String]{
        
        let titles = types.map { item in
            return item.display
        }
        return titles
    }
    override func indexDidChanged() {
        
    }
}

extension EXOrderTypeShowAlert: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return vcs[index]
    }
}


extension EXOrderTypeShowAlert: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}

extension EXOrderTypeShowAlert{
    
    func configDefaultSelectedItem(type:EXSwapMarketOrderType){
        let index = types.firstIndex(of: type) ?? 0
        self.segmentedView.defaultSelectedIndex = index
        self.listContainerView.defaultSelectedIndex = index
    }
    
}



class EXOrderTypeShowItemView: EXCOCustomBaseView {
    
    var type:EXSwapMarketOrderType? {
        didSet{
            titleLabel.text = type?.indicator
            setContent(content: type?.indicatorDetail ?? "")
        }
    }
    
    
    
    

     //MARK: lifecycle
    override func setSubView() {
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.exs_addSubViews([titleLabel,contentView])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
        }
    }

    
    //MARK: lazy
    
    func setContent(content:String){
        let message = NSMutableAttributedString(string: content)
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 5
        para.paragraphSpacing = 20
        message.addAttribute(.foregroundColor, value: UIColor.ThemeLabel.colorMedium, range: NSRange(location: 0, length: message.length))
        message.addAttribute(.font, value: UIFont.ThemeFont.SecondaryRegular, range: NSRange(location: 0, length: message.length))
        message.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: message.length))
        self.contentView.attributedText = message
    }
    
    
    //MARK: lazy
    ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var contentView: UITextView = {
        let textView = UITextView()
        textView.ext_UseAutoLayout()
        textView.backgroundColor = UIColor.ThemeView.alertBg
        textView.textColor = UIColor.ThemeLabel.colorMedium
        textView.isScrollEnabled = true
//        let message = NSMutableAttributedString(string: "cp_extra_text117".ex_localized())
//        let para = NSMutableParagraphStyle()
//        para.lineSpacing = 5
//        para.paragraphSpacing = 20
//        message.addAttribute(.foregroundColor, value: UIColor.ThemeLabel.colorMedium, range: NSRange(location: 0, length: message.length))
//        message.addAttribute(.font, value: UIFont.ThemeFont.SecondaryRegular, range: NSRange(location: 0, length: message.length))
//        message.addAttribute(.paragraphStyle, value: para, range: NSRange(location: 0, length: message.length))
//        textView.attributedText = message
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }()
}

extension EXOrderTypeShowItemView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}



