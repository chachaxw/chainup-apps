//
//  EXImageButton.swift
//  Chainup
//
//  Created by bradjohn on 2024/1/1.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXImageButton: UIButton {
    
    var image: UIImage? {
        didSet {
            customImageView.image = image
        }
    }
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    var imagePosition: EXImageButtonPosition = .left {
        didSet {
            updateLayout(position: imagePosition)
        }
    }
    
    var contentInsets: UIEdgeInsets = .zero {
        didSet {
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
            layoutIfNeeded()
        }
    }
    
    var spacing: CGFloat = 4 {
        didSet {
            contentView.spacing = spacing
            layoutIfNeeded()
        }
    }
    
    lazy var textLabel: UILabel = {
        let v = UILabel()
        v.font = .Ex.regular(14)
        v.textColor = .Ex.text1
        return v
    }()
    
    lazy var customImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    
   private lazy var contentView: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.spacing = 4
        v.alignment = .center
        v.isUserInteractionEnabled = false
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
        titleLabel?.removeFromSuperview()
        imageView?.removeFromSuperview()
        clipsToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints{ $0.edges.equalToSuperview().inset(contentInsets)}
        updateLayout(position: .left)
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


extension EXImageButton {
    enum EXImageButtonPosition {
        case top
        case left
        case bottom
        case right
    }
    
    private func updateLayout(position: EXImageButtonPosition) {
        switch position {
        case .top:
            contentView.axis = .vertical
            contentView.removeAllArrangedSubviews()
            contentView.addArrangedSubviews([customImageView, textLabel])
            
        case .left:
            contentView.axis = .horizontal
            contentView.removeAllArrangedSubviews()
            contentView.addArrangedSubviews([customImageView, textLabel])
            
        case .bottom:
            contentView.axis = .vertical
            contentView.removeAllArrangedSubviews()
            contentView.addArrangedSubviews([textLabel, customImageView])
            
        case .right:
            contentView.axis = .horizontal
            contentView.removeAllArrangedSubviews()
            contentView.addArrangedSubviews([textLabel, customImageView])
        }
        layoutIfNeeded()
    }
}
