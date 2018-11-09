//
//  CoreDataStack.swift
//  Todo-CoreData
//
//  Created by qbit on 08/11/18.
//  Copyright © 2018 qbit.co.id. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Todos")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        return container
    }
    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
}
