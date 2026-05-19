//
//  EXSendRedPacketVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSendRedPacketVC: NavCustomVC {
    
    var sendVC = EXSendOutRedPacketListVC()
    
    var receivedVC = EXReceivedRedPacketListVC()
    
    func createSendVC(){
        sendVC = EXSendOutRedPacketListVC()
        sendVC.clickPushBlock = {[weak self]() in
            guard let mySelf = self else{return}
            mySelf.createreceivedVC()
            mySelf.navigationController?.pushViewController(mySelf.receivedVC, animated: true)
        }
    }
    
    func createreceivedVC(){
        receivedVC = EXReceivedRedPacketListVC()
        receivedVC.clickPushBlock = {[weak self]() in
            guard let mySelf = self else{return}
            mySelf.createSendVC()
            mySelf.navigationController?.pushViewController(mySelf.sendVC, animated: true)
            
        }
    }
    
    var entity = EXRedPakcetPublicInfoEntity()
    {
        didSet{
            spellLuckView.redPakcetPublicInfoEntity = entity
            normalView.redPakcetPublicInfoEntity = entity
        }
    }
    
    var arr = ["redpacket_sendout_sendPackets".localized(),"redpacket_received_received".localized()]
    
    lazy var rightBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.extSetAddTarget(self, #selector(clickRightBtn))
        btn.setImage(UIImage.themeImageNamed(imageName: "menu"), for: UIControl.State.normal)
        return btn
    }()
    
    //toolbar
    lazy var toolView : EXSendRedPacketToolView = {
        let view = EXSendRedPacketToolView()
        view.extUseAutoLayout()
        view.clickBtnBlock = {[weak self]tag in
            guard let mySelf = self else{return}
            mySelf.spellLuckView.isHidden = tag == 1
            mySelf.spellLuckView.reloadView()

            mySelf.normalView.isHidden = !mySelf.spellLuckView.isHidden
            mySelf.normalView.reloadView()
        }
        return view
    }()
    
    //Pai Shou Qi Red Envelope
    lazy var spellLuckView : EXSendRedPacketView = {
        let view = EXSendRedPacketView()
        view.extUseAutoLayout()
        view.type = .spellLuck
        return view
    }()
    
    //Ordinary red envelope
    lazy var normalView : EXSendRedPacketView = {
        let view = EXSendRedPacketView()
        view.extUseAutoLayout()
        view.type = .normal
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        createSendVC()
        createreceivedVC()
        // Do any additional setup after loading the view.
        contentView.addSubViews([toolView,spellLuckView,normalView])
        toolView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(44)
        }
        spellLuckView.snp.makeConstraints { (make) in
            make.top.equalTo(toolView.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
        normalView.snp.makeConstraints { (make) in
            make.top.equalTo(toolView.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
        
        EXRedPakcetPublicInfo.sharedInstance.getData {
            self.entity = EXRedPakcetPublicInfo.sharedInstance.entity
            let firstSpellLuck = EXRedPakcetPublicInfo.sharedInstance.getFirstSpellLuck()
            if firstSpellLuck != nil{
                self.spellLuckView.setView(firstSpellLuck!)
            }
            let firstNormal = EXRedPakcetPublicInfo.sharedInstance.getNormal()
            if firstNormal != nil{
                self.normalView.setView(firstNormal!)
            }
        }
        
    }
    
    override func setNavCustomV() {
        
        self.navCustomView.addSubview(rightBtn)
        rightBtn.snp.makeConstraints { (make) in
            make.height.equalTo(4)
            make.width.equalTo(16)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(self.navCustomView.popBtn)
        }
        
    }
    
    //Click on the button in the upper right corner
    @objc func clickRightBtn(){
        
        let sheet = EXOldActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            switch idx {
            case 0://Red envelopes sent out
                mySelf.createSendVC()
                mySelf.navigationController?.pushViewController(mySelf.sendVC, animated: true)
            case 1://Received red envelopes
                mySelf.createreceivedVC()
                mySelf.navigationController?.pushViewController(mySelf.receivedVC, animated: true)
            default:
                break
            }
        }
        sheet.configButtonTitles(buttons:  arr)
        EXAlert.showSheet(sheetView: sheet)   
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

