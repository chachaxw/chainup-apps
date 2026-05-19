//
//  ThemeUpdater.swift
//  EXKit_Example
//
//  Created by zq on 2023/7/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EXKit

private class EXFloatingButton: UIWindow, EXSwiftLoadProtocol {
    static var shared:EXFloatingButton?
    static var token:NSObjectProtocol = NSObject()
    static func swiftLoad() {
        token = NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: nil) { _ in
            shared = EXFloatingButton()
            NotificationCenter.default.removeObserver(token)
        }
    }
    let viewController:UIViewController = RootViewController()
    private static let size = CGSize(width: 50, height: 50)
    init() {
        super.init(frame:CGRect(origin: CGPoint(x: Device_W - Self.size.width, y:Device_H - TABBAR_H - Self.size.height), size: Self.size))
        rootViewController = viewController
        windowLevel = .alert + 100
        isHidden = false
        corneradius = 25
        let panGestureRecognizer = UIPanGestureRecognizer()
        addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.rx.event
            .filter({ $0.state == .changed })
            .subscribe { [weak self] (panGestureRecognizer:UIPanGestureRecognizer) in
            guard let `self` = self else { return }
            let point = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            panGestureRecognizer.setTranslation(.zero, in: panGestureRecognizer.view)
            self.centerX += point.x
            self.centerY += point.y
            self.adjustPosition()
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(UIApplication.didChangeStatusBarOrientationNotification).subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            self.adjustPosition()
        }).disposed(by: disposeBag)
    }
    
    func adjustPosition() {
        let safeAreaInset = EXSafeAreaInsets()
        //
        var center = self.center
        //
        center.x = max(center.x, Self.size.width / 2)
        center.x = min(center.x, UIScreen.main.bounds.width - Self.size.width / 2 - safeAreaInset.right)
        //
        center.y = max(center.y, safeAreaInset.top + Self.size.height / 2)
        center.y = min(center.y, UIScreen.main.bounds.height - safeAreaInset.bottom - Self.size.height / 2)
        //
        self.center = center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class RootViewController: UIViewController {
        let titleLabel: UILabel = UILabel(font: .Ex.medium(15), textColor: .Ex.text4, alignment: .center)
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .Ex.main1
            view.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            updateTheme()
            //
            let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.rx.event
                .filter({ $0.state == .ended })
                .subscribe(onNext: {[weak self] _ in
                (EXTheme.isDark ? EXTheme.light : EXTheme.dark).active()
                self?.updateTheme()
            }).disposed(by: disposeBag)
            view.addGestureRecognizer(tapGestureRecognizer)
        }
        func updateTheme() {
            titleLabel.text = EXTheme.isDark ? "Dark" : "Light"
        }
    }
}


protocol EXThemeViewControllerProtocol {
    func observerThemeChanging()
}

extension EXThemeViewControllerProtocol where Self:UIViewController {
    func observerThemeChanging() {
        NotificationCenter.default.rx.notification(EXTheme.didUpdateNotification).subscribe(onNext: { [weak self] _ in
            self?.updateTheme()
        }).disposed(by: disposeBag)
    }
    func updateTheme() {
        guard var viewControllers = navigationController?.viewControllers else { return }
        guard let index = viewControllers.firstIndex(of: self) else { return }
        viewControllers[index] = Self.init()
        navigationController?.setViewControllers(viewControllers, animated: false)
    }
}


extension UIViewController:EXSwiftLoadProtocol {
    public static func swiftLoad() {
        guard let method1 = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.viewDidLoad)) else { return }
        guard let method2 = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.swizzled_theme_viewDidLoad))  else { return }
        method_exchangeImplementations(method1, method2)
    }
    @objc func swizzled_theme_viewDidLoad() {
        swizzled_theme_viewDidLoad()
        if let themeViewController = self as? EXThemeViewControllerProtocol {
            themeViewController.observerThemeChanging()
        }
    }
}

extension InputViewController     : EXThemeViewControllerProtocol {}
extension ButtonViewController    : EXThemeViewControllerProtocol {}
extension AlertViewController     : EXThemeViewControllerProtocol {}
extension TagViewController       : EXThemeViewControllerProtocol {}
extension PopoverViewController   : EXThemeViewControllerProtocol {}
extension SkeletonViewController  : EXThemeViewControllerProtocol {}
extension SearchBarViewController : EXThemeViewControllerProtocol {}
extension EXColorTableViewController : EXThemeViewControllerProtocol {}
