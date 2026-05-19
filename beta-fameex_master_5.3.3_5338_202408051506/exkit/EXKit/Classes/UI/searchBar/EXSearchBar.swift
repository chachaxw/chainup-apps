//
//  EXSearchBar.swift
//  Blueprints
//
//  Created by cwd on 2023/6/19.
//

import UIKit
import SnapKit
public class EXSearchBarView: EXBaseView {
    
    public var toContract: Bool = false
    
    public var jumpCallBack: EXComBoolBlock?
    
    public var textDidChange: EXComStringBlock?
    
    public var cancelCallback: EXComVoidBlock?
    
    public var isShowCancel: Bool = false {
        didSet {
            updateLayout(with: isShowCancel)
        }
    }
    
    public var cancenTextColor: UIColor = .Ex.main4 {
        didSet {
            cancelButton.setTitleColor(cancenTextColor, for: .normal)
        }
    }
    
    public var searchContainerInsets: UIEdgeInsets = .zero {
        didSet {
            guard searchContainer.superview != nil else { return }
            updateLayout(with: searchContainerInsets)
        }
    }
    
    public var placeHolder: String = "" {
        didSet{
            textfield.setPlaceHolderAtt(placeHolder, color: .Ex.text3, font: 14,weight: .medium)
        }
    }
    //不可搜索跳转下一页
    public var canSearch: Bool = true{
        didSet{
            self.coverBtn.isHidden = canSearch
            self.textfield.isUserInteractionEnabled = canSearch
        }
    }
    
    public override func setData() {
        super.setData()
        textfield.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] text in
                self?.textDidChange?(text)
            }).disposed(by: self.disposeBag)
    }
    
    
    public override func setSubView(){
        super.setSubView()
        backgroundColor = .Ex.fill3
        extSetCornerRadius(16)
        searchContainer.extSetCornerRadius(16)
        contentInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        contentView.addSubViews([searchContainer, cancelButton])
        searchContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        cancelButton.snp.removeConstraints()
        searchContainer.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        
        ///
        searchContainer.addSubViews([searchIcon, textfield, coverBtn])
        searchIcon.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.width.equalTo(20)
            make.centerY.equalToSuperview()
        }
        textfield.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right).offset(8)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        coverBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateLayout(with isShow: Bool)  {
        cancelButton.isHidden = !isShow
        if isShow {
            searchContainer.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            cancelButton.snp.remakeConstraints { make in
                make.left.equalTo(searchContainer.snp.right).offset(16)
                make.right.equalToSuperview()
                make.height.lessThanOrEqualToSuperview()
                make.centerY.equalToSuperview()
            }
        } else {
            searchContainer.snp.remakeConstraints { make in
                make.edges.equalToSuperview().inset(searchContainerInsets)
            }
        }
    }
    
    func updateLayout(with insets: UIEdgeInsets = .zero) {
        searchIcon.snp.updateConstraints { $0.left.equalToSuperview().offset(insets.left) }
        textfield.snp.updateConstraints { $0.right.equalToSuperview().offset(-insets.right) }
    }
    
    //MARK: lazy
    private lazy var searchIcon :UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.image = EXKitBundle.image(named: "public_search")
        return v
    }()
    
    private let textfield: UITextField  = {
        let v = UITextField()
        v.textColor = .Ex.text1
        v.font = UIFont.Ex.medium(14)
        v.setModifyClearButton()
        return v
    }()
    
    private lazy var coverBtn:UIButton = {
        let v = UIButton()
        v.addTarget(self, action: #selector(jump), for: .touchUpInside)
        v.isHidden = true
        return v
    }()
    
    /// the parent of icon and textfield
   public lazy var searchContainer: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var cancelButton: EXButton = {
        let v = EXButton(type: .custom)
        v.isHidden = true
        v.extUseAutoLayout()
        v.selectStyle = .blueTextColor
        v.setTitle("common_text_btnCancel".localized(), for: .normal)
        v.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        v.setEnlargeEdgeWithTop(8, left: 8, bottom: 8, right: 8)
        return v
    }()
    
    //MARK: action
    @objc func jump(){
        self.jumpCallBack?(self.toContract)
    }
    
    @objc func cancelAction() {
        self.cancelCallback?()
    }
     
   public func clear() {
        textfield.text = ""
    }
    
}

extension EXSearchBarView: EXTextFieldProtocol {
    public var textField: UITextField { textfield }
}
