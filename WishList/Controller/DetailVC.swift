//
//  DetailVC.swift
//  WishList
//
//  Created by 徐永宏 on 2017/8/20.
//  Copyright © 2017年 徐永宏. All rights reserved.
//

import UIKit

class DetailVC: UIViewController, UINavigationBarDelegate {
    
    @IBOutlet weak var detailNavBar: UINavigationBar!
    
    /**
     * for dynamically changing the title of the bar
     */
    @IBOutlet weak var detailNavItem: UINavigationItem!
    /**
     * for adding a gesture recognizer to change image
     */
    @IBOutlet weak var detailImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
        
    }
    
    func initialize() {
        // set a delegate for navi bar, to extend navibar to the screen top
        detailNavBar.delegate = self
        
        // add a gesture recognizer for detail image view for selecting image
        detailImage.isUserInteractionEnabled = true
        detailImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(detailImageTapped)))
    }
    
    @objc func detailImageTapped() {
        print("detailImageTapped")
    }

    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: the UINavigationBar delegate method for deciding the postion of the bar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}
