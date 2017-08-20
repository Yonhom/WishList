//
//  WishItemCell.swift
//  WishList
//
//  Created by 徐永宏 on 2017/8/20.
//  Copyright © 2017年 徐永宏. All rights reserved.
//

import UIKit

class WishItemCell: UITableViewCell {
    
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    func updateCell(with item: Item) {
        itemTitle.text = item.title
        itemPrice.text = "$\(item.price)"
        itemDetail.text = item.details
    }

}
