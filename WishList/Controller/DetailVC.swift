//
//  DetailVC.swift
//  WishList
//
//  Created by 徐永宏 on 2017/8/20.
//  Copyright © 2017年 徐永宏. All rights reserved.
//

import UIKit
import CoreData

class DetailVC: UIViewController, UINavigationBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var detailNavBar: UINavigationBar!
    
    /**
     * for dynamically changing the title of the bar
     */
    @IBOutlet weak var detailNavItem: UINavigationItem!
    /**
     * for adding a gesture recognizer to change image
     */
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var productName: UITextView!
    
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var productDetail: UITextView!
    @IBOutlet weak var productStore: UIPickerView!
    
    /**
     * core data context for scratching data on it
     */
    var mocContext: NSManagedObjectContext!
    
    /**
     * for store and fetch store data
     */
    var resultController: NSFetchedResultsController<Store>!
    
    /**
     * the wishitem for the current detail page
     * if the item is nil, we are at adding new item page, else at editing page
     */
    var wishItem: Item!
    
    /**
     for choosing image for the detail page
     */
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
    }
    
    func initialize() {
        mocContext = (UIApplication.shared.delegate as! AppDelegate).mocContext
        
        // set a delegate for navi bar, to extend navibar to the screen top
        detailNavBar.delegate = self
        
        // set the store picker's delegate and data source
        productStore.delegate = self
        productStore.dataSource = self
        
        // add a gesture recognizer for detail image view for selecting image
        detailImage.isUserInteractionEnabled = true
        detailImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(detailImageTapped)))
        // set up delegate for the image picker
        imagePickerController.delegate = self
        
        // generate store
//                generateStore()
        
        // fetch store (the store info need to be fetched first, then looking for the item to edit)
        fetchAttempt()
        
        // if wishItem is not nil, we are at editing page, change nav bar title
        if wishItem == nil {
            detailNavItem.title = "Add"
        } else {
            detailNavItem.title = "Edit"
            
            // fill form with item to edit
            productName.text = wishItem.title
            productPrice.text = String(wishItem.price)
            productDetail.text = wishItem.details
            
            if let store = wishItem.toStore {
                if let indexInPicker = resultController.indexPath(forObject: store) {
                    productStore.selectRow(indexInPicker.row, inComponent: 0, animated: false)
                }
            }
            
            detailImage.image = wishItem.toImage?.image as? UIImage
            
        }
        
        
    }
    
    /**
     * execute only once for the test store
     */
    func generateStore() {
        let store0 = Store(context: mocContext)
        store0.name = "Amazon"
        let store1 = Store(context: mocContext)
        store1.name = "Apple Store"
        let store2 = Store(context: mocContext)
        store2.name = "Tmall"
        let store3 = Store(context: mocContext)
        store3.name = "Taobao"
        let store4 = Store(context: mocContext)
        store4.name = "Best Buy"
        let store5 = Store(context: mocContext)
        store5.name = "Ebay"
        // persist it to the storage
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func fetchAttempt() {
        // the fetch request
        let fetchRequest = NSFetchRequest<Store>(entityName: "Store")
        let sortDesc = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc]
        
        // the controller for generating and fetching data
        resultController = NSFetchedResultsController<Store>(
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
    
    @objc func detailImageTapped() {
        print("detailImageTapped")
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        /*
         whether a new item is added or a existing item updated, we only need to add/update the
         item itself, core data will update the ui for us automatically
         */
        if wishItem == nil { // add a new item
            let newItem = Item(context: mocContext)
            newItem.title = productName.text
            newItem.price = Double(productPrice.text!)!
            newItem.details = productDetail.text
            // select the store indicated by the store picker
            if let fetchedStores = resultController.fetchedObjects {
                newItem.toStore = fetchedStores[productStore.selectedRow(inComponent: 0)]
            }
            // create a new image item
            let newImage = Image(context: mocContext)
            newImage.image = detailImage.image
            // associate the new image with new item
            newItem.toImage = newImage
            
        } else {  // update the current item
            wishItem.title = productName.text
            wishItem.price = Double(productPrice.text!)!
            wishItem.details = productDetail.text
            // select the store indicated by the store picker
            if let fetchedStores = resultController.fetchedObjects {
                wishItem.toStore = fetchedStores[productStore.selectedRow(inComponent: 0)]
            }
            
            // create a new image item
            let newImage = Image(context: mocContext)
            newImage.image = detailImage.image
            // associate the new image with the edited item
            wishItem.toImage = newImage
        }
        
        // persist it to the item
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        // pop off detail page
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: the UINavigationBar delegate method for deciding the postion of the bar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    // MARK: UIPickerView's delegate and data source method
    @available(iOS 2.0, *)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @available(iOS 2.0, *)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let stores = resultController.fetchedObjects {
            return stores.count
        }
        return 0
    }
    @available(iOS 2.0, *)
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let stores = resultController.fetchedObjects {
            return stores[row].name
        }
        return nil
    }
    
    // MARK: image picker controller delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        detailImage.image = image
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
}
