//
//  EXDropDownSelector.swift
//  Pods
//
//  Created by bradjohn on 2024/5/8.
//

import UIKit

public class EXDropDownSelector: UIView {
    
    public var clickedBlock: (() -> Void)?
    
    public var isAimated: Bool = false
    
    public var contentInset: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            guard contentView.superview != nil else { return }
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInset) }
        }
    }
    
    public lazy var titleTextField: UITextField = {
        let v = UITextField()
        v.isEnabled = false
        v.font = .Ex.medium(14)
        v.textColor = .Ex.text1
        v.newSetPlaceHolderAtt("", color: .Ex.text3, font: .Ex.medium(14))
        return v
    }()
    
    public lazy var detailTextField: UITextField = {
        let v = UITextField()
        v.isEnabled = false
        v.font = .Ex.medium(14)
        v.textColor = .Ex.text1
        v.newSetPlaceHolderAtt("", color: .Ex.text3, font: .Ex.medium(14))
        return v
    }()
    
    public lazy var arrowImgV: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = true
        v.image = EXKitBundle.image(named: "public_arrow_down")
        return v
    }()
    
    public lazy var leftView: EXStackView = {
        let v = EXStackView()
        v.separatorConfiguration = nil
        v.axis = .horizontal
        v.alignment = .center
        v.distribution = .fill
        v.spacing = 4
        return v
    }()
    
    public lazy var rightView: EXStackView = {
        let v = EXStackView()
        v.separatorConfiguration = nil
        v.axis = .horizontal
        v.alignment = .center
        v.spacing = 4
        v.distribution = .fillProportionally
        return v
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
        onBindViewModel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
        onBindViewModel()
    }
    
    func onCreate() {
        backgroundColor = .Ex.special2
        extSetCornerRadius(4)
        addSubViews([contentView])
        contentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(contentInset) }
        contentView.addSubViews([leftView, rightView])
        leftView.addArrangedSubviews([titleTextField])
        rightView.addArrangedSubviews([detailTextField, arrowImgV])
        ///
        leftView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
        }
        rightView.snp.makeConstraints { make in
            make.left.equalTo(leftView.snp.right).offset(4)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
        }
        leftView.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func onBindViewModel() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickedAction))
        addGestureRecognizer(tap)
    }
    
    @objc func clickedAction() {
        updateArrowAnimatedIfNeeded(with: true)
        self.clickedBlock?()
    }
    
    private func updateArrowAnimatedIfNeeded(with isOpen: Bool) {
        if isAimated == false {
            return
        }
        UIView.animate(withDuration: 0.2) {
            self.arrowImgV.transform = isOpen ? .init(rotationAngle: .pi) : .identity
        }
    }
    
   public func updateIfNeeded(title: String? = nil, detail: String? = nil) {
       resetArrowAnimatedIfNeeded()
       titleTextField.text = title
       detailTextField.text = detail
    }
    
    public func resetArrowAnimatedIfNeeded() {
        updateArrowAnimatedIfNeeded(with: false)
    }
    
   
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
