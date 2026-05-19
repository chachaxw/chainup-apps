//
//  EXPasteTextField.swift
//  EXKit
//
//  Created by bradjohn on 2024/5/14.
//

import UIKit

public class EXPasteTextField: EXBasicTextField {
    
    public override var contentInset: UIEdgeInsets {
        didSet {
            guard currentContentView.superview != nil else { return }
            currentContentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(contentInset) }
        }
    }
    
    var isCanPaste: Bool = true {
        didSet {
            updateLayoutIfNeeded(canPaste: isCanPaste)
        }
    }
    
    lazy var pasteBtn: EXButton = {
        let v = EXButton()
        v.selectStyle = .blueTextColor
        v.setTitle("common_action_paste".localized(), for: .normal)
        v.addTarget(self, action: #selector(pasteAction), for: .touchUpInside)
        return v
    }()
    
    private lazy var currentContentView: UIView = {
        let v = UIView()
        v.extUseAutoLayout()
        v.setContentHuggingPriority(.required, for: .horizontal)
        return v
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
    }
    
    func onCreate() {
        addSubViews([currentContentView])
        currentContentView.addSubViews([contentView, pasteBtn])
        ///
        currentContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentInset)
        }
        ///
        updateLayoutIfNeeded(canPaste: true)
        ///
        contentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentView.setContentCompressionResistancePriority(.required, for: .horizontal)
        pasteBtn.setContentHuggingPriority(.required, for: .horizontal)
        pasteBtn.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    @objc func pasteAction() {
        if let copyText = UIPasteboard.general.string {
            textField.text = copyText
            textField.sendActions(for: .valueChanged)
        }
    }
    
    private func updateLayoutIfNeeded(canPaste: Bool) {
        guard pasteBtn.superview != nil else {
            return
        }
        pasteBtn.isHidden = !isCanPaste
        contentView.snp.removeConstraints()
        pasteBtn.snp.removeConstraints()
        if isCanPaste {
            contentView.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.bottom.equalToSuperview()
            }
            pasteBtn.snp.makeConstraints { make in
                make.left.equalTo(contentView.snp.right).offset(8)
                make.right.equalToSuperview()
                make.top.bottom.equalToSuperview()
            }
        } else {
            contentView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
