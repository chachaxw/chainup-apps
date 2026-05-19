//
//  EXRxCustomObjMapper.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/31.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

import RxSwift
import Moya
import HandyJSON

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
//    func success() -> Single<Bool> {
//        return flatMap { response in
//            //~=Check if a range contains a certain value
//            guard (200...209) ~= response.statusCode else {
//                throw KKError.jsonError
//            }
//            guard let _json = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String:Any] else {
//                throw KKError.dataError
//            }
//            guard let _code = _json["code"] as? Int, _code == 1 else {
//                throw KKError.error(_json["code"] as? Int, _json["msg"] as? String)
//            }
//            return Single.just(true)
//        }
//    }
//    func mapString() -> Single<String> {
//        return flatMap { response in
//            //~=Check if a range contains a certain value
//            guard (200...209) ~= response.statusCode else {
//                throw KKError.jsonError
//            }
//            guard let _json = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String:Any] else {
//                throw KKError.dataError
//            }
//            guard let _code = _json["code"] as? Int, _code == 1 else {
//                throw KKError.error(_json["code"] as? Int, _json["msg"] as? String)
//            }
//            guard let strInt = _json["data"] as? Int else {
//                throw KKError.jsonError
//            }
//            return Single.just(String(strInt))
//        }
//    }
    func mapObject<T: HandyJSON>(_ type: T.Type,_ handleError: Bool = true) -> Single<T> {
        return flatMap { response in
            //~=Check if a range contains a certain value
            guard (200...209) ~= response.statusCode else {
                throw CustomNetworkError.ParseDataError
            }
            guard let _json = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String:Any] else {
                throw CustomNetworkError.ParseDataError
            }
            if let _code = _json["code"] as? Int, let msg = _json["msg"] as? String{
                if _code != 0 {
                    let errMsg = msg + "(\(_code))"
                    if handleError == true{
                        EXAlert.showFail(msg: errMsg)
                    }
                    throw CustomNetworkError.ParseDataError
                }
            }
            let dataJson = _json["data"] as? [String:Any]
            guard let _dataJson = dataJson else {
                throw CustomNetworkError.ParseDataError
            }
            let object = T.deserialize(from: _dataJson)
            guard let _object = object else {
                throw CustomNetworkError.ParseDataError
            }
            return Single.just(_object)
        }
    }
    
    
//    func mapArray<T: HandyJSON>(_ type: T.Type,_ handleError: Bool = true, customHandleCode:(() -> (String))? = nil  ) -> Single<[T?]> {
//        return flatMap { response in
//            guard (200...209) ~= response.statusCode else {
//                throw KKError.jsonError
//            }
//
//            let json = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments)
//            if json is [Any] {
//                let objects = [T].deserialize(from: json as? [Any])
//                guard let _objects = objects else {
//                    throw KKError.dataError
//                }
//                return Single.just(_objects)
//            }
//
//
//            guard let _json = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String:Any] else {
//                throw KKError.dataError
//            }
//            guard let _code = _json["code"] as? Int, _code == 1 else {
//                throw KKError.error(_json["code"] as? Int, _json["msg"] as? String)
//            }
//            let __json = _json["data"] as? [Any]
//            if __json == nil {
//                return Single.just([])
//            }
//            let objects = [T].deserialize(from: __json)
//            guard let _objects = objects else {
//                throw KKError.dataError
//            }
//            return Single.just(_objects)
//        }
//    }
    
    
}

