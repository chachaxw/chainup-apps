//
//  EXSwapHorThreeCell.swift
//  EXSwapSDK
//
//  Created by ZYJ on 2023/3/23.
//

import UIKit
class EXSwapHorThreeCellModel:EXCOBaseModel {
    var leftTop = ""
    var leftBottom:String?
    var middleTop = ""
    var middleBottom:String?
    var rightTop = ""
    var rightBottom:String?
    var available = false
}

class EXSwapHorThreeCell: UITableViewCell {
    
    lazy var topView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        return view
    }()
    
    lazy var middleView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        return view
    }()
    
    lazy var bottomView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.setLeftText("cp_position_text2".ex_localized())
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.ThemeView.bg
        self.contentView.exs_addSubViews([topView, middleView, bottomView])
        self.contentView.backgroundColor = UIColor.ThemeView.bgIcon
        self.contentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12.5)
            make.right.equalToSuperview().offset(-12.5)
            make.top.bottom.equalToSuperview()
        }
        self.topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(18)
            make.left.right.equalToSuperview()
            make.height.equalTo(18)
        }
        self.middleView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.left.height.right.equalTo(topView)
        }
        self.bottomView.snp.makeConstraints { (make) in
            make.top.equalTo(middleView.snp.bottom).offset(20)
            make.left.height.right.equalTo(topView)
        }
    }
    
    func setData(data:EXSwapHorThreeCellModel) {
        setTop(left: data.leftTop, middle: data.middleTop, right: data.rightTop)
        setBottom(left: data.leftBottom, middle: data.middleBottom, right: data.rightBottom)
    }
    
    func setTop(left:String,middle:String,right:String) {
        topView.leftLabel.text = left
        middleView.leftLabel.text = middle
        bottomView.leftLabel.text = right
    }
    
    func setBottom(left:String?,middle:String?,right:String?) {
        topView.rightLabel.text = left
        middleView.rightLabel.text = middle
        bottomView.rightLabel.text = right
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXSwapStopPLDetailCell: EXSwapHorThreeCell {
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    override func setData(data: EXSwapHorThreeCellModel) {
        setTop(left: data.leftTop, middle: data.middleTop, right: data.rightTop)
        setBottom(left: data.leftBottom, middle: data.middleBottom, right: data.rightBottom,available: data.available)
    }
    func setBottom(left: String?, middle: String?, right: String?,available:Bool) {
        super.setBottom(left: left, middle: middle, right: right)
        if available {
            bottomView.rightLabel.textColor = UIColor.ThemekLine.up
        }
    }
}
