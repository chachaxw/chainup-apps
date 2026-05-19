//
//  EXNetworkCorrector.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/4.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

class EXNetworkUploadModel:EXBaseModel {
    var error:Int = 0
    var lineNum:String = ""
    var speed:String = ""
}

class EXNetworkCorrector: NSObject {
    
    var retryCount:Int //Number of checks, default to 5
    var retryInterval:Int //Each inspection time, default to 10 seconds
    var differance:Int //Difference, default to 500, greater than the difference switch
    var lines:[String] = []
    var wslines:[String] = []

    var currentResponds:[String] = []
    var tmpResponds:[String] = []
    
    var countTimes:Int = 0
    var gatherInfo:[String:[String]] = [:]
    var averageInfo:[String:String] = [:]
    
    var timerDisposable: Disposable? = nil
    var subscription: Disposable? = nil
    let disposeBag = DisposeBag()
    var aborting:Bool = false
    
    required init(retryCount:Int = 5 , retryInteval:Int = 10 , lines:[String],wsLines:[String],differance:Int = 500) {
        self.retryCount = retryCount
        self.retryInterval = retryInteval
        self.differance = differance
        self.lines = lines
        self.wslines = wsLines
    }
    
    func startMonitoring() {
        if self.lines.isEmpty {
            return
        }
        fetchWs()
        fetchHealth()
        self.timerDisposable = Observable<Int>.interval(.seconds(retryInterval), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.fetchHealth()
            })
    }
    
    func fetchHealth() {
        countTimes += 1
        if countTimes > self.retryCount {
            self.timerDisposable?.dispose()
            subscription?.dispose()
            handleAverage()
//Print ("Last request completed")
            return
        }
//Print ("Request  (countTimes)")
        let appapiHost = EXNetworkDoctor.sharedManager.getAppAPIHost()
        var allLinks:[EXPing] = []
        var respondsTimeAry:[Observable<String>] = []
        for (_,host) in lines.enumerated() {
            let urlString = EXNetworkDoctor.sharedManager.changeApiTo(domain: host, oldDomainUrl: appapiHost)
            let ping = EXPing(host: host,address: urlString, type: .api)
            allLinks.append(ping)
            respondsTimeAry.append(ping.durationRelay.asObservable())
        }
        
        for item in allLinks {
            item.startPinging()
        }
        
        subscription?.dispose()
        if countTimes > 0 {
            let recordtimes = tmpResponds.filter { (evertime) -> Bool in
                return evertime.count > 0
            }
            if recordtimes.count < self.lines.count {
                self.handleAllResponds(forceUpload: true)
            }
        }
        subscription = Observable.combineLatest(respondsTimeAry)
            .distinctUntilChanged()
            .subscribe({[weak self] (event) in
                switch event {
                case .next(let respondings):
                    self?.tmpResponds = respondings
                    self?.currentResponds = respondings.filter({ (item) -> Bool in
                        return item.count > 0
                    })
                    self?.handleAllResponds(forceUpload: false)
                    break
                case .completed:
                    break
                case .error:
                    break
                }
            })
    }
    
    //ForceUpload force calculation, if there is no request to return after the deadline, use the existing line conditions to calculate the optimal
    func handleAllResponds(forceUpload:Bool) {
        
        var tmp:[String] = []
        if forceUpload {
            tmp = tmpResponds
        }else {
            //After all the line data comes back, the processing is optimal
            if self.currentResponds.count == self.lines.count {
                tmp = currentResponds
            }
        }
        if tmp.count > 0 {
//Print ("processing result")
            for (idx,lineName) in self.lines.enumerated() {
                if var item  = gatherInfo[lineName] {
                    item.append(tmp[idx])
                    gatherInfo[lineName] = item
                }else {
                    gatherInfo[lineName] = [tmp[idx]]
                }
            }
        }
    }
    
    func handleAverage() {
        for line in self.lines {
            if let allTimes = gatherInfo[line] {
                if allTimes.contains("+") {
                    let numbers = allTimes.filter{ (item) -> Bool in
                        return item != "+"
                    }
                    var average = ""
                    if numbers.count > 0 {
                        let numberSum = numbers.reduce(0,{ a,b in
                            return a + (Int(b) ?? 0)
                        })
                        average = "\(numberSum/numbers.count)"
                    }
                    let empty = allTimes.filter {(item) -> Bool in
                        return item == "+"
                    }
                    averageInfo[line] = average + empty.joined()
                }else {
                    let sum = allTimes.reduce(0,{ a,b in
                        return a + (Int(b) ?? 0)
                    })
                    let average = sum/retryCount
                    averageInfo[line] = "\(average)"
                    
                }
            }
        }
//        print("Here comes the result -"  (averageInfo))
        print(gatherInfo)
        if self.averageInfo.count > 0 {
            runForOptimalLine(average: averageInfo)
        }
    }
    
    private func runForOptimalLine(average:[String:String]) {
        let allresutls = average.map{$0.1}.joined()
        var name:String = ""
        var result:String = ""
        if allresutls.contains("+") {
            let noErroLines = average.filter { (a,b) -> Bool in
                return !(b.contains("+"))
            }
            //Find the ones without a+sign and choose the best one
            if noErroLines.count > 0 {
                let sorted = noErroLines.sorted {(a,b) -> Bool in
                    let first = Int(a.1)!
                    let second = Int(b.1)!
                    return first < second
                }
                let optimalLine = sorted[0]
                name = optimalLine.key
                result = optimalLine.value
            }else {
                //For those with a+sign, the+sign is the least, while the+sign is the same and the best is chosen
                let errorCountsLine = average.sorted { (a,b) -> Bool in
                    let first = a.value
                    let second = b.value
                    let errorCountA = first.count - first.replacingOccurrences(of: "+", with: "").count
                    let errorCountB = second.count - second.replacingOccurrences(of: "+", with: "").count
                    if errorCountA == errorCountB {
                        let resultA = Int(first.replacingOccurrences(of: "+", with: "")) ?? 0
                        let resultB = Int(second.replacingOccurrences(of: "+", with: "")) ?? 0
                        return resultA < resultB
                    }else {
                        return errorCountA < errorCountB
                    }
                }
                
                let optimalLine = errorCountsLine[0]
                
                name = optimalLine.key
                result = optimalLine.value
            }
        }else {
            let sorted = average.sorted {(a,b) -> Bool in
                let first = Int(a.1)!
                let second = Int(b.1)!
                return first < second
            }
            if sorted.count > 0 {
                let optimalLine = sorted[0]
                name = optimalLine.key
                result = optimalLine.value
            }
        }
        self.trySwitchLine(lineName: name, latency: result)
    }
    
    func switchTo(host:String) {
        //Make sure you don't cut it wrong
        if aborting == true {
            return
        }
        
        uploadResult(old: self.oldDomain(), new: host)
        if host.count > 0 , self.lines.contains(host) {
            EXNetworkDoctor.sharedManager.changeCurrentHost(selectedHost: host)
        }

    }
    
    private func getErrorCompare(a:String,b:String)-> ComparisonResult {
        /*
         a < b   then return NSOrderedAscending. The left operand is smaller than the right operand.
         a > b   then return NSOrderedDescending. The left operand is greater than the right operand.
         a == b  then return NSOrderedSame. The operands are equal.
         */
        
        let errorCountA = a.count - a.replacingOccurrences(of: "+", with: "").count
        let errorCountB = b.count - b.replacingOccurrences(of: "+", with: "").count
        if errorCountA == errorCountB {
            return .orderedSame
        }else if errorCountA > errorCountB {
            return .orderedDescending
        }else {
            return .orderedAscending
        }
    }
    
    func isFasterThanCurrent(a:String,b:String) -> Bool {
        let resultA = Int(a.replacingOccurrences(of: "+", with: "")) ?? 0
        let resultB = Int(b.replacingOccurrences(of: "+", with: "")) ?? 0 
        if resultA - resultB > differance {
            //Switch, upload
            return true
        }
        return false
    }
    
    private func oldDomain() ->String {
        let appapiHost = EXNetworkDoctor.sharedManager.getAppAPIHost()
        let oldDomain = appapiHost.hostStr()
        return oldDomain
    }
    
    private func trySwitchLine(lineName:String,latency:String) {
        let oldDomain = self.oldDomain()
        if lineName == oldDomain {
            //Unchanged, upload data
            uploadResult(old: oldDomain, new: oldDomain)
        }else {
            if let currentResponds = averageInfo[oldDomain] {
                //Number of errors in the current line
                if currentResponds.contains("+") {
                    //Comparison>500
                    let result = getErrorCompare(a: currentResponds, b: latency)
                    switch result {
                    case .orderedDescending:
                        self.switchTo(host: lineName)
                    case .orderedSame:
                        if isFasterThanCurrent(a: currentResponds, b: latency) {
                            //Switch, upload
                            self.switchTo(host: lineName)
                        }else {
                            //Unchanged, upload
                            uploadResult(old: oldDomain, new: oldDomain)
                        }
                    case .orderedAscending:
                        //Unchanged, upload
                        uploadResult(old: oldDomain, new: oldDomain)
                    }
                }else {
                    if latency.contains("+")  {
                        //Unchanged, upload
                        uploadResult(old: oldDomain, new: oldDomain)
                    }else {
                        //No errors
                        //Comparison, greater than 500
                        if isFasterThanCurrent(a: currentResponds, b: latency) {
                            //Switch, upload
                            self.switchTo(host: lineName)
                        }else {
                            //Unchanged, upload
                            uploadResult(old: oldDomain, new: oldDomain)
                        }
                        
                    }
                }
            }
        }
    }
    
    private func uploadResult(old:String,new:String) {
        var uploadsAry:[[String:Any]] = []
        for (idx,line) in self.lines.enumerated() {
            var model:[String:Any] = [:]
            model["lineNum"] = idx + 1
            if let result = averageInfo[line] {
                if result.contains("+") {
                    let speed = result.replacingOccurrences(of: "+", with: "")
                    let errorCountA = result.count - speed.count
                    model["error"] = errorCountA
                    model["speed"] = speed
                }else {
                    model["speed"] = result
                    model["error"] = 0
                }
                uploadsAry.append(model)
            }
        }
        
        //Xcode11.6, debug will crash for unknown reason
        #if DEBUG
        return
        #else
        if let json = json(from: uploadsAry),json.count > 0 {
            appApi.hideAutoLoading()
            appApi.rx.request(.networkUpload(oldLine: old, newLine: new, netWorkJson: json))
                .subscribe{event in
                    switch event {
                    case .success(_):
                        break
                    case .failure(_):
                        break
                    }
            }.disposed(by: self.disposeBag)
        }
        #endif
        
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}

