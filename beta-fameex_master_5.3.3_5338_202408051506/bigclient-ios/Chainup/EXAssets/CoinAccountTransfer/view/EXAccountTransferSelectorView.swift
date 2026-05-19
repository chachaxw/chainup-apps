//
//  EXAccountTransferSelectorView.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit
class EXAccountTransferSelectorView: UIView {
   
    var accountType:EXAccountType?
    
    lazy var titleLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(16), textColor: .Ex.text1)
        return v
    }()
    
    lazy var iconView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.image = EXKitBundle.image(named: "public_arrow_down")
        return v
    }()
    
    lazy var tapBtn: UIButton = {
        let v = UIButton(type: .custom)
        return v
    }()
    
    
    typealias SelectorDidTapCallback = () -> ()
    var onSelectorTapped:SelectorDidTapCallback?
    
    var enableTap:Bool = false {
        didSet {
            iconView.isHidden = !enableTap
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
    }
    
    
    func onCreate() {
        addSubViews([titleLabel, iconView, tapBtn])
        ///
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
        }
        iconView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.lessThanOrEqualTo(CGSizeMake(10, 10))
        }
        tapBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        tapBtn.rx.controlEvent(.touchUpInside).subscribe(onNext:{ [weak self] in
            guard let self else { return }
            self.didTapped()
        }).disposed(by: disposeBag)
       
        EXAlert.sheetCloseSubject.asObserver()
            .bind(to: self.rx.isShowing).disposed(by: disposeBag)
    }
    
     func didTapped() {
        if enableTap {
            self.clockwiseRotation(true)
            onSelectorTapped?()
        }
    }
    
    func clockwiseRotation(_ rotation:Bool) {
        if self.enableTap {
            UIView.animate(withDuration: 0.2) {
                if rotation {
                    self.iconView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }else {
                    self.iconView.transform = CGAffineTransform.identity
                }
            }
        }
    }
}

extension Reactive where Base: EXAccountTransferSelectorView {
    
    var isShowing: Binder<Bool> {
        return Binder(self.base) { selector, isShow in
            selector.clockwiseRotation(isShow)
        }
    }
}
