//
//  EXHomeViews.swift
//  Chainup
//
//  Created by cwd on 2023/8/26.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXHomeNavBar : UIView{
    
    func reloadLan(){
        searchBar.placeHolder = "market_search_ex".localized()
    }
    lazy var searchBar: EXSearchBarView = {
        let s = EXSearchBarView()
        s.placeHolder = "market_search_ex".localized()
        s.canSearch = false
        return s
    }()
    
    lazy var msgBtn:RepeatButton = {
        let btn = RepeatButton(type: .custom)
        btn.setImage(UIImage.themeImageNamed(imageName: "home_news"), for: .normal)
        btn.addTarget(self, action: #selector(clickMailBtn), for: .touchUpInside)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    lazy var redView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.extSetCornerRadius(3)
        view.backgroundColor = .Ex.fall1
        view.isHidden = true
        return view
    }()
    
    lazy var qrBtn:RepeatButton = {
        let btn = RepeatButton(type: .custom)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(UIImage.themeImageNamed(imageName: "home_scancode"), for: .normal)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.isHidden = true
        return btn
    }()

    lazy var seperator :UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    lazy var userBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.extUseAutoLayout()
        btn.extSetAddTarget(self, #selector(clickUserBtn))
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeNav.bg
        seperator.alpha = 0.0
        addSubViews([searchBar,msgBtn,redView,qrBtn,userBtn,seperator])
        configUserBtn()
        msgBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(20)
            make.centerY.equalTo(userBtn)
        }
        
        redView.snp.makeConstraints { (make) in
            make.height.width.equalTo(6)
            make.left.equalTo(msgBtn.snp.right).offset(-1)
            make.top.equalTo(msgBtn.snp.top).offset(0)
        }
        
        qrBtn.snp.makeConstraints { (make) in
            make.right.equalTo(msgBtn.snp.left).offset(-12)
            make.width.height.equalTo(20)
            make.centerY.equalTo(userBtn)
        }
        
        userBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.height.width.equalTo(28)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        searchBar.snp.makeConstraints { (make) in
            make.left.equalTo(userBtn.snp.right).offset(12)
            make.right.equalTo(msgBtn.snp.left).offset(-12)
            make.height.equalTo(32)
            make.centerY.equalTo(userBtn)
        }
        
        seperator.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
    
    func configUserBtn() {
        if XUserDefault.isOffLine() {
            userBtn.setImage(UIImage.themeImageNamed(imageName: "headportrait1"), for: .normal)
            userBtn.setImage(UIImage.themeImageNamed(imageName: "headportrait1"), for:.selected)
        }else {
            let image = UIImage.svgImage(named: "headportrait1")
            userBtn.setImage(image, for: .normal)
            userBtn.setImage(image, for:.selected)
        }
    }
    
    @objc func clickMailBtn() {
        if XUserDefault.isOffLine() {
            BusinessTools.modalLoginVC()
            return
        }
        let vc = EXAppMailVC()
        self.yy_viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    

    @objc func clickUserBtn(){
        guard let navigationController = yy_viewController?.navigationController else { return }
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .linear)
        transition.type = .moveIn
        transition.subtype = .fromLeft
        navigationController.view.layer.add(transition, forKey: "userCenterTransition")
        navigationController.pushViewController(EXMEVC(), animated: false)
        navigationController.transitionCoordinator?.animate(alongsideTransition: { (context:UIViewControllerTransitionCoordinatorContext) in
            
        }, completion: { (context:UIViewControllerTransitionCoordinatorContext) in
            
        })
    }
    
    
    func dealScanBtn(show:Bool){
        if (show == true){
            searchBar.snp.updateConstraints({ make in
                make.right.equalTo(msgBtn.snp.left).offset(-(12 + 12 + 20))
                make.height.equalTo(32)
                make.centerY.equalTo(userBtn)
            })
            
            qrBtn.isHidden = false
        }
    }
    
    func showMessageRedDot(show:Bool)  {
        redView.isHidden = !show
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

