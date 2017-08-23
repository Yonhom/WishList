//
//  ViewController.swift
//  WishList
//
//  Created by 徐永宏 on 2017/8/20.
//  Copyright © 2017年 徐永宏. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    /**
     * core data generate & fetch controller
     */
    var resultController: NSFetchedResultsController<Item>!
    
    // the MOC: managed object context
    var mocContext = (UIApplication.shared.delegate as! AppDelegate).mocContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // generate test data
//        generateTestData()
        
        // fetch result in core data
        fetchAttempt()
        
        // set the data source and delegate of the tableview to the current view controller
        tableView.delegate = self
        tableView.dataSource = self
        
        // set the fetched result controller's delegate the current view controller
        resultController.delegate = self
        
    }
    
    func generateTestData() {
        let item0 = Item(context: mocContext) // the item inistantiated is inserted in the context scratch pad
        item0.title = "Haha"
        item0.price = 99.99
        item0.details = "hahahahahahahahahahahaha"
        
        let item1 = Item(context: mocContext)
        item1.title = "Hehe"
        item1.price = 88.88
        item1.details = "hehehehehehehehehehehehe"
        
        // sync it to the exteral storage
        do {
            try mocContext.save() // save the data on the context scratch pad to the storage
        } catch {
            print("data persistance error:\(error)")
        }
    }
    
    func fetchAttempt() {
        // the fetch request
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        let sortDesc = NSSortDescriptor(key: "generated", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc]
        
        // the controller for generating and fetching data
        resultController = NSFetchedResultsController<Item>(
            fetchRequest: fetchRequest,
            managedObjectContext: mocContext,
            sectionNameKeyPath: nil, cacheName: nil)
        
        // do the fetching
        do {
            try resultController.performFetch()
        } catch {
            print("Fetching data with error: \(error)")
        }
    }
    
    /**
     method for updating cell
     */
    func update(_ cell: WishItemCell, with item: Item) {
        cell.updateCell(with: item)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "AddDetail" {
                
            }
            if identifier == "EditDetail" {
                let destinationVC = segue.destination as! DetailVC
                let wishItem = sender as! Item
                destinationVC.wishItem = wishItem
            }

        }
        
    }
    
    // MARK: CoreData FetchResultController's delegate method --- for communicating data change to the table view
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            break
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
            break
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            break
            
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            break
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            break
        case .update:
            break
        case .move:
            break
            
        }
    }
    
    // MARK: tableview's datasource & delegate method --- for fill data to the table view
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = resultController.sections {
            return sections.count
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = resultController.sections, let objects = sections[section].objects {
            return objects.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WishItemCell", for: indexPath) as? WishItemCell else {
            fatalError("fatal error with dequeuing WishItemCell!")
        }
        
        // update the cell with wishItem
        // get the item at the cell index
        let wishItem = resultController.object(at: indexPath)
        update(cell, with: wishItem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue to detail page with item to be updated
        let itemToEdit = resultController.object(at: indexPath)
        performSegue(withIdentifier: "EditDetail", sender: itemToEdit)
    }
    
    // MARK: delete-related tableview method
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    // implement this method to open swipe to delete functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let itemToDelete = resultController.object(at: indexPath)
        mocContext.delete(itemToDelete)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
}

