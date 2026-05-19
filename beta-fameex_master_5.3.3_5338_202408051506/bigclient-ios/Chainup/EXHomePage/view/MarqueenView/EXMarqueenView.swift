//
//  EXMarqueenView.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//GYRollingNoticeView for copy

import UIKit

protocol EXMarqueenViewDataSource :NSObjectProtocol {
    func numberOfRowsFor(view:EXMarqueenView) -> Int
    func marqueeView(view:EXMarqueenView, cellAtIdx:Int) -> EXMarqueenCell
}

protocol EXMarqueenViewDelegate :NSObjectProtocol {
    func marqueeView(view:EXMarqueenView,didClickAt index:Int)
}

class EXMarqueenView: UIView {
    
    weak var dataSource :EXMarqueenViewDataSource?
    weak var delegate :EXMarqueenViewDelegate?
    var interval = 3.0
    private var currentIndex:Int = 0
    
    // MARK: private properties
    private lazy var cellClsDict: Dictionary = { () -> [String : Any] in
        var tempDict = Dictionary<String, Any>()
        return tempDict
    }()
    private lazy var reuseCells: Array = { () -> [EXMarqueenCell] in
        var tempArr = Array<EXMarqueenCell>()
        return tempArr
    }()
    
    private var timer: Timer?
    private var currentCell: EXMarqueenCell?
    private var willShowCell: EXMarqueenCell?
    private var isAnimating = false
    // MARK: -
    open func register(_ cellClass: Swift.AnyClass?, forCellReuseIdentifier identifier: String) {
        self.cellClsDict[identifier] = cellClass
    }
    
    open func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        self.cellClsDict[identifier] = nib
    }
    
    open func dequeueReusableCell(withIdentifier identifier: String) -> EXMarqueenCell? {
        for cell in self.reuseCells {
            guard let reuseIdentifier = cell.reuseIdentifier else { return nil }
            if reuseIdentifier.elementsEqual(identifier) {
                return cell
            }
        }
        
        if let cellCls = self.cellClsDict[identifier] {
            if let nib = cellCls as? UINib {
                let arr = nib.instantiate(withOwner: nil, options: nil)
                if let cell = arr.first as? EXMarqueenCell {
                    cell.setValue(identifier, forKeyPath: "reuseIdentifier")
                    return cell
                }
                return nil
            }
            
            if let noticeCellCls = cellCls as? EXMarqueenCell.Type {
                let cell = noticeCellCls.self.init(reuseIdentifier: identifier)
                return cell
            }
            
        }
        return nil
    }
    
    open func reloadDataAndStartRoll() {
        stopRoll()
        guard let count = self.dataSource?.numberOfRowsFor(view: self), count > 0 else {
            return
        }
        
        layoutCurrentCellAndWillShowCell()
        
        
        
        guard count >= 2 else {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(EXMarqueenView.timerHandle), userInfo: nil, repeats: true)
        if let __timer = timer {
            RunLoop.current.add(__timer, forMode: RunLoop.Mode.common)
        }
        resume()
        
    }
    
    //If you want to release, please stop the timer at the appropriate location. If you want to release, please stop the timer in the right place, for example '- viewDidDismiss'
    open func stopRoll() {
        
        if let rollTimer = timer {
            rollTimer.invalidate()
            timer = nil
        }
        
//        status = .idle
        isAnimating = false
        currentIndex = 0
        currentCell?.removeFromSuperview()
        willShowCell?.removeFromSuperview()
        currentCell = nil
        willShowCell = nil
        self.reuseCells.removeAll()
    }
    
    open func pause() {
        if let __timer = timer {
            __timer.fireDate = Date.distantFuture
//            status = .pause
        }
    }
    
    open func resume() {
        if let __timer = timer {
            __timer.fireDate = Date.distantPast
//            status = .working
        }
    }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNoticeViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNoticeViews()
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    

}


// MARK: private funcs
extension EXMarqueenView {
    
    @objc fileprivate func timerHandle() {
        if isAnimating {
            return
        }
        layoutCurrentCellAndWillShowCell()
        currentIndex += 1
        
        let w = self.frame.size.width
        let h = self.frame.size.height
        
        isAnimating = true
        UIView.animate(withDuration: 0.5, animations: {
            self.currentCell?.frame = CGRect(x: 0, y: -h, width: w, height: h)
            self.willShowCell?.frame = CGRect(x: 0, y: 0, width: w, height: h)
        }) { (flag) in
            if let cell0 = self.currentCell, let cell1 = self.willShowCell {
                self.reuseCells.append(cell0)
                cell0.removeFromSuperview()
                self.currentCell = cell1
            }
            self.isAnimating = false
        }
    }
    
    
    fileprivate func layoutCurrentCellAndWillShowCell() {
        guard let count = (self.dataSource?.numberOfRowsFor(view: self)) else { return }
        
        if (currentIndex > count - 1) {
            currentIndex = 0
        }
        
        var willShowIndex = currentIndex + 1
        if (willShowIndex > count - 1) {
            willShowIndex = 0
        }
        //    print(">>>>%d", currentIndex)
        
        let w = self.frame.size.width
        let h = self.frame.size.height
                
        if currentCell == nil {
            //The first time there was no currentcell
            // currentcell is null at first time
            if let cell = self.dataSource?.marqueeView(view: self, cellAtIdx: currentIndex) {
                currentCell = cell
                cell.frame  = CGRect(x: 0, y: 0, width: w, height: h)
                self.addSubview(cell)
            }
            
            return
        }
        
        
        if let cell = self.dataSource?.marqueeView(view: self, cellAtIdx: willShowIndex) {
            willShowCell = cell
            cell.frame = CGRect(x: 0, y: h, width: w, height: h)
            self.addSubview(cell)
        }
        
        
        
        guard let _cCell = currentCell, let _wCell = willShowCell else {
            return
        }
        
        
//        print(String(format: "currentCell  %p", _cCell))
//        print(String(format: "willShowCell %p", _wCell))
        let currentCellIdx = self.reuseCells.firstIndex(of: _cCell)
        let willShowCellIdx = self.reuseCells.firstIndex(of: _wCell)
    
        if let index = currentCellIdx,reuseCells.count > index {
            self.reuseCells.remove(at: index)
        }
        
        if let index = willShowCellIdx,reuseCells.count > index{
            self.reuseCells.remove(at: index)
        }
        
    }
    
    @objc fileprivate func handleCellTapAction(){
        
        guard let count = self.dataSource?.numberOfRowsFor(view: self) else {
            return
        }
        
        if (currentIndex > count - 1) {
            currentIndex = 0;
        }
        self.delegate?.marqueeView(view: self, didClickAt: currentIndex)
    }
    
    fileprivate func setupNoticeViews() {
        self.clipsToBounds = true
        self.addGestureRecognizer(self.createTapGesture())
    }
    
    fileprivate func createTapGesture() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(EXMarqueenView.handleCellTapAction))
    }
    
}

