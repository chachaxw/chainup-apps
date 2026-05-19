//
//  EXDirectionSelector.swift
//  Chainup
//
//  Created by liuxuan on 2020/10/29.
//  Copyright © 2020 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

open class EXDirectionSelector: UIControl {
    
    public var contentAlignment:NSTextAlignment {
        didSet{
            updateContentLayout()
        }
    }
    
    public var textAlignment:NSTextAlignment {
        get { titleLabel.textAlignment }
        set {
            guard textAlignment != newValue else { return }
            titleLabel.textAlignment = newValue
            updateContentLayout()
        }
    }
    
    public var isOn:Bool = false {
        didSet {
            if isOn {
                icon.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }else {
                icon.transform = CGAffineTransform.identity
            }
        }
    }
    //
    public override var intrinsicContentSize: CGSize {
        let iconSize = self.iconSize
        let titleSize = titleLabel.intrinsicContentSize
        //
        var width = titleSize.width + iconTitleSpacing + iconSize.width
        var height = max(titleSize.height, iconSize.height)
        //
        let inset = self.contentInsets
        width += inset.left + inset.right
        height += inset.top + inset.bottom
        //
        let size = CGSize(width: width, height: height)
        return size
    }
    //
    public var iconSize:CGSize = CGSize(width: 16, height: 16) {
        didSet {
            icon.snp.updateConstraints({ make in
                make.size.equalTo(iconSize)
            })
            updateContentLayout()
        }
    }
    
    private lazy var contentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel,icon])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = iconTitleSpacing
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    public var iconTitleSpacing:CGFloat = 4 {
        didSet {
            contentView.spacing = iconTitleSpacing
            updateContentLayout()
        }
    }
    
    public var preferedSize: CGSize { intrinsicContentSize }
    
    public var contentInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12) {
        didSet {
            updateContentLayout()
        }
    }
    
    public lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.ThemeFont.BodyMedium
        label.textColor = UIColor.ThemeLabel.colorLite
        label.rx.methodInvoked(#selector(UIView.invalidateIntrinsicContentSize)).subscribe(onNext: { [weak self] _ in
            self?.invalidateIntrinsicContentSize()
        }).disposed(by: disposeBag)
        return label
    }()
    
    public lazy var icon:UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.image = UIImage.themeImageNamed(imageName:"coins_drop_down")
        return icon
    }()
    
    public required init(frame: CGRect = .zero, alignment: NSTextAlignment = .left) {
        self.contentAlignment = alignment
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.contentAlignment = .left
        super.init(coder: aDecoder)
        config()
    }
    
    open func config() {
        self.extSetCornerRadius(4)
        self.extSetBorderWidth(1/UIScreen.main.scale, color: UIColor.ThemeView.border)
        icon.snp.makeConstraints { (make) in
            make.size.equalTo(iconSize)
        }
        addSubview(contentView)
        updateContentLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(normalStyle), name:  NSNotification.Name.init("EXSheetDissmissed"), object: nil)
        EXKitAlert.sheetCloseSubject
            .asObserver()
            .bind(to: self.rx.isOn)
            .disposed(by: self.disposeBag)
    }
    
    @objc public func normalStyle() {
        setOn(false, animated: true)
    }
    
    
    public func hideBorder() {
        self.extSetCornerRadius(0)
        self.extSetBorderWidth(0, color: UIColor.clear)
    }
    
    public func updateContentLayout() {
        switch contentAlignment {
        case .center:
            if textAlignment == .center && !icon.isHidden {
                contentView.snp.remakeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.centerX.equalToSuperview().offset((iconTitleSpacing + iconSize.width) / 2)
                }
            }else{
                contentView.snp.remakeConstraints { make in
                    make.center.equalToSuperview()
                }
            }
        default:
            var inset = contentInsets
            if textAlignment == .center && !icon.isHidden {
                inset.left += iconSize.width + iconTitleSpacing
            }
            contentView.snp.remakeConstraints { make in
                make.edges.equalTo(inset)
            }
        }
        invalidateIntrinsicContentSize()
    }

    public func setOn(_ on: Bool, animated: Bool) {
        guard on != self.isOn else { return }
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.isOn = on
        }
    }
}


extension Reactive where Base: EXDirectionSelector {
    
    public var isOn: Binder<Bool> {
        return Binder(self.base) { selector, isOn in
            selector.setOn(isOn, animated: true)
        }
    }
}
