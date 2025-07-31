//
//  SearchViewModel.swift
//  AdvanceApp
//
//  Created by 김이든 on 7/28/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel {
    // Input
    let searchQuery = BehaviorRelay<String>(value: "")
    let bookSelected = PublishRelay<Book>()
    
    // Output
    let books = BehaviorRelay<[Book]>(value: [])
    let selectedBook = PublishRelay<Book>()
    
    private let disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    
    init() {
        bind()
    }
    
    private func bind() {
        searchQuery
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] query -> Observable<[Book]> in
                guard let self = self else { return .just([]) }
                return self.networkManager.searchBooks(query: query)
                    .catchAndReturn([])
            }
            .bind(to: books)
            .disposed(by: disposeBag)
        bookSelected
            .bind(to: selectedBook)
            .disposed(by: disposeBag)
    }
}
