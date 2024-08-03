//
//  ProductModel.swift
//  eCom
//
//  Created by Anas on 13/07/24.
//

import Foundation

struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating
}

struct Rating: Codable {
    let rate: Double
    let count: Int
}

struct Cart: Codable {
    var id: Int
    var title: String
    var price: Double
    var description: String
    var category: String
    var image: String
    var count:Int
}
