//
//  SectionModel.swift
//  AdvanceApp
//
//  Created by 김이든 on 8/1/25.
//

import Foundation
import RxDataSources

enum BookSection {
    case recent(title: String, items: [Book])
    case search(title: String, items: [Book])
}

extension BookSection: SectionModelType {
    typealias Item = Book // BookSection에 포함될 셀 데이터의 타입이 Book임을 명시

    var items: [Book] {
        switch self {
        case .recent(_, let items): return items
        case .search(_, let items): return items
        }
    }

    init(original: BookSection, items: [Book]) {
        switch original {
        case .recent(let title, _): self = .recent(title: title, items: items)
        case .search(let title, _): self = .search(title: title, items: items)
        }
    }
}
