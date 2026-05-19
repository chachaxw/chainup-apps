//
//  EXMyRewardsViewController.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXMyRewardsViewController: NavCustomVC {

    var rewardCenterVm = EXTaskViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        self.rewardCenterVm.getRewardCenterHomeAllInfo()
    }
    //MARK: lazy
    lazy var mainView: EXRewardMianView = {
        let v = EXRewardMianView(viewModel: self.rewardCenterVm)
        return v
    }()
}


extension EXMyRewardsViewController{
    func configView(){
        configNav()
        self.contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
    }
    func configNav(){
        navtype = .listtitle
        self.lastVC = false
        self.setTitle("myReward_text2".localized())
    }
}
