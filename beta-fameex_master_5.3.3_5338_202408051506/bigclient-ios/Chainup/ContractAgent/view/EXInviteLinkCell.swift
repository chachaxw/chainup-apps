//
//  EXInviteLinkCell.swift
//  Chainup
//
//  Created by chainup on 2023/8/31.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
import SnapKit

///// the basic component for invite

class EXInviteTitleView: UIView {
    
    var bottomBorderColor: UIColor = .Ex.fill4 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isHavebottomBorder: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard contentView.superview != nil else { return }
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInset) }
        }
    }
    
    lazy var titleLabel: UILabel = {
        let v = UILabel(font: .Ex.bold(16), textColor: .Ex.text1)
        return v
    }()
    
    lazy var ruleButton: UIButton = {
        let v = UIButton(type: .custom)
        v.isHidden = true
        let vt = UILabel(text: "referral_inviteRewards_rules".localized(), font: .Ex.regular(12), textColor: .Ex.text2)
        let vi = UIImageView(image: EXKitBundle.image(named: "public_positions_arrow_right"))
        vi.contentMode = .scaleAspectFit
        v.addSubViews([vt, vi])
        vt.snp.makeConstraints { $0.left.centerY.equalToSuperview()}
        vi.snp.makeConstraints { make in
            make.left.equalTo(vt.snp.right).offset(4)
            make.right.centerY.equalToSuperview()
        }
        return v
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        backgroundColor = .clear
        addSubview(contentView)
        contentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(contentInset) }
        contentView.addSubViews([titleLabel, ruleButton])
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.height.equalToSuperview()
        }
        ruleButton.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(16)
            make.centerY.height.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext(), isHavebottomBorder {
            context.setStrokeColor(bottomBorderColor.cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: 0, y: rect.height))
            context.addLine(to: CGPoint(x: rect.width, y: rect.height))
            context.strokePath()
        }
    }
    
}

class EXInviteVerticalView: UIView {
    
    var spacing: Float = 8 {
        didSet {
            spaceingConstraint?.update(offset: spacing)
        }
    }
    
    var textAlignment: NSTextAlignment = .left {
        didSet {
            topLabel.textAlignment = textAlignment
            bottomLabel.textAlignment = textAlignment
        }
    }
    
    var topText: String? {
        didSet {
            topLabel.text = topText
        }
    }
    
    var bottomText: String? {
        didSet {
            bottomLabel.text = bottomText?.count != 0 ? bottomText : "--"
        }
    }
    
    var bottomTextColor: UIColor? {
        didSet {
            bottomLabel.textColor = bottomTextColor
        }
    }
    
    lazy var topLabel: UILabel = {
        let v = UILabel(font: .Ex.regular(12), textColor: .Ex.text2)
        return v
    }()
    
    lazy var bottomLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(14), textColor: .Ex.main1)
        return v
    }()
    
    private var spaceingConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        addSubViews([topLabel, bottomLabel])
        topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        bottomLabel.snp.makeConstraints { make in
            spaceingConstraint = make.top.equalTo(topLabel.snp.bottom).offset(spacing).constraint
            make.height.equalTo(topLabel.snp.height).multipliedBy(1.143)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        topLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        bottomLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
}


class EXInviteBasicCell: UITableViewCell {
    
    var clickBlock: EXComVoidBlock?
    var ruleBlock: EXComVoidBlock?
    
    lazy var titleView: EXInviteTitleView = {
        let v = EXInviteTitleView()
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extSetCell(isRemoveSelectedBackgroundView: true)
        onCreate()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        extSetCell(isRemoveSelectedBackgroundView: true)
        backgroundColor = .Ex.fill1
        contentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)) }
        onCreate()
        bindViewModel()
    }
    
    func onCreate() {
        backgroundColor = .Ex.fill1
        contentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)) }
    }
    
    func bindViewModel() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event.asObservable().subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.clickBlock?()
        }).disposed(by: disposeBag)
        contentView.addGestureRecognizer(tapGesture)
        
        titleView.ruleButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let self else { return }
            self.ruleBlock?()
        }).disposed(by: disposeBag)
    }
    
    func setClickBlock(clickBlock: EXComVoidBlock? = nil, ruleBlock: EXComVoidBlock? = nil) {
        self.clickBlock = clickBlock
        self.ruleBlock = ruleBlock
    }
    
    func setInvitePublicConfigModel(_ config: EXInvitationPublicConfigModel?) {
        
    }
    
}

