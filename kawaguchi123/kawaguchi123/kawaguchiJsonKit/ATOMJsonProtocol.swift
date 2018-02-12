//
//  ViewController.swift
//  kawaguchi123
//
//  Created by Lee on 2018/2/12.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#else
    import AppKit
#endif

#if os(iOS) || os(tvOS) || os(watchOS)
    public typealias AtomColor = UIColor
#else
    public typealias AtomColor = NSColor
#endif

//MARK: - Public protocol -
public protocol _AtomJsonBase {
    func atomToValue() -> Any?
}

public protocol _AtomJsonInitBase: _AtomJsonBase {
    init()
}

public protocol _AtomJsonBasicType: _AtomJsonBase {
    static func atomTransform(_ value: Any?) -> Self?
}

public protocol _AtomJsonObjectType: _AtomJsonInitBase {}
public protocol AtomJsonBasicType: _AtomJsonBasicType{}
public protocol AtomJsonCollectionType: _AtomJsonBasicType{}
public protocol AtomJsonEnumType: AtomJsonBasicType{}
public protocol AtomJsonObjectType: _AtomJsonObjectType {
    static func _atomTransform(_ value: Any?) -> Any?
}

public protocol AtomJson: _AtomJsonInitBase {
    mutating func atomMap(_ map: [String : Any]) -> Void
}


public extension AtomJson {
    public func atomToValue() -> Any? {
        let mirror = Mirror(reflecting: self)
        var jsonMap = [String: Any]()
        var children = [(label: String?, value: Any)]()
        let mirrorChildrenCollection = AnyRandomAccessCollection(mirror.children)!
        children += mirrorChildrenCollection
        var currentMirror = mirror
        while let superclassChildren = currentMirror.superclassMirror?.children {
            let randomCollection = AnyRandomAccessCollection(superclassChildren)!
            children += randomCollection
            currentMirror = currentMirror.superclassMirror!
        }
        children.enumerated().forEach({ (index, element) in
            if let key = element.label, !key.isEmpty {
                if let value = (element.value as? _AtomJsonBase)?.atomToValue() {
                    jsonMap[key] = value
                }
            }
        })
        return jsonMap
    }
}

extension ImplicitlyUnwrappedOptional: _AtomJsonBase {
    public func atomToValue() -> Any? {
        return self == nil ? nil : (self! as? _AtomJsonBase)?.atomToValue()
    }
}

extension Optional: _AtomJsonBase {

    public func atomToValue() -> Any? {
        return self == nil ? nil : (self! as? _AtomJsonBase)?.atomToValue()
    }
}

//MARK: - Internal protocol -
public protocol AtomJsonBoolType:AtomJsonBasicType {}

extension AtomJsonBoolType {
    public static func atomTransform(_ object: Any?) -> Bool? {
        switch object {
        case let str as NSString:
            let lowerCase = str.lowercased
            if ["0", "false"].contains(lowerCase) {
                return false
            }
            if ["1", "true"].contains(lowerCase) {
                return true
            }
            return false
        case let num as NSNumber:
            return num.boolValue
        default:
            return false
        }
    }
    
    public func atomToValue() -> Any? {
        return self
    }
}

public protocol AtomJsonFloatType:AtomJsonBasicType, LosslessStringConvertible {
    init(_ number: NSNumber)
}

extension AtomJsonFloatType {
    public static func atomTransform(_ value: Any?) -> Self? {
        switch value {
        case let str as String:
            return Self(str)
        case let num as NSNumber:
            return Self(num)
        default:
            return Self(0.0)
        }
    }
    
    public func atomToValue() -> Any? {
        return self
    }
}

public protocol AtomJsonIntType:AtomJsonBasicType, BinaryInteger {
    init?(_ text: String, radix: Int)
    init(_ number: NSNumber)
}

extension AtomJsonIntType {
    public static func atomTransform(_ value: Any?) -> Self? {
        switch value {
        case let str as String:
            return Self(str, radix: 10)
        case let num as NSNumber:
            return Self(num)
        default:
            return Self(0)
        }
    }
    
    public func atomToValue() -> Any? {
        return self
    }
}

public protocol AtomJsonCGFloatType: AtomJsonBasicType {
    
}
extension AtomJsonCGFloatType {
    public static func atomTransform(_ value: Any?) -> CGFloat? {
        switch value {
        case let str as String:
            return CGFloat((str as NSString).floatValue)
        case let num as NSNumber:
            return CGFloat(num.floatValue)
        default:
            return 0
        }
    }
    
