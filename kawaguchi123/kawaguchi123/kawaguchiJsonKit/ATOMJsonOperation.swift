//
//  ViewController.swift
//  kawaguchi123
//
//  Created by Lee on 2018/2/12.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import Foundation

infix operator <<<

//MARK: - AtomJsonBasicType -
public func <<< <T: _AtomJsonBasicType>(left: inout T!, right: Any?) -> Void {
    left = T.atomTransform(right)
}

public func <<< <T: _AtomJsonBasicType>(left: inout T?, right: Any?) -> Void {
    left = T.atomTransform(right)
}

public func <<< <T: _AtomJsonBasicType>(left: inout T, right: Any?) -> Void {
    if let value = T.atomTransform(right) {
        left = value
    }
}

//MARK: - AtomJsonEnumType -
public func <<< <T: AtomJsonEnumType> (left: inout T!, right: Any?) -> Void {
    left = T.atomTransform(right)
}

public func <<< <T: AtomJsonEnumType>(left: inout T?, right: Any?) -> Void {
    left = T.atomTransform(right)
}

public func <<< <T: AtomJsonEnumType>(left: inout T, right: Any?) -> Void {
    if let value = T.atomTransform(right) {
        left = value
    }
}

//MARK: - AtomJsonObjectType -
public func <<< <T: AtomJsonObjectType>(left: inout T!, right: Any?) -> Void {
    left = T._atomTransform(right) as? T
}

public func <<< <T: AtomJsonObjectType>(left: inout T?, right: Any?) -> Void {
    left = T._atomTransform(right) as? T
}

public func <<< <T: AtomJsonObjectType>(left: inout T, right: Any?) -> Void {
    if let value = T._atomTransform(right) as? T {
        left = value
    }
}


//MARK: - AtomJson -
public func <<< <T: AtomJson>(left: inout T?, right: Any?) -> Void {
    if let rightMap = right as? [String: Any] {
        left = T.init()
        left!.atomMap(rightMap)
    }
}

public func <<< <T: AtomJson>(left: inout T!, right: Any?) -> Void {
    if let rightMap = right as? [String: Any] {
        left = T.init()
        left.atomMap(rightMap)
    }
}

public func <<< <T: AtomJson>(left: inout T, right: Any?) -> Void {
    if let rightMap = right as? [String: Any] {
        left.atomMap(rightMap)
    }
}

//MARK: - [AtomJsonBasicType] -
public func <<< <T: _AtomJsonBasicType>(left: inout [T]?, right: Any?) -> Void {
    if right != nil {
        left = [T].init()
        left! <<< right
    }
}

public func <<< <T: _AtomJsonBasicType>(left: inout [T]!, right: Any?) -> Void {
    if right != nil {
        left = [T].init()
        left! <<< right
    }
}

public func <<< <T: _AtomJsonBasicType>(left: inout [T], right: Any?) -> Void {
    if let rightMap = right as? [Any] {
        rightMap.forEach({ (map) in
            left.append(T.atomTransform(map)!)
        })
    }
}

//MARK: - [AtomJsonEnumType] -
public func <<< <T: AtomJsonEnumType> (left: inout [T]!, right: Any?) -> Void {
    if right != nil {
        left = [T].init()
        left! <<< right
    }
}

public func <<< <T: AtomJsonEnumType>(left: inout [T]?, right: Any?) -> Void {
    if right != nil {
        left = [T].init()
        left! <<< right
    }
}

public func <<< <T: AtomJsonEnumType>(left: inout [T], right: Any?) -> Void {
    if let rightMap = right as? [Any] {
        rightMap.forEach({ (map) in
            left.append(T.atomTransform(map)!)
        })
    }
}

//MARK: - [AtomJsonObjectType] -
public func <<< <T: AtomJsonObjectType>(left: inout [T]!, right: Any?) -> Void {
    if right != nil {
        left = [T].init()
        left! <<< right
    }
}

public func <<< <T: AtomJsonObjectType>(left: inout [T]?, right: Any?) -> Void {
    if right != nil {
        left = [T].init()
        left! <<< right
    }
}

public func <<< <T: AtomJsonObjectType>(left: inout [T], right: Any?) -> Void {
    if let rightMap = right as? [Any] {
        rightMap.forEach({ (map) in
            if let value = T._atomTransform(map) as? T {
                left.append(value)
            }
        })
    }
}

//MARK: - [AtomJson] -
public func <<< <T: AtomJson>(left: inout [T]?, right: Any?) -> Void {
    if right != nil {
        left = [T].init()
        left! <<< right
    }
}

public func <<< <T: AtomJson>(left: inout [T]!, right: Any?) -> Void {
    if right != nil {
        left = [T].init()
        left! <<< right
    }
}

public func <<< <T: AtomJson>(left: inout [T], right: Any?) -> Void {
    if let rightMap = right as? [Any] {
        rightMap.forEach({ (map) in
            if let elementMap = map as? [String : Any] {
                var element = T.init()
                element.atomMap(elementMap)
                left.append(element)
            }
        })
    }
}

