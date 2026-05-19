//
//  EXSendOutRedPacketDetailVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import Swap
class EXSendOutRedPacketDetailVC: NavCustomVC {
    
    lazy var mainView : EXSendOutRedPacketDetailView = {
        let view = EXSendOutRedPacketDetailView()
        view.extUseAutoLayout()
        view.noShowShareBlock = {[weak self] in
            self?.shareBtn.isHidden = true
        }
        return view
    }()
    
    lazy var shareBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.setImage(UIImage.themeImageNamed(imageName: "share"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickShareBtn))
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(mainView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.view.bringSubviewToFront(self.navCustomView)
        
        //Leave blank at the top of the solution tableview
        if #available(iOS 11.0, *) {
            mainView.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    //Click on the share button
    @objc func clickShareBtn(){
        let view = EXRedPacketDetailView()
        let entity = EXCreateRedPacketEntity()
        entity.shareUrl = mainView.entity.url
        entity.nickName = mainView.entity.nickName
        entity.coinSymbol = mainView.entity.coinSymbol
        entity.background = mainView.entity.background
        view.setView(entity)
        view.show(self)
    }
    
    override func setNavCustomV() {
        self.navCustomView.backView.addSubview(shareBtn)
        shareBtn.snp.makeConstraints { (make) in
            make.height.equalTo(17)
            make.width.equalTo(18)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        self.navCustomView.backgroundColor = UIColor.ThemeRedPacket.normalRed
        self.xscrollView = mainView.tableView
        self.navCustomView.popBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_return"), for: UIControl.State.normal)
        self.setTitle("redpacket_received_detail".localized())
        self.navCustomView.middleTitle.textColor = UIColor.white
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

