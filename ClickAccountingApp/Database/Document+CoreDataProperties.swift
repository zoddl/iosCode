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
    @NSManaged public var createdTime: String?
    @NSManaged public var primaryTag: String?
    @NSManaged public var secondaryTag: String?
    @NSManaged public var amount: String?
    @NSManaged public var tagType: String?
    @NSManaged public var date: String?
    @NSManaged public var tagDescription: String?

}
