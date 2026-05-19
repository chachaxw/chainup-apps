//
//  EXGameAuthorVc.swift
//  Chainup
//
//  Created by ljw on 2023/3/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXGameAuthorVc: BaseVC {
    
    @IBOutlet weak var thirdLab: UILabel!
    @IBOutlet weak var nickLab: UILabel!
    @IBOutlet weak var phoneNumLab: UILabel!
    @IBOutlet weak var applyLab: UILabel!
    @IBOutlet weak var authorLoginBtn: UIButton!
    
    @IBOutlet weak var applyGetLab: UILabel!
    @IBOutlet weak var gameNameLab: UILabel!
    @IBOutlet weak var cancleBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetting()
        
    }
    func basicSetting() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.thirdLab.text = "game_thirdAuthorLogin".localized()
        self.nickLab.text = "otcSafeAlert_action_nickname".localized()
        self.applyLab.text = "game_applyInfo".localized()
        self.applyGetLab.text = "game_applyDetail".localized()
        self.cancleBtn.setTitle("game_refuse".localized(), for: UIControl.State.normal)
        self.authorLoginBtn.setTitle("game_authorLogin".localized(), for: UIControl.State.normal)
        phoneNumLab.text =  UserInfoEntity.sharedInstance().mobileNumber
        gameNameLab.text = EXGameJumpManager.shareInstance.paraDic?["gameName"] ?? ""
    }
  
   
    
    //Click on authorization, the authorization successful interface will jump back to the game app
    @IBAction func author(_ sender: UIButton) {
        
        if let gameId = EXGameJumpManager.shareInstance.paraDic?["gameId"],let token = EXGameJumpManager.shareInstance.paraDic?["gameToken"]{
        appApi.rx.request(.gameOpenUrl(gameId:gameId,token:token)).MJObjectMap(EXVoidModel.self).subscribe(onSuccess: { (m) in
            self.gotoGame()
          }) { (error) in
                       
          }.disposed(by: disposeBag)
            
        }
    }
    func gotoGame() {
        if let paraDic = EXGameJumpManager.shareInstance.paraDic,let gameScheme = paraDic["gameScheme"],let url = URL.init(string: gameScheme + "://"){
//            if  UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                else{
                    UIApplication.shared.openURL(url)
                }
//            }
            
        }
        EXGameJumpManager.shareInstance.paraDic = nil
        self.dismiss(animated: true, completion: nil)
    }
    //Cancel Authorization
    @IBAction func cancle(_ sender: UIButton) {
        EXGameJumpManager.shareInstance.paraDic = nil
        self.dismiss(animated: true, completion: nil)
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

