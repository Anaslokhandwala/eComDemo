//
//  CartViewController.swift
//  eCom
//
//  Created by Anas on 13/07/24.
//

import UIKit

class CartViewController: UIViewController {

    @IBOutlet weak var cartItemTV: UITableView!
    @IBOutlet weak var totalCartVal: UILabel!
    
    let dbHelper = DBHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"

        cartItemTV.register(CartTableViewCell.nib(), forCellReuseIdentifier: CartTableViewCell.identifier)
        var subTotal = 0.0
        for item in cart {
            let prodVal = item.price * Double(item.count)
            subTotal = subTotal + prodVal
        }
        
        totalCartVal.text = "Subtotal: " + String(format: "%.2f", subTotal) + "$"

    }
    
    @objc func buttonAddToCartClicked(sender: UIButton) {
        let rowIndex = sender.tag
        cart[rowIndex].count += 1
        
        dbHelper.update(cartItem: cart[rowIndex])
        
        DispatchQueue.main.async {
            var subTotal = 0.0
            for item in cart {
                let prodVal = item.price * Double(item.count)
                subTotal = subTotal + prodVal
            }
            
            self.totalCartVal.text = "Subtotal: " + String(format: "%.2f", subTotal) + "$"
            self.cartItemTV.reloadData()
        }
    }

    @objc func buttonRemovedFromCartClicked(sender: UIButton) {
        let rowIndex = sender.tag
        
        if cart[rowIndex].count > 1 {
            cart[rowIndex].count -= 1
            dbHelper.update(cartItem: cart[rowIndex])
        }else if cart[rowIndex].count == 1{
            dbHelper.delete(id: cart[rowIndex].id)
            cart.remove(at: rowIndex)
        }
        
        DispatchQueue.main.async {
            var subTotal = 0.0
            for item in cart {
                let prodVal = item.price * Double(item.count)
                subTotal = subTotal + prodVal
            }
            
            self.totalCartVal.text = "Subtotal: " + String(format: "%.2f", subTotal) + "$"
            self.cartItemTV.reloadData()
        }
    }


}

extension CartViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
}

extension CartViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cartItemTV.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as! CartTableViewCell
       
        let product = cart[indexPath.item]
        
        cell.configure(with: product.image, price: product.price, title: product.title, cartCount: product.count)

        cell.addBtn.tag = indexPath.row
        cell.addBtn.addTarget(self, action: #selector(buttonAddToCartClicked(sender:)), for: .touchUpInside)
        cell.removeBtn.tag = indexPath.row
        cell.removeBtn.addTarget(self, action: #selector(buttonRemovedFromCartClicked(sender:)), for: .touchUpInside)

        cell.selectionStyle = .none
        
        return cell
    }
    
    
}
