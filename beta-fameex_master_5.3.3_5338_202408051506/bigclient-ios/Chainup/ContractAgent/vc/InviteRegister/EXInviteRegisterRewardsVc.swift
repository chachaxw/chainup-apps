//
//  EXInviteRegisterRewardsVc.swift
//  Chainup
//
//  Created by bradjohn on 2024/3/14.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit

class EXInviteRegisterRewardsVc: NavCustomVC {
    
    lazy var containerView: EXInviteRegisterRewardsView = {
        let v = EXInviteRegisterRewardsView()
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.addSubViews([containerView])
        containerView.snp.makeConstraints { make in
            make.top.equalTo(self.navCustomView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        if let panGesture = self.navigationController?.interactivePopGestureRecognizer {
            containerView.pagingView.listContainerView.scrollView.panGestureRecognizer.require(toFail: panGesture)
            containerView.pagingView.mainTableView.panGestureRecognizer.require(toFail: panGesture)
        }
    }
    
    override func setNavCustomV() {
        super.setNavCustomV()
        self.navtype = .listtitle
        self.navCustomView.middleTitle.text = "referral_inviteRewards_title".localized()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (containerView.segmentView.selectedIndex == 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
