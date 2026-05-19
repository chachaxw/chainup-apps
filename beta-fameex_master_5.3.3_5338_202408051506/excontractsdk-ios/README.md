# Swap

[![CI Status](https://img.shields.io/travis/柴伟东/Swap.svg?style=flat)](https://travis-ci.org/柴伟东/Swap)
[![Version](https://img.shields.io/cocoapods/v/Swap.svg?style=flat)](https://cocoapods.org/pods/Swap)
[![License](https://img.shields.io/cocoapods/l/Swap.svg?style=flat)](https://cocoapods.org/pods/Swap)
[![Platform](https://img.shields.io/cocoapods/p/Swap.svg?style=flat)](https://cocoapods.org/pods/Swap)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Swap is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Swap'
```

## Author

cwd

## License

Swap is available under the MIT license. See the LICENSE file for more info.




# Swap

合约SDK接入文档
====

# 1.0 兼容性
开发语言: swift5.0 
支持 iOS12.0 以上的系统。其他系统需要进行测试。 

# 1.1 软硬件支持 
    1.硬件: iPhone。
    2.开发环境: Xcode13 及以上版本。 

# 2.0 合约SDK功能介绍
##2.1.公有信息数据（EXPublicSwapInfo）
    市场Ticker 
    深度OrderBook
    最新成交Trade
    K线Kline 
## 2.2 个人账户信息数据（EXPersonaSwapInfo）
    合约资产
    合约仓位
    委托订单
    订单记录
## 2.3ws数据实时刷新（EXSwapSocketManager）
    行情、深度、最新成交 订阅跟取消
    私有资产订阅需要通过认证（认证成功SDK内部自动订阅）
# 3.0 集成SDK
## 方式1:推荐使用pod集成, 本地路径集成
    集成方式: pod 'Swap', :path => '/XXXXX/Lib/Swap' //path 为"Swap.podspec 所在的目录"
    
## 方式2:可以将Lib/Swap/Swap 文件拖入项目,导入必须的头文件

# 4.0 初始化SDK,详细可以参考：Lib/Swap/Example
## 4.1 需要使用的地方import Swap
## 4.2配置 合约需要的一些参数
​```swift
        func loadEXSwapSDK() {
        let base = "https://futuresappapi/xxxx/"
        let ws = "wss://futuresws/xxxxx/kline-api/ws"
        let infoDictionary = Bundle.main.infoDictionary!
        let appDisplayName = infoDictionary["CFBundleDisplayName"] as? String ?? "swap"//程序名称
        let config = EXSwapPrivateConfig.shared
        config.base_host = base //api URl地址
        config.ws = ws  //ws 的地址
        config.appName = appDisplayName //用于分享的图片的 app 名字
        config.appIcon = UIImage() //用于分享的图片 的logo
        config.shareUrl = "分享链接用于生成二维码"
        //链接socket
        EXSwapSocketManager.shared.connectServer()
        //初始化合约
        EXContractSDK.ex_start(AppName: appDisplayName, launchOption: config, finish: { (_, _) in
            //登录状态已记录
            self.swapSDKLoadPlatForm()
        })
    }
​```
## 4.3.登录、退出以及回调监听
​```swift
    /**
     登录、退出以及回调监听,通知的key EXLoginSuccess/Logout_notification_name
     换成自己项目里的
     */
    func swapPlatformSDKCallBack() {
        // 监听登录成功
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(swapSDKLoadPlatForm),
                                               name: NSNotification.Name(rawValue: "EXLoginSuccess"),
                                               object: nil)
        // 退出登录
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshLogout),
                                               name: NSNotification.Name(rawValue: "Logout_notification_name"),
                                               object: nil)
        
        EXSwapPlatformSDK.shared.loginCallBack = {
            //弹出登录
        }
        
        EXSwapPlatformSDK.shared.transferOnClickedCallBack = { (symbol,currentVC) in
            
           //跳转到划转
        }
        EXSwapPlatformSDK.shared.realNameAuthenticationCallBack = {
           // 实名认证
        }
    }
    
    // 监听登录成功 配置token
    @objc func swapSDKLoadPlatForm() {
        let token = ""
        if token.count > 0 {
            let account = EXSwapAccount()
            account.token = token
            EXSwapPlatformSDK.shared.activeAccount = account
            EXSwapPlatformSDK.shared.inviteUrl = "邀请链接的url"
        }
    }
    // 退出清空数据
    @objc func refreshLogout() {
        EXContractSDK.alreadLogout()
        EXSwapPlatformSDK.shared.activeAccount = nil
    }
​​```
## 4.4 AppDelegate里添加屏幕支持的旋转方向,k线横屏需要使用
​```swift
extension AppDelegate{
     func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIDeviceManger.shared.blockRotation
    }
}
​​```
​​
​​
## 4.5 皮肤切换
  白天  
 ​```
  EXTheme.light.active()
​​ ​​```
  夜间
 ​```
 ​EXTheme.dark.active()
​​ ​​```
## 4.6 语言切换
​​ 目前项目里主要支持中文和英文2种语言,优先线上语言包,线上语言包没有得话,会走本地语言包
​​ 切换语言包
​​ ```
​​ EXLanguageTools.setLanguage(langeuage: key)
​​ ```



## 对内自己项目使用手册
 开发项目中集成 合约私有库
 0. configTableView
 1. 回调实现 详见
 initSwapPlatformSDK 里的回调实现

 2. 合约里需要的一些配置项
 
 2.1分享
 EXSwapPrivateConfig.shared.sharePage =  EXAppConfigManager.sharedInstance.getSharingPage
 2.2线路切换 成功后需要记录最新的路线
 方法 func updateSwapDomain 里面处理更新路线
 EXSwapPrivateConfig.shared.ws =  self.wsContractV2
 EXSwapPrivateConfig.shared.base_host = self.contractApiV2
 
 2.3 获取配置信息后 更新到合约  updateConfigToContract()
 2.4 市场币对信息获取后更新 精度信息 EXSwapPrivateConfig.shared.coinPrecisionMap
 
 3.svg 换色需求
 3.1 颜色需要更换 全局替换
 3.2 svg图片配置  SvgConfigManger.shared.newThemeColor = "#FADE14"
 4. 资产集成 newSwapAsset 相关回调实现
 

