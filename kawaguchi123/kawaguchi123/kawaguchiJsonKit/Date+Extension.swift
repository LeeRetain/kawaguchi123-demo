//
//  NSDate+Extension.swift
//  SwiftHaveOC
//
//  Created by Lee on 2018/2/10.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import UIKit
import Foundation

extension Date {
    static func getTitleDateString(curDatestr: String, preDatestr:String) -> String{
        if curDatestr.isEmpty{
            return ""
        }
        else{
            let dateCur = Date(timeIntervalSince1970: TimeInterval(curDatestr)!)
            var datePre = Date()
            if !preDatestr.isEmpty{
                datePre = Date(timeIntervalSince1970: TimeInterval(preDatestr)!)
            }
            let calendar = Calendar.current
            let compCur = calendar.dateComponents([.year,.month,.day], from: dateCur)
            let compPre = calendar.dateComponents([.year,.month,.day], from: datePre)
            
            // 年
            if compCur.year==compPre.year{
                // 月
                if compCur.year==compPre.year && compCur.month==compPre.month{
                    if compCur.year==compPre.year && compCur.month==compPre.month && compCur.day==compPre.day{
                        return "今天"
                    }
                    else{
                        // テンプレートから時刻を表示
                        let format = DateFormatter()
                        format.setTemplate(.customMonth)
                        return format.string(from: dateCur)
                    }
                }
                else{
                    // テンプレートから時刻を表示
                    let format = DateFormatter()
                    format.setTemplate(.customMonth)
                    return format.string(from: dateCur)
                }
            }
            else{
                // テンプレートから時刻を表示
                let format = DateFormatter()
                format.setTemplate(.customYear)
                return format.string(from: dateCur)
            }
        }
    }
    
    static func getDetailTitleDateString(curDatestr: String) -> String{
        if curDatestr.isEmpty{
            return ""
        }
        else{
            let dateCur = Date(timeIntervalSince1970: TimeInterval(curDatestr)!)
            let format = DateFormatter()
            format.setTemplate(.customHour)
            return format.string(from: dateCur)
        }
    }
}

extension DateFormatter {
    // テンプレートの定義(例)
    enum Template: String {
        case era  = "GG"      // "西暦" (default) or "平成" (本体設定で和暦を指定している場合)
        case full = "yMdkHms" // 2017/1/1 12:39:22
        case date = "yMd"     // 2017/1/1
        case time = "Hms"     // 12:39:22
        case shortTime = "Hm" // 12:39
        case onlyHour  = "k"    // 12時
        case weekDay   = "EEEE" // 日曜日
        case customYear  = "yyyy/MM/dd"
        case customMonth = "M/d(EE)"
        case customHour  = "HH:mm"
    }
    // 冗長な関数のためラップ
    func setTemplate(_ template: Template) {
        // optionsは拡張のためにあるが使用されていない引数
        // localeは省略できないがほとんどの場合currentを指定する
        dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: .current)
    }
}