    public func atomToValue() -> Any? {
        return self
    }
    
}

extension CGFloat: AtomJsonCGFloatType {}
extension Bool: AtomJsonBoolType {}
extension Float: AtomJsonFloatType {}
extension Double: AtomJsonFloatType {}
extension Int: AtomJsonIntType {}
extension UInt: AtomJsonIntType {}
extension Int8: AtomJsonIntType {}
extension Int16: AtomJsonIntType {}
extension Int32: AtomJsonIntType {}
extension Int64: AtomJsonIntType {}
extension UInt8: AtomJsonIntType {}
extension UInt16: AtomJsonIntType {}
extension UInt32: AtomJsonIntType {}
extension UInt64: AtomJsonIntType {}

extension NSNumber: AtomJsonObjectType {
    public static func _atomTransform(_ value: Any?) -> Any? {
        switch value {
        case let str as String:
            return NSNumber(value: (str as NSString).floatValue)
        case let num as NSNumber:
            return num
        default:
            return NSNumber(value: 0)
        }
    }
    
    public func atomToValue() -> Any? {
        return self
    }
}

extension String: AtomJsonBasicType {
    public static func atomTransform(_ value: Any?) -> String? {
        switch value {
        case let str as String:
            return str
        case let num as NSNumber:
            if NSStringFromClass(type(of: num)) == "__NSCFBoolean" {
                if num.boolValue {
                    return "true"
                }
                return "false"
            }
            return num.stringValue
        default:
            if let vl = value {
                switch vl {
                case nil, is NSNull:
                    return ""
                default:
                    return "\(vl)"
                }
            }
            return ""
        }
    }
    
    public func atomToValue() -> Any? {
        return self
    }
}

extension NSString: AtomJsonObjectType {
    public static func _atomTransform(_ value: Any?) -> Any? {
        if let str = String.atomTransform(value) {
            return NSString(string: str)
        }
        return ""
    }
    
    public func atomToValue() -> Any? {
        return self
    }
}

extension Array: AtomJsonCollectionType {
    public static func atomTransform(_ value: Any?) -> [Element]? {
        guard let array = value as? NSArray else {
            print("AtomJson: Expect value not NSArray")
            return nil
        }
        typealias Element = Iterator.Element
        var result: [Element] = [Element]()
        array.forEach { (each) in
            if let element = (Element.self as? _AtomJsonBasicType.Type)?.atomTransform(each) as? Element {
                result.append(element)
            }else if let element = (Element.self as? AtomJsonObjectType.Type)?._atomTransform(each) as? Element {
                result.append(element)
            }else if let element = (Element.self as? AtomJson.Type)?.atom_json(each) as? Element {
                result.append(element)
            }else if let element = each as? Element {
                result.append(element)
            }
        }
        return result
    }
    
    public func atomToValue() -> Any? {
        var jsonArray = [Any]()
        self.forEach { (element) in
            if let value = (element as? _AtomJsonBase)?.atomToValue() {
                jsonArray.append(value)
            }
        }
        return jsonArray
    }
}

extension Set: AtomJsonCollectionType {
    public static func atomTransform(_ value: Any?) -> Set? {
        guard let array = value as? NSArray else {
            print("AtomJson: Expect value not NSArray")
            return nil
        }
        typealias Element = Iterator.Element
        var result = Set<Element>()
        array.forEach { (each) in
            if let element = (Element.self as? _AtomJsonBasicType.Type)?.atomTransform(each) as? Element {
                result.insert(element)
            }else if let element = (Element.self as? AtomJsonObjectType.Type)?._atomTransform(each) as? Element {
                result.insert(element)
            }else if let element = (Element.self as? AtomJson.Type)?.atom_json(each) as? Element {
                result.insert(element)
            }else if let element = each as? Element {
                result.insert(element)
            }
        }
        return result
    }
    
    public func atomToValue() -> Any? {
        var jsonArray = [Any]()
        self.forEach { (element) in
            if let value = (element as? _AtomJsonBase)?.atomToValue() {
                jsonArray.append(value)
            }
        }
        return jsonArray
    }
}

