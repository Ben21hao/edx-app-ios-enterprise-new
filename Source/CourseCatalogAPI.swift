//
//  CourseCatalogAPI.swift
//  edX
//
//  Created by Anna Callahan on 10/14/15.
//  Copyright © 2015 edX. All rights reserved.
//

import edXCore

public struct CourseCatalogAPI {
    
    static func coursesDeserializer(response : NSHTTPURLResponse, json : JSON) -> Result<[OEXCourse]> {
        return (json.array?.flatMap {item in
            item.dictionaryObject.map { OEXCourse(dictionary: $0) }
        }).toResult()
    }
    
    static func courseDeserializer(response : NSHTTPURLResponse, json : JSON) -> Result<OEXCourse> {
        return json.dictionaryObject.map { OEXCourse(dictionary: $0) }.toResult()
    }
    
    static func enrollmentDeserializer(response: NSHTTPURLResponse, json: JSON) -> Result<UserCourseEnrollment> {
        return UserCourseEnrollment(json: json).toResult()
    }
    
    private enum Params : String {
        case User = "username"
        case CourseDetails = "course_details"
        case CourseID = "course_id"
        case EmailOptIn = "email_opt_in"
        case Mobile = "mobile"
        case Org = "org"
        case CompanyId = "company_id"
    }
    
        public static func getCourseCatalog(userID: String, company_id: String, page : Int) -> NetworkRequest<Paginated<[OEXCourse]>> {
//    public static func getCourseCatalog(userID: String, page : Int, organizationCode: String?) -> NetworkRequest<Paginated<[OEXCourse]>> {
    
//        var query = [Params.Mobile.rawValue: JSON(true), Params.User.rawValue: JSON(userID)]
//        if let orgCode = organizationCode {
//            query[Params.Org.rawValue] = JSON(orgCode)
//        }
        
       let query = [Params.Mobile.rawValue: JSON(true),
                    Params.CompanyId.rawValue: JSON(company_id),
                    Params.User.rawValue: JSON(userID)]
        
        return NetworkRequest(
            method: .GET,
            path : "/api/mobile/enterprise/v0.5/companyfindcourses/", //api/courses/v1/
            query : query,
            requiresAuth : true,
            deserializer: .JSONResponse(coursesDeserializer)
        ).paginated(page: page)
    }
    
    public static func getCourse(courseID: String, companyID : String) -> NetworkRequest<OEXCourse> {
        return NetworkRequest(
        
        // method: .GET,
        // path: "/api/mobile/enterprise/v0.5/companycoursesdetail/{courseID}".oex_formatWithParameters(["courseID" : courseID]),
        // deserializer: .JSONResponse(courseDeserializer))
        
        //api/courses/v1/courses/{courseID} 
        // /api/mobile/enterprise/v0.5/companycoursesdetail/course-v1:EliteU+11067001+A1?company_id=600000001
        
        method: .GET,
        path: "/api/mobile/enterprise/v0.5/companycoursesdetail/{courseID}".oex_formatWithParameters(["courseID" : courseID]),
        query : [Params.CompanyId.rawValue: JSON(companyID)],
        deserializer: .JSONResponse(courseDeserializer))
    }
    
    public static func enroll(courseID: String, emailOptIn: Bool = true) -> NetworkRequest<UserCourseEnrollment> {
        return NetworkRequest(
            method: .POST,
            path: "api/enrollment/v1/enrollment",
            requiresAuth: true,

            body: .JSONBody(JSON([
                "course_details" : [
                    "course_id": courseID,
                    "email_opt_in": emailOptIn
                ]
            ])),
            deserializer: .JSONResponse(enrollmentDeserializer)
        )
    }
}
