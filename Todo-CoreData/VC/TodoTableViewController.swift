//
//  TodoTableViewController.swift
//  Todo-CoreData
//
//  Created by qbit on 08/11/18.
//  Copyright © 2018 qbit.co.id. All rights reserved.
//

import UIKit
import CoreData

class TodoTableViewController: UITableViewController {
    
    //MARK: -Properties
    
    var resultController: NSFetchedResultsController<Todo>!
    let coreDataStack = CoreDataStack()

    override func viewDidLoad() {
        super.viewDidLoad()
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        // Init
        request.sortDescriptors = [sortDescriptors]
        resultController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        resultController.delegate = self
        // Fetch
        do {
         try resultController.performFetch()
        }
        catch {
            print("Perform Fetch Error:\(error)")
        }
    }
    
    // MARK:  - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)

        // Configure the cell...
        let todo = resultController.object(at: indexPath)
        cell.textLabel?.text = todo.title

        return cell
    }
    
    // Mark: Table View Delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive , title: "Delete") { (action,
            view, completion) in
            
            // TODO: Delete todo
            let todo = self.resultController.object(at: indexPath)
            self.resultController.managedObjectContext.delete(todo)
            do {
                try self.resultController.managedObjectContext.save()
                completion(true)
            }
            catch {
                print("Error delete todo: \(error)")
            }
        }
        action.image = #imageLiteral(resourceName: "trash")
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive , title: "Check") { (action,
            view, completion) in
            let todo = self.resultController.object(at: indexPath)
            self.resultController.managedObjectContext.delete(todo)
            do {
                try self.resultController.managedObjectContext.save()
                completion(true)
            }
            catch {
                print("Error delete todo: \(error)")
            }
        }
        action.image = #imageLiteral(resourceName: "check")
        action.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowAddTodo", sender: tableView.cellForRow(at: indexPath))
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultController.managedObjectContext
        }
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddTodoViewController {
            vc.managedContext = resultController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                let todo = resultController.object(at: indexPath)
                vc.todo = todo
            }
        }
    }

}

extension TodoTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let todo = resultController.object(at: indexPath)
                cell.textLabel?.text = todo.title
            }
        default:
            break
        }
    }
}
