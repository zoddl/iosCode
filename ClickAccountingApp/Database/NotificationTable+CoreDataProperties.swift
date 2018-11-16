//
//  NotificationTable+CoreDataProperties.swift
//  
//
//  Created by Abhishek  Chauhan on 20/03/18.
//
//

import Foundation
import CoreData


extension NotificationTable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationTable> {
        return NSFetchRequest<NotificationTable>(entityName: "NotificationTable")
    }

    @NSManaged public var message: String?
    @NSManaged public var notificationKey: String?
    @NSManaged public var title: String?
}
