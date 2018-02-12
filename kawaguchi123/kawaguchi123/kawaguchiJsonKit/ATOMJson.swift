//
//  ViewController.swift
//  kawaguchi123
//
//  Created by Lee on 2018/2/12.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import Foundation

fileprivate extension _AtomJsonBase {
    //// parser json keypath value
    fileprivate static func _atomKeyPathValue(_ keyPathArray: [String], json: Any?) -> Any? {
        var jsonObject = json
        keyPathArray.forEach({ (key) in
            if let range = key.range(of: "[") {
                let realKey = String(key[..<range.lowerBound])
                var indexString = key
                if !realKey.isEmpty {
                    jsonObject = (jsonObject as! Dictionary<String, Any>)[realKey]
                    indexString = String(key[range.lowerBound...])
                }
                var handleIndexString = indexString.replacingOccurrences(of: "]", with: ",")
                handleIndexString = handleIndexString.replacingOccurrences(of: "[", with: "")
                if handleIndexString.hasSuffix(",") {
                    handleIndexString = String(handleIndexString[..<handleIndexString.index(handleIndexString.endIndex, offsetBy: -1)])
                }
                if !handleIndexString.isEmpty {
                    handleIndexString.components(separatedBy: ",").forEach({ (i) in
                        if let index = Int(i) {
                            if let jsonArray = (jsonObject as? [Any])?[index] {
                                jsonObject = jsonArray
                            }else {
                                print("AtomJson: keyPath 異常")
                                jsonObject = nil
                            }
                        }else {
                            print("AtomJson: keyPath 配列index異常")
                            jsonObject = nil
                        }
                    })
                }else {
                    print("AtomJson: keyPath 配列index異常")
                    jsonObject = nil
                }
            }else {
                jsonObject = (jsonObject as! Dictionary<String, Any>)[key]
            }
        })
        return jsonObject
    }
    
    /// parser json
    fileprivate static func _atomJson(_ json: Any?, keyPath: String?) -> Self? {
        if json != nil {
            if keyPath != nil && keyPath != "" {
                var json_object: Any!
                switch json {
                case let str as String:
                    let json_data = str.data(using: .utf8)
                    return self._atomJson(json_data, keyPath: keyPath)
                case let data as Data:
                    json_object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    return self._atomJson(json_object, keyPath: keyPath)
                case _ as Dictionary<String, Any> , _ as Array<Any>:
                    if let keyPathArray = keyPath?.components(separatedBy: ".") {
                        let jsonObject = _atomKeyPathValue(keyPathArray, json: json)
                        switch jsonObject {
                        case _ as Dictionary<String, Any>:
                            print("AtomJson: Call api error,array json use api \(self).json(json)")
                            return nil
                        case _ as Array<Any>:
                            print("AtomJson: Call api error,array json use api [\(self)].json(json)")
                            return nil
                        default:
                            if let value  = jsonObject as? Self {
                                return value
                            }
                            print("AtomJson: Call api error, json not nil")
                            return nil
                        }
                    }
                default:
                    print("AtomJson: Call api error, json not nil")
                    return nil
                }
            }
            if let value  = json as? Self {
                return value
            }
            return nil
        }
        return nil
    }
}

public extension AtomJsonBasicType {
    
    /// 分析json
    ///
    /// - Parameters:
    /// - json: jsonデータ(文字、Dic，データData)
    /// - keyPath: json keyPath
    /// - Returns: model
    public static func atom_json(_ json: Any?, keyPath: String?) -> Self? {
        return _atomJson(json, keyPath: keyPath)
    }
}

public extension AtomJsonObjectType {
    
    /// 分析json
    ///
    /// - Parameters:
    /// - json: jsonデータ(文字、Dic，データData)
    /// - keyPath: json keyPath
    /// - Returns: model
    public static func atom_json(_ json: Any?, keyPath: String?) -> Self? {
        return _atomJson(json, keyPath: keyPath)
    }
}

public extension AtomJson {
    
    //MARK: - json -> model  -
    /// 分析json
    ///
    /// - Parameter jsonデータ(文字、Dic，データData)
    /// - Returns: model
    public static func atom_json(_ json: Any?) -> Self? {
        switch json {
        case let str as String:
            let json_data = str.data(using: .utf8)
            return Self.atom_json(json_data)
        case let data as Data:
            let json_object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return Self.atom_json(json_object)
        case let dictionary as Dictionary<String, Any>:
            var model = Self.init()
            model.atomMap(dictionary)
            return model
        case _ as Array<Any>:
            print("AtomJson: Call api error,array json use api [\(self)].json(json)")
            return nil
        default:
            print("AtomJson: Call api error, json not nil")
            return nil
        }
    }
    
