//
//  ProductCollectionViewCell.swift
//  eCom
//
//  Created by Anas on 13/07/24.
//

import UIKit
import SDWebImage

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var addToCartBtn: UIButton!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var prodDes: UILabel!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    static let identifier = "ProductCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with image:String, price:Double, title:String, description: String){
        
        imageView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder.png"))
        prodDes.text = description
        prodName.text = title
        prodPrice.text = String(format: "%.2f",price) + "$"
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "ProductCollectionViewCell", bundle: nil)
    }

}
