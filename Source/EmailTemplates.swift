//
//  EmailTemplateDataFactory.swift
//  edX
//
//  Created by Danial Zahid on 2/20/17.
//  Copyright © 2017 edX. All rights reserved.
//

import UIKit

class EmailTemplates {
    
    static func supportEmailMessageTemplate() -> String {
        let osVersionText = TDLocalizeSelectSwift("SUBMIT_FEEDBACK.OS_VERSION").oex_formatWithParameters(["version" :  UIDevice.currentDevice().systemVersion])
        let appVersionText = TDLocalizeSelectSwift("SUBMIT_FEEDBACK.APP_VERSION").oex_formatWithParameters(["version" : NSBundle.mainBundle().oex_shortVersionString(), "build" : NSBundle.mainBundle().oex_buildVersionString()])
        let deviceModelText = TDLocalizeSelectSwift("SUBMIT_FEEDBACK.DEVICE_MODEL").oex_formatWithParameters(["model" : UIDevice.currentDevice().model])
        let body = ["\n", TDLocalizeSelectSwift("SUBMIT_FEEDBACK.MARKER"), osVersionText, appVersionText, deviceModelText].joinWithSeparator("\n")
        return body
    }
    
}
