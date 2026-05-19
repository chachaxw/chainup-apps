//
//  EXTradeHeaderBase.swift
//  Chainup
//
//  Created by 劉軒 on 2023/10/31.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXTradeHeaderFooter:UIView {
    
    var contentInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10) {
        didSet {
            layoutIfNeeded()
        }
    }
    
    lazy var notesLabel: UILabel = {
        let label = UILabel()
        label.font = .Ex.medium(12)
        label.textColor = .Ex.text2
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configNotesUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configNotesUI() {
        backgroundColor = .Ex.main1.withAlphaComponent(0.15)
        extSetCornerRadius(4)
        addSubview(notesLabel)
        notesLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
    }
}

class EXTradeHeaderBase: UIView {
    var entity:CoinMapEntity
    var orderType:EXTradeOrderType
    var headerLayout:EXTradeHeaderLayout
    var orderWay:EXTradeOrderWay
    
    var contentInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 20, right: 16) {
        didSet {
            centerView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
        }
    }
    
    lazy var centerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var cmFooter:EXTradeHeaderFooter  = {
        let footer = EXTradeHeaderFooter()
        return footer
    }()
    
    typealias LeverPanelCallback = () -> ()
    var onLeverPanelCallback : LeverPanelCallback?
    
    required init(entity:CoinMapEntity,orderType:EXTradeOrderType,layout:EXTradeHeaderLayout, orderWay: EXTradeOrderWay){
        self.entity = entity
        self.orderType = orderType
        self.headerLayout = layout
        self.orderWay = orderWay
    
        super.init(frame: .init(origin: .zero, size: .init(width: CGFLOAT_MIN, height: CGFloat.leastNonzeroMagnitude)))
        
        addSubViews([centerView])
        centerView.addSubViews([cmFooter])
        centerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentInsets)
        }
        cmFooter.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        updateCmFooter()
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCmFooter() {
        if self.entity.etfOpen == "1" {
            let attributedText = entity.getETFNotesAttributes("etf_notes_explain_tips")
            if !attributedText.string.isEmpty {
                cmFooter.notesLabel.attributedText = attributedText
                cmFooter.isHidden = false
                return
            }
        }
        cmFooter.isHidden = true
    }
    
    func onCreate() {
   
    }
    
    func refreshHeader(orderWay:EXTradeOrderWay) {
        if self.orderWay != orderWay {
            self.orderWay = orderWay
        }
    }
    
    func refreshEntity(entity:CoinMapEntity) {
        self.entity = entity
        updateCmFooter()
        
    }
}

