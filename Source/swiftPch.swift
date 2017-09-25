//
//  swiftPch.swift
//  edX
//
//  Created by Elite Edu on 16/12/1.
//  Copyright © 2016年 edX. All rights reserved.
//

import UIKit

/* 服务器 */
//let ELITEU_URL = OEXConfig.sharedConfig().apiHostURL //swift不能从文件中读取域名

//let ELITEU_URL = "http://192.168.0.182:8000"
//let ELITEU_URL = "http://demo.e-ducation.cn" //f版 - 测试
//let ELITEU_URL = "http://enterprise.e-ducation.cn" //企业生产
let ELITEU_URL = "https://enterprise.e-ducation.cn" //https 企业生产
//let ELITEU_URL = "https://enterprise.demo.e-ducation.cn"


let TDScreenWidth = UIScreen.mainScreen().bounds.size.width
let TDScreenHeight = UIScreen.mainScreen().bounds.size.height

func TDLocalizeSelectSwift(key: String) -> String {
    return LanguageChangeTool.bundle().localizedStringForKey(key, value: nil, table: "Localizable")
}

func TDNotificationCenter() -> NSNotificationCenter {
    return NSNotificationCenter.defaultCenter()
}
