//
//  EXSearchBar.swift
//  Blueprints
//
//  Created by cwd on 2023/6/19.
//

import UIKit
import SnapKit
public class EXSearchBarView: EXBaseView {
    public var jumpCallBack: EXComVoidBlock?
    public var textDidChange: EXComStringBlock?
    public var placeHolder: String = ""{
        didSet{
            textfield.setPlaceHolderAtt(placeHolder, color: UIColor.Ex.text3, font: 12,weight: .medium)
        }
    }
    //不可搜索跳转下一页
    public var canSearch: Bool = true{
        didSet{
            self.coverBtn.isHidden = canSearch
            self.textfield.isUserInteractionEnabled = canSearch
        }
    }
    public override func setSubView(){
        self.backgroundColor = .Ex.fill3
        self.corneradius = 16
        addSubview(searchIcon)
        addSubview(textfield)
        addSubview(coverBtn)
        textfield.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] text in
                self?.textDidChange?(text)
            }).disposed(by: self.disposeBag)
        searchIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.height.width.equalTo(20)
            make.centerY.equalToSuperview()
        }
        textfield.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right).offset(12)
            make.height.equalTo(14)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
        coverBtn.snp.makeConstraints { make in
            make.edges.equalTo(textfield)
        }
    }
    
    
    //MARK: lazy
   private lazy var searchIcon :UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = EXKitBundle.image(named: "public_search")
        return img
    }()
    private let textfield: UITextField  = {
        let tf = UITextField()
        tf.textColor = .Ex.text1
        tf.font = UIFont.Ex.medium(12)
        tf.setModifyClearButton()
        return tf
    }()
    
    private lazy var coverBtn:UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(jump), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    //MARK: action
    @objc func jump(){
        self.jumpCallBack?()
    }
}
