//import UIKit
//import RxSwift
//import ObjectiveC
//
//// DisposeBag for UIViewController & UIView
///*
// 大家rxswift的bindUI和disposebag 都用这里面vc 和 view里面的就可以 English: Everyone can use the bindUI and disposebag in rxswift, as well as the ones in VC and View
// 如果你自己之前的工程创建过disposebag 和 实现过bindUI方法 English: If you have created a disposebag and implemented the bindUI method in your previous project
// 需要1:删除定义的disposebag 2.override func bindUI(){super.bindUI() } English: Requirement 1: Delete the defined disposebag 2. override fun bindUI() {super. bindUI()}
// 3.如果之前有cell复用的时候的disposebag 注意修改为专门为了解决复用问题的disposeBagForBinding English: 3. If there was a previous dispose tag during cell reuse, please modify it to a dispose BagForBinding specifically designed to address reuse issues
// */
//fileprivate var disposeBagContext: UInt8 = 0
//fileprivate var disposeBagForBindingContext: UInt8 = 0
//
//// UIViewController
//extension UIViewController {
//
//    private func synchronizedBag<T>( _ action: () -> T) -> T {
//        objc_sync_enter(self)
//        let result = action()
//        objc_sync_exit(self)
//        return result
//    }
//    
//    /* UI绑定 */ English: /*UI binding*/
//    @objc open func bindUI()
//    {
//        // 清空之前的绑定 English: Clear previous binding
//        disposeBagForBinding = DisposeBag()
//    }
//    /* 一般的使用方式 */ English: /*General usage methods*/
//    public var disposeBag: DisposeBag {
//        get {
//            return synchronizedBag {
//                if let disposeObject = objc_getAssociatedObject(self, &disposeBagContext) as? DisposeBag {
//                    return disposeObject
//                }
//                let disposeObject = DisposeBag()
//                objc_setAssociatedObject(self, &disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                return disposeObject
//            }
//        }
//        set {
//            synchronizedBag {
//                objc_setAssociatedObject(self, &disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
//    /* 数据源可能发生变化的时候使用，比如Cell重用，一般用在bindUI方法中，下次更新数据源的时候取消之前的绑定 */ English: /*When there may be changes in the data source, such as cell reuse, it is generally used in the bindUI method. When updating the data source next time, the previous binding is canceled*/
//    public var disposeBagForBinding: DisposeBag {
//        get {
//            return synchronizedBag {
//                if let disposeObject = objc_getAssociatedObject(self, &disposeBagForBindingContext) as? DisposeBag {
//                    return disposeObject
//                }
//                let disposeObject = DisposeBag()
//                objc_setAssociatedObject(self, &disposeBagForBindingContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                return disposeObject
//            }
//        }
//        set {
//            synchronizedBag {
//                objc_setAssociatedObject(self, &disposeBagForBindingContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
//}
//
//// UIView
//extension UIView {
//    
//    private func synchronizedBag<T>( _ action: () -> T) -> T {
//        objc_sync_enter(self)
//        let result = action()
//        objc_sync_exit(self)
//        return result
//    }
//    
//    /* UI绑定 */ English: /*UI binding*/
//    @objc open func bindUI()
//    {
//        // 清空之前的绑定 English: Clear previous binding
//        disposeBagForBinding = DisposeBag()
//    }
//    /* 一般的使用方式 */ English: /*General usage methods*/
//    public var disposeBag: DisposeBag {
//        get {
//            return synchronizedBag {
//                if let disposeObject = objc_getAssociatedObject(self, &disposeBagContext) as? DisposeBag {
//                    return disposeObject
//                }
//                let disposeObject = DisposeBag()
//                objc_setAssociatedObject(self, &disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                return disposeObject
//            }
//        }
//        set {
//            synchronizedBag {
//                objc_setAssociatedObject(self, &disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
//    /* 数据源可能发生变化的时候使用，比如Cell重用，一般用在bindUI方法中，下次更新数据源的时候取消之前的绑定 */ English: /*When there may be changes in the data source, such as cell reuse, it is generally used in the bindUI method. When updating the data source next time, the previous binding is canceled*/
//    public var disposeBagForBinding: DisposeBag {
//        get {
//            return synchronizedBag {
//                if let disposeObject = objc_getAssociatedObject(self, &disposeBagForBindingContext) as? DisposeBag {
//                    return disposeObject
//                }
//                let disposeObject = DisposeBag()
//                objc_setAssociatedObject(self, &disposeBagForBindingContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                return disposeObject
//            }
//        }
//        set {
//            synchronizedBag {
//                objc_setAssociatedObject(self, &disposeBagForBindingContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
//}

