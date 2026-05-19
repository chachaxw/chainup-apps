//
//  EXReceivedRedPacketDetailVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import Swap
class EXReceivedRedPacketDetailVC: NavCustomVC {

    lazy var mainView : EXReceivedRedPacketDetailView = {
        let view = EXReceivedRedPacketDetailView()
        view.extUseAutoLayout()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addSubview(mainView)
        self.view.bringSubviewToFront(self.navCustomView)
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        //Leave blank at the top of the solution tableview
        if #available(iOS 11.0, *) {
            mainView.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func setNavCustomV() {
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

