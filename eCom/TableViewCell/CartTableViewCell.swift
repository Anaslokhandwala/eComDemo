//
//  CartTableViewCell.swift
//  eCom
//
//  Created by Anas on 13/07/24.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet var imageViewN: UIImageView!
    
    @IBOutlet weak var itemCountLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    static let identifier = "CartTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with image:String, price:Double, title:String, cartCount:Int){
        
        imageViewN.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder.png"))
        itemCountLbl.text = String(cartCount)
        prodName.text = title
        prodPrice.text = String(format: "%.2f",price * Double(cartCount)) + "$"
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "CartTableViewCell", bundle: nil)
    }
    
}
