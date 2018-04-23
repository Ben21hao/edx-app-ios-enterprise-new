//
//  swiftPch.swift
//  edX
//
//  Created by Elite Edu on 16/12/1.
//  Copyright © 2016年 edX. All rights reserved.
//

import UIKit

/* 服务器 */
//let ELITEU_URL = OEXConfig.sharedConfig().apiHostURL() 



let TDScreenWidth = UIScreen.mainScreen().bounds.size.width
let TDScreenHeight = UIScreen.mainScreen().bounds.size.height

func TDLocalizeSelectSwift(key: String) -> String {
    return LanguageChangeTool.bundle().localizedStringForKey(key, value: nil, table: "Localizable")
}

func TDNotificationCenter() -> NSNotificationCenter {
    return NSNotificationCenter.defaultCenter()
}