extension EXNetworkCorrector {
    
    func fetchWs() {
        let wsApiHost = EXNetworkDoctor.sharedManager.getAppAPIHost()
        var allLinks:[EXPing] = []
        var wsTimeAry:[Observable<String>] = []
        for (_,host) in wslines.enumerated() {
            let urlString = EXNetworkDoctor.sharedManager.changeApiTo(domain: host, oldDomainUrl: wsApiHost)
            let ping = EXPing(host: host,address: urlString, type: .api)
            wsTimeAry.append(ping.durationRelay.asObservable())
            allLinks.append(ping)
        }
        for item in allLinks {
            item.startPinging()
        }
        Observable.combineLatest(wsTimeAry)
            .distinctUntilChanged()
            .subscribe({[weak self] (event) in
                switch event {
                case .next(let respondings):
                    let emptys = respondings.filter {$0.count == 0}
                    if emptys.count == 0 {
                        self?.updateWs(responds: respondings)
                    }
                    break
                case .completed:
                    break
                case .error:
                    break
                }
            }).disposed(by: self.disposeBag)
    }
    
    func updateWs(responds:[String]) {
        let sorted = responds.filter { return $0 != "+"}.sorted { a, b in
            return NumberHandler.handleDouble(a) < NumberHandler.handleDouble(b)
        }
        if sorted.count > 0 {
            let rst = sorted[0]
            if let idx = responds.firstIndex(of: rst) {
                if self.wslines.count > idx {
                    EXNetworkDoctor.sharedManager.changeWsHost(selectedHost: self.wslines[idx])
                }
            }

        }
    }
}

