//
//  EXHomeDataService.swift
//  Chainup
//
//  Created by cwd on 2022/12/19.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
/**
 合约首页所有的轮询接口处理 English: Processing of all polling interfaces on the contract homepage
 */
class EXHomeDataService:NSObject{
    
    private override init(){}
    
    class func shared() -> EXHomeDataService{
        return EXHomeDataService()
    }
    let thread = Thread(target: self, selector: #selector(lanchRunloop), object: nil)
    func run(){
        // 开启RunLoop 保活线程 English: Enable RunLoop to keep threads alive
//        let thread = Thread(target: self, selector: #selector(lanchRunloop), object: nil)
        thread.start()
        // 再次调用还能执行任务在这个线程 English: Calling again can still execute tasks on this thread
//        perform(#selector(foo), on: thread, with: nil, waitUntilDone: false)

    }
    func test(){
        perform(#selector(foo), on: thread, with: nil, waitUntilDone: false)

    }
  
    @objc func foo(){
//        //print("子线程")
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            //print("子线程")
        }
        timer.fire()
    }
    
    @objc internal func lanchRunloop() {
        autoreleasepool {
//            //print("lanchRunloop")
            let currentThread: Thread = Thread.current
            currentThread.name = "contractThread"
            let currentRunLoop: RunLoop = RunLoop.current
            // 这里不一定非要 add NSMachPort English: It's not necessary to add NSMachPort here
            // 只要是 Timer Observer Source(MachPort) 添加到一种Mode下都可以 English: As long as Timer Observer Source (MachPort) is added to one mode, it can be done
            // 如果不添加 Timer Observer Source 那么RunLoop会自动退出， English: If the Timer Observer Source is not added, RunLoop will automatically exit,
            // 具体可以看RunLoop源代码 English: You can refer to the RunLoop source code for details
            currentRunLoop.add(NSMachPort(), forMode: .common)
            currentRunLoop.run()
        }
    }
    

}

