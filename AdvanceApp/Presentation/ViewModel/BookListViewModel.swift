//
//  BookListViewModel.swift
//  AdvanceApp
//
//  Created by 김이든 on 8/4/25.
//
import Foundation
import RxSwift
import RxCocoa

final class BookListViewModel {
    static let shared = BookListViewModel()
    
    let books = BehaviorRelay<[Book]>(value: [])
    
    private init() {}
    
    func add(_ book: Book) {
        var current = books.value
        current.insert(book, at: 0)
        books.accept(current)
    }
    
    func removeAll() {
        books.accept([])
    }
}
