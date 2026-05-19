//
//  EXCustomToast.swift
//  Chainup
//
//  Created by cwd on 2022/6/13.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift

class EXCustomToast: EXCustomBaseView {
    
    
    static let toastTimeInterval: TimeInterval = 3.0
    fileprivate var duration: TimeInterval = 3.0
    var upTimer: Timer?
    
    //Copy display
    lazy var content: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        v.numberOfLines = 0
        v.font = UIFont.ThemeFont.BodyRegular
        v.textColor = .white
        return v
    }()
    //Bottom spacing
    lazy var bottomSpace: UILabel = {
        let v = UILabel()
        return v
    }()
    
    lazy var container: UIStackView = {
        let v = UIStackView()
        v.distribution = .fill
        v.axis = .vertical
        v.alignment = .center
        v.backgroundColor = UIColor.ThemeState.normal //UIColor.ThemeView.mask //UIColor.extColorWithHex("#313E55")//UIColor.red
        return v
    }()
    
    convenience init(duration: Double) {
        self.init(frame: CGRect.zero)
        self.duration = duration
        scheduleUpTimer(duration)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func setSubView() { 
        self.backgroundColor = .clear
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.greaterThanOrEqualToSuperview().offset(40)
            make.right.lessThanOrEqualToSuperview().offset(-40)
            make.center.equalToSuperview()
        }
        container.addArrangedSubview(content)
        container.addArrangedSubview(bottomSpace)
        content.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(14)
        }
        //seize a seat
        bottomSpace.snp.makeConstraints { make in
            make.height.equalTo(14)
        }
    }
   
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.roundCorners(corners: .allCorners, radius: 4)
    }
    
    
    
    //MARK: lazy
    
    
    fileprivate func scheduleUpTimer(_ after: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                self.removeFromSuperview()
            }
        }
    }
    
    fileprivate func scheduleUpTimer(_ after: Double, interval: Double) {
        stopUpTimer()
        upTimer = Timer.scheduledTimer(withTimeInterval: after, repeats: false, block: {_ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                self.removeFromSuperview()
            }
        })
    }
    
    
    fileprivate func stopUpTimer() {
        upTimer?.invalidate()
        upTimer = nil
    }
    
    @objc func upFromTimer(_ timer: Timer) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.removeFromSuperview()
        }
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        stopUpTimer()
        removeFromSuperview()
    }
    deinit {
        stopUpTimer()
        NotificationCenter.default.removeObserver(self)
    }
}
extension EXCustomToast{
    class func showMsg(msg: String){
        UIApplication.shared.keyWindow?.endEditing(true)
        let v = EXCustomToast(duration: 2.0)
        v.content.text = msg
        v.frame = UIScreen.main.bounds
        UIApplication.shared.keyWindow?.addSubview(v)
    }

}

