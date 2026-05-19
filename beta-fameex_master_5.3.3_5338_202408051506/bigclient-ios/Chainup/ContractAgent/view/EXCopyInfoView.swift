//
//  EXCopyInfoView.swift
//  Chainup
//
//  Created by chainup on 2023/8/27.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXCopyInfoView: UIView {
    
    var isSuperior: Bool = false {
        didSet {
            updatLayoutOfAddCodeButtonIfNeed(isSuperior)
        }
    }
    
    private var pasteContent: String?
    
    lazy var leftLabel: UILabel = {
        let v = UILabel()
        v.textColor = .Ex.text1
        v.font = .Ex.medium(14)
        v.extUseAutoLayout()
        return v
    }()
    
    lazy var copyLabel: UILabel = {
        let v = UILabel()
        v.textColor = .Ex.text1
        v.font = .Ex.regular(12)
        v.extUseAutoLayout()
        return v
    }()
    
    lazy var copyImageView: UIImageView = {
        let v = UIImageView()
        v.extUseAutoLayout()
        v.contentMode = .scaleAspectFit
        v.image = .themeImageNamed(imageName: "assets_copy")
        return v
    }()
    
    lazy var addCodeButton: EXButton = {
        let v = EXButton(type: .custom)
        v.isHidden = true
        v.selectStyle = .blueTextColor
        v.setTitle("referral_superior_button".localized(), for: .normal)
        v.setEnlargeEdgeWithTop(6, left: 6, bottom: 6, right: 6)
        return v
    }()
    
    lazy var copyBackView: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill3
        v.extSetCornerRadius(2)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
        onBindViewModel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
        onBindViewModel()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        onCreate()
        onBindViewModel()
    }
    
    func onCreate() {
        addSubViews([leftLabel, copyBackView, addCodeButton])
        copyBackView.addSubViews([copyLabel, copyImageView])
        leftLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(25)
        }
        copyBackView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(leftLabel.snp.right).offset(50)
            make.height.equalTo(25)
        }
        addCodeButton.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(leftLabel.snp.right).offset(50)
            make.right.equalToSuperview()
            make.centerY.height.equalToSuperview()
        }
        ///
        copyLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.height.equalToSuperview()
        }
        copyImageView.snp.makeConstraints { make in
            make.left.equalTo(copyLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSizeMake(12, 12))
        }
        
        addCodeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        leftLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        leftLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    func onBindViewModel() {
        let tap = UITapGestureRecognizer()
        tap.rx.event.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.pasteContent?.copyToPasteBoard()
                EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
            }).disposed(by: disposeBag)
        copyBackView.addGestureRecognizer(tap)
        
    }
    
    func setData(title:String?, content:String?, paste: String? = nil) {
        leftLabel.text = title
        copyLabel.text = content
        pasteContent = paste
    }
    
    private func updatLayoutOfAddCodeButtonIfNeed(_ flag: Bool) {
        copyBackView.isHidden = flag
        addCodeButton.isHidden = !flag
        layoutIfNeeded()
    }
}
