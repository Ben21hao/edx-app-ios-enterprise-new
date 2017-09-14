//
//  OEXCourseInfoViewController+Swift.swift
//  edX
//
//  Created by Saeed Bashir on 8/25/16.
//  Copyright © 2016 edX. All rights reserved.
//

import Foundation

extension OEXCourseInfoViewController {
 
    func enrollInCourse(courseID: String, emailOpt: Bool) {
        guard let _ = OEXSession.sharedSession()?.currentUser else {
            OEXRouter.sharedRouter().showSignUpScreenFromController(self, completion: {
                self.enrollInCourse(courseID, emailOpt: emailOpt)
            })
            return;
        }
        
        let environment = OEXRouter.sharedRouter().environment;
        
        if let _ = environment.dataManager.enrollmentManager.enrolledCourseWithID(courseID) {
            showMainScreenWithMessage(TDLocalizeSelectSwift("FIND_COURSES_ALREADY_ENROLLED_MESSAGE"), courseID: courseID)
            return
        }
        
        let request = CourseCatalogAPI.enroll(courseID)
        environment.networkManager.taskForRequest(request) {[weak self] response in
            if response.response?.httpStatusCode.is2xx ?? false {
                environment.analytics.trackUserEnrolledInCourse(courseID)
                self?.showMainScreenWithMessage(TDLocalizeSelectSwift("FIND_COURSES_ENROLLMENT_SUCCESSFUL_MESSAGE"), courseID: courseID)
            }
            else {
                self?.showOverlayMessage(TDLocalizeSelectSwift("FIND_COURSES_ENROLLMENT_ERROR_DESCRIPTION"))
            }
        }
    }
}