    /// 分析json
    ///
    /// - Parameters:
    /// - json: jsonデータ(文字、Dic，データData)
    /// - keyPath: json keyPath
    /// - Returns: model
    public static func atom_json(_ json: Any?, keyPath: String?) -> Self? {
        if json != nil {
            if keyPath != nil && keyPath != "" {
                var json_object: Any!
                switch json {
                case let str as String:
                    let json_data = str.data(using: .utf8)
                    return self.atom_json(json_data, keyPath: keyPath)
                case let data as Data:
                    json_object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    return self.atom_json(json_object, keyPath: keyPath)
                case _ as Dictionary<String, Any> , _ as Array<Any>:
                    if let keyPathArray = keyPath?.components(separatedBy: ".") {
                        let jsonObject = _atomKeyPathValue(keyPathArray, json: json)
                        switch jsonObject {
                        case _ as Dictionary<String, Any>:
                            return self.atom_json(jsonObject)
                        case _ as Array<Any>:
                            print("AtomJson: Call api error,array json use api [\(self)].json(json)")
                            return nil
                        default:
                            print("AtomJson: Call api error, json not nil")
                            return nil
                        }
                    }
                default:
                    print("AtomJson: Call api error, json not nil")
                    return nil
                }
            }
            return self.atom_json(json)
        }
        return nil
    }
    
    //MARK: - model -> json -
    /// model->json string
    ///
    /// - Returns: json string
    public func atom_json() -> String? {
        if let map = self.atom_dictionary() {
            if JSONSerialization.isValidJSONObject(map) {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: map, options: [])
                    return String(data: jsonData, encoding: .utf8)
                }catch let error {
                    print("AtomJson: error \(error)")
                }
            }else {
                print("AtomJson: error invalid json map")
            }
            return nil
        }
        return nil
    }
    
    /// model->json Dic
    ///
    /// - Returns: json Dic
    public func atom_dictionary() -> [String: Any]? {
        return self.atomToValue() as? [String : Any]
    }
}


public extension NSObject {
    private struct AtomJsonConst {
        static var cachePropertyList = "AtomJsonConst###cachePropertyList"
    }
    
    private class func getPropertyList() -> [String] {
        if let cachePropertyList = objc_getAssociatedObject(self, &AtomJsonConst.cachePropertyList) {
            return cachePropertyList as! [String]
        }
        var propertyList = [String]()
        if let superClass = class_getSuperclass(self.classForCoder()) {
            if superClass != NSObject.classForCoder() {
                if let superList = (superClass as? NSObject.Type)?.getPropertyList() {
                    propertyList.append(contentsOf: superList)
                }
            }
        }
        var count:UInt32 =  0
        if let properties = class_copyPropertyList(self.classForCoder(), &count) {
            for i in 0 ..< count {
                let name = property_getName(properties[Int(i)])
                if let nameStr = String(cString: name, encoding: .utf8) {
                    propertyList.append(nameStr)
                }
            }
        }
        objc_setAssociatedObject(self, &AtomJsonConst.cachePropertyList, propertyList, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return propertyList
    }
    
    //MARK: - model -> coding -
    /// model kvc
    ///
    /// - Parameter aCoder:
    public func atom_encode(_ aCoder: NSCoder) {
        let selfType = type(of: self)
        selfType.getPropertyList().forEach { (name) in
            if let value = self.value(forKey: name) {
                aCoder.encode(value, forKey: name)
            }
        }
    }
    
    
    /// model kvc
    ///
    /// - Parameter decode:
    public func atom_decode(_ decode: NSCoder) {
        let selfType = type(of: self)
        selfType.getPropertyList().forEach { (name) in
            if let value = decode.decodeObject(forKey: name) {
                self.setValue(value, forKey: name)
            }
        }
    }
    
