//
//  TagViewController.swift
//  EXKit_Example
//
//  Created by cwd on 2023/6/14.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EXKit
class TagViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .Ex.fill1
        let types = AuthStatus.allCases
        var y = navBarHeight() + 100
        for t in types{
            let item = EXNewTagView()
            item.authType = t
            self.view.addSubview(item)
            item.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(y)
            }
            y += 50
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
