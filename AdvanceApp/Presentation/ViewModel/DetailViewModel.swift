//
//  DetailViewModel.swift
//  AdvanceApp
//
//  Created by 김이든 on 7/31/25.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailViewModel {
    let book: Book

    init(book: Book) {
        self.book = book
    }
}
