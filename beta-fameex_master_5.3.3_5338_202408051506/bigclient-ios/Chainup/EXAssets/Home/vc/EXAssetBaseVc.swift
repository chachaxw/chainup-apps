//
//  EXAssetBaseVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXAssetBaseVc: BaseVC {
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    typealias AssetUpdateCallback = (EXCommonAssetModel) -> ()
    var onAssetupdate:AssetUpdateCallback?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func updatePrivacy() {
        
    }

}
