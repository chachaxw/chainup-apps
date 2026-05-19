//
//  EXSendOutRedPacketListVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSendOutRedPacketListVC: NavCustomVC {
    
    typealias ClickPushBlock = () -> ()
    var clickPushBlock : ClickPushBlock?
    
    var arr = ["redpacket_sendout_sendPackets".localized(),"redpacket_received_received".localized()]
    
    lazy var rightBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.extSetAddTarget(self, #selector(clickRightBtn))
        btn.setImage(UIImage.themeImageNamed(imageName: "menu"), for: UIControl.State.normal)
        return btn
    }()
    
    lazy var mainView : EXSendOutRedPacketListView = {
        let view = EXSendOutRedPacketListView()
        view.extUseAutoLayout()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.addSubViews([mainView])
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    //Click on the button in the upper right corner
    @objc func clickRightBtn(){
        
        let sheet = EXOldActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            
            switch idx {
            case 1://Received red envelopes
                mySelf.popBack(false)
                mySelf.clickPushBlock?()
            default:
                break
            }
        }
        sheet.configButtonTitles(buttons:  arr)
        EXAlert.showSheet(sheetView: sheet)
    }
    
    override func setNavCustomV() {
        self.xscrollView = mainView.tableView
        self.setTitle("redpacket_sendout_sendPackets".localized())
        self.navCustomView.addSubview(rightBtn)
        rightBtn.snp.makeConstraints { (make) in
            make.height.equalTo(4)
            make.width.equalTo(16)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(self.navCustomView.popBtn)
        }
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

