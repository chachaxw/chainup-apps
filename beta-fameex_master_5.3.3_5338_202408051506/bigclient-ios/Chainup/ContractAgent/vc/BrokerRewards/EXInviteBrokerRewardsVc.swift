//
//  EXInviteBrokerRewardsVc.swift
//  Chainup
//
//  Created by bradjohn on 2024/3/14.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit

class EXInviteBrokerRewardsVc: NavCustomVC {
    lazy var containerView: EXInviteBrokerRewardsView = {
        let v = EXInviteBrokerRewardsView()
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
        containerView.updateNavigationTitleCallback = { [weak self] result in
            guard let self else { return }
            self.navCustomView.middleTitle.text = result ? "合约经纪人".localized() : ""
        }
        if let panGesture = self.navigationController?.interactivePopGestureRecognizer {
            containerView.pagingView.listContainerView.scrollView.panGestureRecognizer.require(toFail: panGesture)
            containerView.pagingView.mainTableView.panGestureRecognizer.require(toFail: panGesture)
        }
    }
    
    override func setNavCustomV() {
        super.setNavCustomV()
        self.navtype = .listtitle
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
