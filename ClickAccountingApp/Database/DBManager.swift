//
//  DBManager.swift
//  ClickAccountingApp
//
//  Created by apptology on 1/23/18.
//  Copyright © 2018 Mobiloitte. All rights reserved.
//

import UIKit
import CoreData

class DBManager: NSObject {
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
}
