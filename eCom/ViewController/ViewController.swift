import UIKit
import SVProgressHUD

var cart = [Cart]()

class ViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var collectionPrView: UICollectionView!
    
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var cartValue: UILabel!
    
    var products = [Product]()
    var filteredProducts = [Product]()
    var searchController: UISearchController!
    let dbHelper = DBHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        circularView.layer.cornerRadius = 45
        circularView.clipsToBounds = true
        
        SVProgressHUD.show()
        
        title = "eCom"
        
        cart = dbHelper.read()
        
        // CollectionView
        collectionPrView.delegate = self
        collectionPrView.dataSource = self

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionPrView.collectionViewLayout = layout
        
        collectionPrView.register(ProductCollectionViewCell.nib(), forCellWithReuseIdentifier: ProductCollectionViewCell.identifier)
        
        // Search Controller
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        topView.addSubview(searchController.searchBar)


        // API Call
        fetchProducts { [weak self] (products, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                print("Error fetching products: \(error)")
                return
            }
            
            if let products = products {
                self?.products = products
                self?.filteredProducts = products
                DispatchQueue.main.async {
                    self?.collectionPrView.reloadData()
                }
                print("Fetched \(products.count) products:")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            var count = 0
            for cou in cart {
                count = count + cou.count
            }
            
            self.cartValue.text = String(count)
        }
    }

    func fetchProducts(completion: @escaping ([Product]?, Error?) -> Void) {
        guard let url = URL(string: "https://fakestoreapi.com/products") else {
            completion(nil, URLError(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "NoData", code: 0, userInfo: nil))
                return
            }
            
            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                completion(products, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    @objc func buttonAddToCartClicked(sender: UIButton) {
        guard let cell = sender.superview?.superview as? ProductCollectionViewCell,
              let indexPath = collectionPrView.indexPath(for: cell) else {
            return
        }

        let product = filteredProducts[indexPath.row]

        if let index = cart.firstIndex(where: { $0.id == product.id }) {

            cart[index].count += 1
                        
            dbHelper.update(cartItem: cart[index])
            
        } else {

            let cartP = Cart(id: product.id,
                             title: product.title,
                             price: product.price,
                             description: product.description,
                             category: product.category,
                             image: product.image,
                             count: 1)
            
            dbHelper.insert(cartItem: cartP)
            cart.append(cartP)
        }

    
        DispatchQueue.main.async {
            var count = 0
            for cou in cart {
                count = count + cou.count
            }
            
            self.cartValue.text = String(count)
        }
    }

    
    @IBAction func gotoCartBtn(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc : CartViewController = self.storyboard?.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func fabButtonTapped() {
        print("FAB tapped!")
    }
    
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell Selected")
    }
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.identifier, for: indexPath) as! ProductCollectionViewCell
       
        let product = filteredProducts[indexPath.item]
        
        cell.configure(with: product.image, price: product.price, title: product.title, description: product.description)
        cell.addToCartBtn.addTarget(self, action: #selector(buttonAddToCartClicked(sender:)), for: .touchUpInside)

        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 2
        let paddingSpace: CGFloat = 0
        let totalPadding = paddingSpace * (itemsPerRow - 1)
        let availableWidth = collectionView.frame.width - totalPadding
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: 325)
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredProducts = products
            collectionPrView.reloadData()
            return
        }
        
        filteredProducts = products.filter { product in
            return product.title.lowercased().contains(searchText.lowercased()) ||
                   product.description.lowercased().contains(searchText.lowercased())
        }
        
        collectionPrView.reloadData()
    }
}
