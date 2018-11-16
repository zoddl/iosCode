let windowHeight = UIScreen.main.bounds.size.height//
//  Constants.swift
//  ClickAccountingApp
//
//  Created by Ratneshwar Singh on 7/7/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import Foundation
import UIKit

let kAppDelegate = UIApplication.shared.delegate as! AppDelegate
let windowWidth = UIScreen.main.bounds.size.width

//Production
let kBaseURL =  "http://zoddl.in/"

//Staging
//let kBaseURL =  "http://13.127.139.247/"

//Production
let kBucketName =   "zoddl-prd"
//let kBucketName =   "zoddl-development"

//Production
let kImageBaseURL =  "https://s3.amazonaws.com/zoddl-prd/"
//let kImageBaseURL =  "https://s3.amazonaws.com/zoddl-development/"
let kTypeIOS = "i"
let kServiceType = "serviceType"
let kDeviceType = "Device_Type"
let kDeviceToken = "Device_Token"
let kLoginType = "Login_Type"
let kSocialId = "Social_Id"
let kDeviceID = "Device_Id"
let kPassword = "Password"
let kEmail = "Email_Id"
let kZoddl = "Zoddl"
let kAPIPayload = "Payload"


//API calls

let kGetDocumentTags = "Document_Api/gallerytag"



let kResponseCode = "ResponseCode"
let kResponseMessage = "ResponseMessage"
let kCustomerDetail = "CustomerDetail"
let kSecondaryTags = "SecondaryTag"
let kTagImageURL = "Image_Url"
let kTagImageThumbURL = "Image_Url_Thumb"
let kTagDocThumbURL = "Doc_Url"


let kAllTagList = "Taglist"

let kPrimary = "Primary"
let kSecondary = "Secondary"


let kAllPrimaryTags = "PrimaryTags"
let kAllSecondaryTags = "SecondaryTags"

let kAllGalleryPrimaryTags = "GalleryPrimaryTags"


let kAdharNumber = "aadhar_number"
let kCity = "city"
let kCompanyName = "company_name"
let kDOB = "dob"
let kFirstName = "first_name"
let kGender = "gender"
let kGSTN = "gstn"


let kPermissionType = "type"
let kPermissionValue = "value"

let kCustomerName = "Customer_Name"

let kID = "Customerid"
let kAuthtoken = "Authtoken" 
let kIsUploaded = "isUploaded"
let kCurrentTimestamp = "CurrentTimeStamp"
let kLastestTimestamp = "Timestamp"


let kPaidStatus = "Paid_Status"

let kImage = "image"
let kLastName = "last_name"
let kPanNumber = "pan_number"
let kMobileNumber = "phone"
let kAltMobileNumber = "alt_phone"
let kProfileImage = "profile_image_url"
let kWebsite = "Website"



let kSkypeId = "skype_id"
let kPrimaryTag = "Primary_Tag"
let kPrimaryTagId = "Id"
let kTagId = "Id"


let kPrimaryName = "Prime_Name"
let kPrimaryDescription = "Description"
let kPrimaryImages = "Images"
let kUserDefaults = UserDefaults.standard
let kReportData = "reportjson"

let kTotalAmout = "Total_Amount"

let kSourceType = "Source_Type"



let kMonth = "Month"
let kTotal = "Total"
let kCount = "Count"

let kLocallySavedTag = "savedTag"
let kLocallySavedCameraTag = "savedCameraTag"

let kSecondaryName = "Secondary_Name"
let kUserEmail = "Email_Id"
let kPageNumber = "Page"


let kSecondaryTag = "Secondary_Tag"
let kAmount = "Amount"
let kTagDate = "Tag_Send_Date"
let kTagStatus = "Tag_Status"
let kTagType = "Tag_Type"
let kTagDescription = "Description"

let kBankPlus = "bank+"
let kBankMinus = "bank-"
let kCashPlus = "cash+"
let kCashMinus = "cash-"
let kOther = "other"


let kCGST = "CGST"
let kSGST = "SGST"
let kIGST = "IGST"
let kMessage = "Message"