////////

protocol EXInvitationInfoTableViewCellDelegate {
    func postButtonDidClick()
    func faceToFaceButtonClickBlock()
    func addSuperiorInviteCode()
}


class EXInviteLinkCell: EXInviteBasicCell {
    
    var delegate:EXInvitationInfoTableViewCellDelegate?
    
    lazy var linkView : EXCopyInfoView = {
        let v = EXCopyInfoView()
        v.copyLabel.lineBreakMode = .byTruncatingMiddle
        return v
    }()
    
    lazy var codeView: EXCopyInfoView = {
        let v = EXCopyInfoView()
        return v
    }()
    
    lazy var addCodeView: EXCopyInfoView = {
        let v = EXCopyInfoView()
        v.isSuperior = true
        v.isHidden = true
        return v
    }()
    
    
    lazy var shareButton: EXButton = {
        let v = EXButton()
        v.selectStyle = .blueColor
        v.setTitle("generate_invitation_poster".localized(), for: .normal)
        v.isEnabled = false
        return v
    }()
    
    lazy var faceTofaceButton: UIButton = {
        let v = UIButton()
        v.setTitle("face_to_face_invitation".localized(), for: .normal)
        v.setTitleColor(.Ex.text2, for: .disabled)
        v.setTitleColor(.Ex.main1, for: .normal)
        v.titleLabel?.font = .Ex.medium(14)
        v.extSetBorderWidth(1, color: .Ex.fill5)
        v.extSetCornerRadius(4)
        v.isEnabled = false
        return v
    }()
    
    private lazy var buttonsView : UIView = {
        let v = UIView()
        return v
        
    }()
    
    private lazy var stack: UIStackView = {
        let v = UIStackView()
        v.distribution = .fill
        v.axis = .vertical
        v.spacing = 16
        return v
    }()
    
    
    override func onCreate() {
        super.onCreate()
        
        ///
        linkView.snp.makeConstraints { $0.height.equalTo(25) }
        codeView.snp.makeConstraints { $0.height.equalTo(25) }
        addCodeView.snp.makeConstraints { $0.height.equalTo(25) }
        
        contentView.addSubViews([stack, buttonsView])
        stack.addArrangedSubviews([linkView, codeView, addCodeView])
        buttonsView.addSubViews([shareButton, faceTofaceButton])
        
        ///
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        ////
        buttonsView.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-15)
            make.centerX.width.equalTo(stack)
            make.height.equalTo(44)
        }
        
        ///
        shareButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.height.equalToSuperview()
        }
        faceTofaceButton.snp.makeConstraints { make in
            make.left.equalTo(shareButton.snp.right).offset(9)
            make.right.centerY.equalToSuperview()
            make.width.height.equalTo(shareButton)
        }
        
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        addCodeView.addCodeButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self else { return }
            self.delegate?.addSuperiorInviteCode()
        }).disposed(by: disposeBag)
        
        shareButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self else { return }
            self.delegate?.postButtonDidClick()
        }).disposed(by: disposeBag)
        
        faceTofaceButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let self else { return }
            self.delegate?.faceToFaceButtonClickBlock()
        }).disposed(by: disposeBag)
    }
    
    func setCellData(_ inviteUrl:String?,_ inviteCode:String?,_ isCanAddSuperior: Bool = false) {
        linkView.setData(title: "invitation_Link".localized(), content: inviteUrl?.inviteUrlStringFormat(), paste: inviteUrl)
        codeView.setData(title: "my_invitation_code".localized(), content: inviteCode, paste: inviteCode)
        addCodeView.setData(title: "add_invite_code".localized(), content: "")
        addCodeView.isHidden = !isCanAddSuperior
        updatebuttonsDisabledIfNeed(inviteUrl?.isEmpty ?? true)
    }
    
    
    private func updatebuttonsDisabledIfNeed(_ disabled: Bool = true) {
        shareButton.isEnabled = !disabled
        faceTofaceButton.isEnabled = !disabled
        faceTofaceButton.extSetBorderWidth(1, color:  disabled ? .Ex.fill5 : .Ex.main1)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
