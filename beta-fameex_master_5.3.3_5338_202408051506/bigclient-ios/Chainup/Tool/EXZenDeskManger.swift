//
//  EXZenDeskManger.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/4/7.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import ZendeskSDKMessaging
import ZendeskSDK
import ZendeskSDKLogger
import EXKit
class EXZenDeskManger: NSObject {
    static let manger = EXZenDeskManger()
    private override init() {}
    var inited: Bool = false
    
    func initSDK(){
        if inited {
            return
        }
//        let channelkey = "eyJzZXR0aW5nc191cmwiOiJodHRwczovL25ld2J0MS56ZW5kZXNrLmNvbS9tb2JpbGVfc2RrX2FwaS9zZXR0aW5ncy8wMUcwMTFGQlJNRVpWQ1hBUkozQ0dLQk1OQS5qc29uIn0="
        let channelkey = "eyJzZXR0aW5nc191cmwiOiJodHRwczovL2JpdGJyZXguemVuZGVzay5jb20vbW9iaWxlX3Nka19hcGkvc2V0dGluZ3MvMDFINlJBR0FSUFRSMjJFRVk1V1RCRFcwNjUuanNvbiJ9"
//        Logger.enabled = true
//        Logger.level = .default
        Zendesk.initialize(withChannelKey: channelkey,
                           messagingFactory: DefaultMessagingFactory()) { [weak self] result in
                if case let .failure(error) = result {
                    self?.inited = false
                    print("Messaging did not initialize.\nError: \(error.localizedDescription)")
                }else{
                    self?.inited = true
                    print("Messaging success")
                }
            }
    }
    func goToNext(){
        guard let vc = TopVC() else {return}
        if EXAppConfigManager.sharedInstance.didOpenServiceOnline(){
            guard let viewController = Zendesk.instance?.messaging?.messagingViewController() else { return }
            
            let v = NavCustomVC()
            v.addChild(viewController)
            v.contentView.addSubview(viewController.view)
            viewController.view.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-EXSafeAreaBottom)
            }
            vc.navigationController?.pushViewController(v, animated: true)
        }else{
            let web = WebVC()
            web.loadUrl(EXAppConfigManager.sharedInstance.getOnlineServiceURL())
            vc.navigationController?.pushViewController(web, animated: true)
        }
    }
}

