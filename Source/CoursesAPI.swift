//
//  CoursesAPI.swift
//  edX
//
//  Created by Akiva Leffert on 12/21/15.
//  Copyright © 2015 edX. All rights reserved.
//

import Foundation
import edXCore

struct CoursesAPI {
    
    static func enrollmentsDeserializer(response: NSHTTPURLResponse, json: JSON) -> Result<[UserCourseEnrollment]> {
        return (json.array?.flatMap { UserCourseEnrollment(json: $0) }).toResult()
    }
    
    //我的课程
    static func getUserEnrollments(username: String, organizationCode: String? ,companyId: String) -> NetworkRequest<[UserCourseEnrollment]> {
        
//        print("username --->> \(username), == companyId -->> \(companyId)")
        
        var path = "api/mobile/enterprise/v0.5/{username}/course_enrollments/".oex_formatWithParameters(["username": username])
        
        if let orgCode = organizationCode {
            path = "api/mobile/enterprise/v0.5/{username}/course_enrollments/?org={org}".oex_formatWithParameters(["username": username, "org": orgCode])
        }
        
        return NetworkRequest(
            method: .GET,
            path: path,
            requiresAuth: true,
            deserializer: .JSONResponse(enrollmentsDeserializer)
        )
    }
}
