//
//  Document+CoreDataProperties.swift
//  
//
//  Created by apptology on 1/23/18.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var docType: String?
    @NSManaged public var createdTime: Double
    @NSManaged public var primaryName: String?
    @NSManaged public var secondaryTag: String?
    @NSManaged public var amount: String?
    @NSManaged public var tagType: String?
    @NSManaged public var tagDate: String?
    @NSManaged public var tagDescription: String?
    @NSManaged public var tagStatus: Int16
    @NSManaged public var isUploaded: Int16
    @NSManaged public var docPath: String?
    @NSManaged public var docImageURL: String?

}
