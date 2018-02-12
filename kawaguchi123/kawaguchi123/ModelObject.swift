//
//  ViewController.swift
//  kawaguchi123
//
//  Created by Lee on 2018/2/12.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import UIKit

enum WorkEnum: String,AtomJsonEnumType {
    case null = "nil"
    case one = "Work"
    case two = "Not Work"
}

enum IntEnum: Int,AtomJsonEnumType {
    case zero = 0
    case hao = 10
    case xxx = 20
}


struct Cls :AtomJson {

    
    var age: Int = 0
    var name: String!
    
    public mutating func atomMap(_ map: [String : Any]) {
        
        age        <<<        map["age"]
        name       <<<        map["name"]
    }
    
}

struct SubArray :AtomJson {
    
    var test3: String!
    var test2: String!
    var cls: Cls!
    var test1: String!
    
    public mutating func atomMap(_ map: [String : Any]) {
        
        test3        <<<        map["test3"]
        test2        <<<        map["test2"]
        cls          <<<        map["cls"]
        test1        <<<        map["test1"]
    }
    
}

struct NestArray :AtomJson {
    var test: String!
    
    public mutating func atomMap(_ map: [String : Any]) {
        
        test        <<<        map["test"]
    }
    
}

class Sub: Codable, AtomJson {
    
    required init() {
    }
    
    var test1: String!
    var test2: String!
    var test3: String!
    
    public func atomMap(_ map: [String : Any]) {
        
        test1        <<<        map["test1"]
        test2        <<<        map["test2"]
        test3        <<<        map["test3"]
    }
    
}

struct ModelObject :AtomJson {
    
    var age: Int = 0
    var enmuStr: WorkEnum!
    var url: URL!
    var subArray: [SubArray]!
    var color: UIColor!
    var nestArray: [[NestArray]]?
    var enmuInt: IntEnum = .xxx
    var sub: Sub!
    var height: Int = 0
    var intArray: [Int]!
    var name: String!
    var learn: [String]!
    
    public mutating func atomMap(_ map: [String : Any]) {
        
        age            <<<        map["age"]
        enmuStr        <<<        map["enmuStr"]
        url            <<<        map["url"]
        subArray       <<<        map["subArray"]
        color          <<<        map["color"]
        nestArray      <<<        map["nestArray"]
        
        enmuInt        <<<        map["enmuInt"]
        sub            <<<        map["sub"]
        height         <<<        map["height"]
        intArray       <<<        map["intArray"]
        name           <<<        map["name"]
        learn          <<<        map["learn"]
    }
    
}