extension Dictionary: AtomJsonCollectionType {
    public static func atomTransform(_ value: Any?) -> Dictionary? {
        guard let nsDict = value as? NSDictionary else {
            print("AtomJson: Expect value not NSDictionary")
            return nil
        }
        var result: [Key: Value] = [Key: Value]()
        for (key, value) in nsDict {
            if let sKey = key as? Key, let nsValue = value as? NSObject {
                if let nValue = (Value.self as? _AtomJsonBasicType.Type)?.atomTransform(nsValue) as? Value {
                    result[sKey] = nValue
                }else if let nValue = (Value.self as? AtomJsonObjectType.Type)?._atomTransform(nsValue) as? Value {
                    result[sKey] = nValue
                }else if let nValue = (Value.self as? AtomJson.Type)?.atom_json(nsValue) as? Value {
                    result[sKey] = nValue
                }else if let nValue = nsValue as? Value {
                    result[sKey] = nValue
                }
            }
        }
        return result
    }
    
    public func atomToValue() -> Any? {
        var jsonMap = [String: Any]()
        self.forEach { (key,value) in
            if let val = (value as? _AtomJsonBase)?.atomToValue() {
                jsonMap[key as! String] = val
            }
        }
        return jsonMap
    }
}

public extension RawRepresentable where Self: AtomJsonEnumType {
    public static func atomTransform(_ value: Any?) -> Self? {
        if let transforType = RawValue.self as? AtomJsonBasicType.Type {
            if let typedValue = transforType.atomTransform(value) {
                return Self(rawValue: typedValue as! RawValue)
            }
        }
        return nil
    }
    
    public func atomToValue() -> Any? {
        return self.rawValue
    }
}

extension NSData: AtomJsonObjectType {
    public static func _atomTransform(_ value: Any?) -> Any? {
        return Data.atomTransform(value)
    }
    
    public func atomToValue() -> Any? {
        return (self as Data).atomToValue()
    }
}

extension Data: AtomJsonBasicType {
    public static func atomTransform(_ value: Any?) -> Data? {
        switch value {
        case let num as NSNumber:
            return num.stringValue.data(using: .utf8)
        case let str as NSString:
            return str.data(using: String.Encoding.utf8.rawValue)
        case let data as NSData:
            return data as Data
        default:
            return nil
        }
    }
    
    public func atomToValue() -> Any? {
        return String(data: self, encoding: .utf8)
    }
}

extension NSDate: AtomJsonObjectType {
    public static func _atomTransform(_ value: Any?) -> Any? {
        return Date.atomTransform(value)
    }
    
    public func atomToValue() -> Any? {
        return (self as Date).atomToValue()
    }
}

extension Date: AtomJsonBasicType {
    public static func atomTransform(_ value: Any?) -> Date? {
        switch value {
        case let num as NSNumber:
            return Date(timeIntervalSince1970: num.doubleValue)
        case let str as NSString:
            return Date(timeIntervalSince1970: TimeInterval(atof(str as String)))
        default:
            return nil
        }
    }
    
    public func atomToValue() -> Any? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter.string(from: self)
    }
}

extension NSURL: AtomJsonObjectType {
    public static func _atomTransform(_ value: Any?) -> Any? {
        return URL.atomTransform(value)
    }
    
    public func atomToValue() -> Any? {
        return self.absoluteString
    }
}

extension URL: AtomJsonBasicType {
    public static func atomTransform(_ value: Any?) -> URL? {
        switch value {
        case let str as NSString:
            return URL(string: str as String)
        default:
            return nil
        }
    }
    
    public func atomToValue() -> Any? {
        return self.absoluteString
    }
}

extension AtomColor: AtomJsonObjectType {
    
    fileprivate func colorString() -> String {
        let comps = self.cgColor.components!
        let r = Int(comps[0] * 255)
        let g = Int(comps[1] * 255)
        let b = Int(comps[2] * 255)
        let a = Int(comps[3] * 255)
        var hexString: String = "#"
        hexString += String(format: "%02X%02X%02X", r, g, b)
        hexString += String(format: "%02X", a)
        return hexString
    }
    
    fileprivate static func getColor(hex: String) -> AtomColor? {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0
        
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hex.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                // Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8
                return nil
            }
        } else {
            // "Scan hex error
            return nil
        }
        #if os(iOS) || os(tvOS) || os(watchOS)
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        #else
            return NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
        #endif
    }
    
    public static func _atomTransform(_ value: Any?) -> Any? {
        switch value {
        case let str as String:
            return getColor(hex: str)
        default:
            return nil
        }
    }
    
    public func atomToValue() -> Any? {
        return colorString()
    }
}
