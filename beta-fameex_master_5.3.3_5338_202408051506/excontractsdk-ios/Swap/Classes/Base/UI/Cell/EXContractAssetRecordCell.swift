//
//  EXContractAssetRecordCell.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/12.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

public class EXContractAssetRecordCell: UITableViewCell {

    var twoByTwoView = EXSTwoByTwoView()
    var dataModel = EXSTwoByTwoItemModel()
    /// 横线 English: /Horizontal line
    lazy var horLineView: UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    public func setCell(leftTop:String, leftBottom:String, rightTop:String, rightBottom:String) {
        
        resetModel()
        dataModel.ltitle = leftTop
        dataModel.lcontent = leftBottom
        dataModel.rtitle = rightTop
        dataModel.rcontent = rightBottom
        twoByTwoView.bindModel(dataModel)
    }
    func resetModel() {
        dataModel.ltitle = ""
        dataModel.lcontent = ""
        dataModel.rtitle = ""
        dataModel.rcontent = ""
    }
    func getModel() -> EXSTwoByTwoItemModel {
        
        let modelB = EXSTwoByTwoItemModel()
        modelB.ltitleColor = UIColor.ThemeLabel.colorLite
        modelB.rtitleColor = UIColor.ThemeLabel.colorLite
        
        modelB.lcontentFont = self.themeHNFont(size: 12)
        modelB.lcontentColor = UIColor.ThemeLabel.colorMedium
        modelB.rcontentFont = self.themeHNFont(size: 12)
        modelB.rcontentColor = UIColor.ThemeLabel.colorMedium
        modelB.rightAlignment = .right
        
        return modelB
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = UIColor.ThemeView.bg
        contentView.exs_addSubViews([twoByTwoView,horLineView])

        dataModel = getModel()
        addTwoByTwoView(dataModel)
        twoByTwoView.snp.makeConstraints { (make) in

            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(14.5)
            make.bottom.equalTo(-11.5)
        }
     
        horLineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTwoByTwoView(_ item:EXSTwoByTwoItemModel) {
        
        twoByTwoView.backgroundColor = UIColor.ThemeView.bg
        twoByTwoView.leftBottomLabel.font = item.lcontentFont
        twoByTwoView.rightBottomLabel.font = item.rcontentFont
        twoByTwoView.leftTopLabel.font = self.themeHNFont(size: 14)
        twoByTwoView.rightTopLabel.font = self.themeHNFont(size: 14)
        twoByTwoView.bindModel(item)
        
        self.addSubview(twoByTwoView)
    }
}

