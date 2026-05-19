import Foundation
import RxSwift
import ObjectiveC

// DisposeBag for UIViewController & UIView
/*
Everyone can use the bindUI and disposebag of rxswift using the ones in VC and View
If you have created a disposebag and implemented the bindUI method in your previous project
Need 1: Delete the defined disposebag 2. override func bindUI() {super. bindUI()}
3. If there was a disposal tag during cell reuse before, please note to modify it to a disposal BagForBinding specifically designed to address reuse issues
 */
fileprivate var disposeBagContext: UInt8 = 0
fileprivate var disposeBagForBindingContext: UInt8 = 0

// UIViewController
extension UIViewController {

    private func synchronizedBag<T>( _ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
    
/*UI binding*/
    @objc open func bindUI()
    {
        //Clear previous binding
        disposeBagForBinding = DisposeBag()
    }
/*General usage*/
    public var disposeBag: DisposeBag {
        get {
            return synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(self, &disposeBagContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(self, &disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        set {
            synchronizedBag {
                objc_setAssociatedObject(self, &disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
/*When there may be changes to the data source, such as cell reuse, it is generally used in the bindUI method. The next time the data source is updated, the previous binding will be cancelled*/
    public var disposeBagForBinding: DisposeBag {
        get {
            return synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(self, &disposeBagForBindingContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(self, &disposeBagForBindingContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        set {
            synchronizedBag {
                objc_setAssociatedObject(self, &disposeBagForBindingContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

// UIView
extension UIView {
    
    private func synchronizedBag<T>( _ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
    
/*UI binding*/
    @objc open func bindUI()
    {
        //Clear previous binding
        disposeBagForBinding = DisposeBag()
    }
/*General usage*/
    public var disposeBag: DisposeBag {
        get {
            return synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(self, &disposeBagContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(self, &disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        set {
            synchronizedBag {
                objc_setAssociatedObject(self, &disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
/*When there may be changes to the data source, such as cell reuse, it is generally used in the bindUI method. The next time the data source is updated, the previous binding will be cancelled*/
    public var disposeBagForBinding: DisposeBag {
        get {
            return synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(self, &disposeBagForBindingContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(self, &disposeBagForBindingContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        set {
            synchronizedBag {
                objc_setAssociatedObject(self, &disposeBagForBindingContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

