//
//  EXSwapPrivateConfig.swift
//  CoNetworkTest
//
//  Created by ZYJ on 2023/1/18.
//

import UIKit
import EXKit
public class EXSwapPrivateConfig{
    
    public var private_key = ""
    public var base_host = "" //合约的域名地址 English: The domain name address of the contract
    public var ws = "" //合约的ws域名 English: The ws domain name of the contract
    public var host_Header = ""
    public var headers = ""
    public var appName = "" //分享图的app 名字 English: The name of the app for sharing images
    public var appIcon = UIImage()//分享图的app 图标 English: App icon for sharing images
    public var sharePage = ""//分享图的 二维码链接 English: QR code link for sharing images
    public var fiatCoinSymbol = "" //获取法币symbol CNY USD等 English: Obtain legal currency symbols CNY USD, etc
    public var coinInfo: (String,String,Int)  = ("","",0) //获取币种的汇率 0符号 1汇率 2位数 English: Obtain currency exchange rate 0 symbol 1 exchange rate 2 digits
    public var coinPrecisionMap = [String: String]() //币种配置的精度0-合约资产模块使用 English: The accuracy of currency allocation 0- Contract asset module usage
    //MARK: fix 需要配置 English: MARK: Fix needs to be configured
    public var coCouponSwitchUrl = "" //合约体验金 English: Contract experience fee
    public var coCouponSwitchUrlStatus = "" //合约体验金 English: Contract experience fee
    public var companyDomain = "" // 配置的公司域名 English: The configured company domain name
    public var profitUrl = "" // 资产盈亏记录 English: Asset profit and loss records
    public var companyId = "" // 公司ID English: Company ID
    public var isPrivate: Bool = false // 
    static private let `manager` = EXSwapPrivateConfig()
    open class var shared: EXSwapPrivateConfig {
        return manager
    }
    private init(){}
}

