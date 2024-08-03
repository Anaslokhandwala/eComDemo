import Foundation
import SQLite3

class DBHelper {
    var db: OpaquePointer?
    
    init() {
        self.db = createDB()
        createTable()
    }
    
    func createDB() -> OpaquePointer? {
        do {

            let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("cartDB.sqlite")
            
            var db: OpaquePointer? = nil
            
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("Error: Unable to open database")
                return nil
            } else {
                print("Pass: Database opened successfully")
                return db
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func createTable() {
        let query = """
        CREATE TABLE IF NOT EXISTS cart(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            price DOUBLE,
            description TEXT,
            category TEXT,
            image TEXT,
            count INTEGER
        );
        """
        
        var createTable: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &createTable, nil) == SQLITE_OK {
            if sqlite3_step(createTable) == SQLITE_DONE {
                print("Table creation Success")
            } else {
                print("Table Creation failed")
            }
        } else {
            print("Preparation Failed")
        }
        
        sqlite3_finalize(createTable)
    }
    
    func insert(cartItem: Cart) {
        let query = "INSERT INTO cart (id, title, price, description, category, image, count) VALUES (?, ?, ?, ?, ?, ?, ?)"
        
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(cartItem.id))
            sqlite3_bind_text(statement, 2, (cartItem.title as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 3, cartItem.price)
            sqlite3_bind_text(statement, 4, (cartItem.description as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (cartItem.category as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 6, (cartItem.image as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 7, Int32(cartItem.count))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Data Inserted")
            } else {
                print("Data not Inserted")
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Query Insert Failed")
        }
    }

    func read() -> [Cart] {
        var cartItems = [Cart]()
        
        let query = "SELECT * FROM cart"
        
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let price = sqlite3_column_double(statement, 2)
                let description = String(cString: sqlite3_column_text(statement, 3))
                let category = String(cString: sqlite3_column_text(statement, 4))
                let image = String(cString: sqlite3_column_text(statement, 5))
                let count = Int(sqlite3_column_int(statement, 6))
                
                let cartItem = Cart(id: id, title: title, price: price, description: description, category: category, image: image, count: count)
                cartItems.append(cartItem)
            }
            sqlite3_finalize(statement)
        } else {
            print("Query Read Failed")
        }
        
        return cartItems
    }
    
    func update(cartItem: Cart) {
        let query = """
        UPDATE cart
        SET title = ?, price = ?, description = ?, category = ?, image = ?, count = ?
        WHERE id = ?
        """
        
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (cartItem.title as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 2, cartItem.price)
            sqlite3_bind_text(statement, 3, (cartItem.description as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (cartItem.category as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (cartItem.image as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 6, Int32(cartItem.count))
            sqlite3_bind_int(statement, 7, Int32(cartItem.id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Data Updated")
            } else {
                print("Data Not Updated")
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Query Update Failed")
        }
    }
    
    func delete(id: Int) {
        let query = "DELETE FROM cart WHERE id = ?"
        
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Data Deleted")
            } else {
                print("Data Not Deleted")
            }
            
            sqlite3_finalize(statement)
        } else {
            print("Query Delete Failed")
        }
    }
}