    //MARK: - model -> copying -
    /// model copy
    ///
    /// - Returns: copy model
    public func atom_copy() -> Self {
        let selfType = type(of: self)
        let copyModel = selfType.init()
        selfType.getPropertyList().forEach { (name) in
            if let value = self.value(forKey: name) {
                let valueType = type(of: value)
                switch valueType {
                case is _AtomJsonBasicType.Type:
                    copyModel.setValue(value, forKey: name)
                default:
                    if let copyValue = (value as? NSObject)?.copy() {
                        copyModel.setValue(copyValue, forKey: name)
                    }
                }
            }
        }
        return copyModel
    }
}

public extension Dictionary {
    
    /// map->json string
    ///
    /// - Returns: json string
    public func atom_json() -> String? {
        if let jsonMap = self.atomToValue() {
            if JSONSerialization.isValidJSONObject(jsonMap) {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonMap, options: [])
                    return String(data: jsonData, encoding: .utf8)
                }catch let error {
                    print("AtomJson: error \(error)")
                }
            }else {
                print("AtomJson: error invalid json map")
            }
            return nil
        }
        return nil
    }
}

public extension Array {
    
    //MARK: - json -> model  -
    /// json->[Model]
    ///
    /// - Parameter json: jsonデータ(文字、Dic，データData)
    /// - Returns: [Model]配列
    public static func atom_json(_ json: Any?) -> [Element]? {
        switch json {
        case let jsonList as [Any]:
            var modelList = [Element]()
            jsonList.forEach({ (each) in
                switch Element.self {
                case is AtomJson.Type:
                    if let model = (Element.self as? AtomJson.Type)?.atom_json(each) {
                        if let value = model as? Element {
                            modelList.append(value)
                        }
                    }
                case is _AtomJsonBasicType.Type:
                    if let model = (Element.self as? _AtomJsonBasicType.Type)?.atomTransform(each) {
                        if let value = model as? Element {
                            modelList.append(value)
                        }
                    }
                case is AtomJsonObjectType.Type:
                    if let model = (Element.self as? AtomJsonObjectType.Type)?._atomTransform(each) {
                        if let value = model as? Element {
                            modelList.append(value)
                        }
                    }
                default:
                    if let value = each as? Element {
                        modelList.append(value)
                    }
                }
            })
            return modelList
        case let str as String:
            let json_data = str.data(using: .utf8)
            return [Element].atom_json(json_data)
        case let data as Data:
            let json_object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return [Element].atom_json(json_object)
        case _ as Dictionary<String, Any>:
            print("Call api error,object json use api Model.json(json)")
            return nil
        default:
            print("Call api error, json not nil")
            return nil
        }
    }
    
    
    /// json->[Model]
    ///
    /// - Parameters:
    ///   - json: jsonデータ(文字、Dic，データData)
    ///   - keyPath: json keyPath
    /// - Returns: [Model]配列
    public static func atom_json(_ json: Any?, keyPath: String?) -> [Element]? {
        if json != nil {
            if keyPath != nil && keyPath != "" {
                var json_object: Any!
                switch json {
                case let str as String:
                    let json_data = str.data(using: .utf8)
                    return self.atom_json(json_data, keyPath: keyPath)
                case let data as Data:
                    json_object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    return self.atom_json(json_object, keyPath: keyPath)
                case _ as Dictionary<String, Any>,  _ as Array<Any>:
                    if let keyPathArray = keyPath?.components(separatedBy: ".") {
                        let jsonObject = _atomKeyPathValue(keyPathArray, json: json)
                        switch jsonObject {
                        case _ as Dictionary<String, Any>:
                            print("Call api error,object json use api Model.json(json)")
                            return nil
                        case _ as [Any]:
                            return [Element].atom_json(jsonObject)
                        default:
                            print("Call api error, json not nil")
                            return nil
                        }
                    }
                default:
                    print("Call api error, json not nil")
                    return nil
                }
            }
            return [Element].atom_json(json)
        }
        return nil
    }
    
    //MARK: - model -> json -
    /// [Model]配列-> json string
    ///
    /// - Parameter format: json
    /// - Returns: json string
    public func atom_json(format: Bool = false) -> String? {
        if let map = self.atom_array() {
            if JSONSerialization.isValidJSONObject(map) {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: map, options: format ? .prettyPrinted : [])
                    return String(data: jsonData, encoding: .utf8)
                }catch let error {
                    print("AtomJson: error \(error)")
                }
            }else {
                print("AtomJson: error invalid json map")
            }
            return nil
        }
        return nil
    }
    
    /// [Model]配列-> [json]
    ///
    /// - Returns: [json]
    public func atom_array() -> [Any]? {
        return self.atomToValue() as? [Any]
    }
}
