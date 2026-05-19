//
//  EXRxExtenstion.swift
//  EXContractSDKTest
//
//  Created by ZYJ on 2023/2/1.
//

import Foundation
import RxSwift
import ObjectiveC

// DisposeBag for UIViewController & UIView
/*
 大家rxswift的bindUI和disposebag 都用这里面vc 和 view里面的就可以 English: Everyone can use the bindUI and disposebag in rxswift, as well as the ones in VC and View
 如果你自己之前的工程创建过disposebag 和 实现过bindUI方法 English: If you have created a disposebag and implemented the bindUI method in your previous project
 需要1:删除定义的disposebag 2.override func bindUI(){super.bindUI() } English: Requirement 1: Delete the defined disposebag 2. override fun bindUI() {super. bindUI()}
 3.如果之前有cell复用的时候的disposebag 注意修改为专门为了解决复用问题的disposeBagForBinding English: 3. If there was a previous dispose tag during cell reuse, please modify it to a dispose BagForBinding specifically designed to address reuse issues
 */
fileprivate var exs_disposeBagContext: UInt8 = 0
fileprivate var exs_disposeBagForBindingContext: UInt8 = 0

// UIViewController
extension UIViewController {

    private func exs_synchronizedBag<T>( _ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
    
    @objc open func exs_bindUI()
    {
        // 清空之前的绑定 English: Clear previous binding
        exs_disposeBagForBinding = DisposeBag()
    }
    public var exs_disposeBag: DisposeBag {
        get {
            return exs_synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(self, &exs_disposeBagContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(self, &exs_disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        set {
            exs_synchronizedBag {
                objc_setAssociatedObject(self, &exs_disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    public var exs_disposeBagForBinding: DisposeBag {
        get {
            return exs_synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(self, &exs_disposeBagForBindingContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(self, &exs_disposeBagForBindingContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        set {
            exs_synchronizedBag {
                objc_setAssociatedObject(self, &exs_disposeBagForBindingContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

// UIView
extension UIView {
    
    private func exs_synchronizedBag<T>( _ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
    
    @objc open func exs_bindUI()
    {
        // 清空之前的绑定 English: Clear previous binding
        exs_disposeBagForBinding = DisposeBag()
    }
    public var exs_disposeBag: DisposeBag {
        get {
            return exs_synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(self, &exs_disposeBagContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(self, &exs_disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        set {
            exs_synchronizedBag {
                objc_setAssociatedObject(self, &exs_disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    public var exs_disposeBagForBinding: DisposeBag {
        get {
            return exs_synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(self, &exs_disposeBagForBindingContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(self, &exs_disposeBagForBindingContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        set {
            exs_synchronizedBag {
                objc_setAssociatedObject(self, &exs_disposeBagForBindingContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

