//
//  ViewController.swift
//  kawaguchi123
//
//  Created by Lee on 2018/2/12.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonString = try! String(contentsOfFile: Bundle.main.path(forResource: "ModelObject", ofType: "json")!, encoding: .utf8)
        let jsonData = jsonString.data(using: .utf8)
        
        print("***************** Model *****************\n\n")
        print("json -> model:")
        let model = ModelObject.atom_json(jsonData)
        print("model = \(String(describing: model))")
        print("\n---------------------------------------------------\n")
        
        print("model -> Dic:")
        let modelDict = model?.atom_dictionary()
        print("modelDict = \(modelDict!)")
        print("\n---------------------------------------------------\n")
        
        print("model  -> jsonString:")
        let modelJson = model?.atom_json()
        print("modelJson = \(modelJson!)")
        
        
        
        print("\n***************** [Model] *****************\n\n")
        print("json -> [Model] :")
        let arrayModel = [SubArray].atom_json(modelJson,keyPath: "subArray")
        print("arrayModel = \(arrayModel!)")
        print("\n---------------------------------------------------\n")
        /* keyPath 使用法
         let subArrayModel = SubArray.atom_json(modelJson,keyPath: "subArray[0]")
         let subNestArray = NestArray.atom_json(modelJson,keyPath: "nestArray[0][0]")
         let test = String.atom_json(modelJson, keyPath: "nestArray[0][0].test")
         */
        
        print("[model]  -> :")
        let arrayModelArray = arrayModel?.atom_array()
        print("arrayModelArray = \(arrayModelArray!)")
        print("\n---------------------------------------------------\n")
        
        print("[model]  -> jsonstring:")
        let arrayModelJson = arrayModel?.atom_json(format: true)
        print("arrayModelJson = \(arrayModelJson!)")
        
        
        print("\n***************** Model Coding *****************\n\n")
        let modelCoding = Sub.atom_json(jsonData, keyPath: "sub")
        if let modelCodingData = try? JSONEncoder().encode(modelCoding) {
            if let modelUncoding = try? JSONDecoder().decode(Sub.self, from: modelCodingData) {
                print("modelUncodingJson = \(modelUncoding.atom_json()!)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

