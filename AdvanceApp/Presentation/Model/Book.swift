//
//  Book.swift
//  AdvanceApp
//
//  Created by 김이든 on 7/28/25.
//

import Foundation

// MARK: - Book
struct BookResponse: Codable {
    let meta: Meta
    let documents: [Book]
}

// MARK: - Document
struct Book: Codable {
    let authors: [String]?
    let contents: String?
    let price: Int?
    let salePrice: Int?
    let thumbnail: String?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case authors, contents, price
        case salePrice = "sale_price"
        case thumbnail, title
    }
}

// MARK: - Meta
struct Meta: Codable {
    let isEnd: Bool
    let pageableCount, totalCount: Int

    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
    }
}
