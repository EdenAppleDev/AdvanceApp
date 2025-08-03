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
    let sections = BehaviorRelay<[BookSection]>(value: [])
    let selectedBook = PublishRelay<Book>()
    
    private let disposeBag = DisposeBag()
    private let networkManager = NetworkManager.shared
    
    private var recentBooks: [Book] = []
    
    init() {
        bind()
    }
    
    private func bind() {
        // 검색어 처리
        searchQuery
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // 0.3초 간격으로 입력 안정화
            .flatMapLatest { [weak self] query -> Observable<[Book]> in  // 최신 검색어만 처리
                guard let self else { return .just([]) }
                return self.networkManager.searchBooks(query: query)
                    .catchAndReturn([])  // 실패 시 빈 배열 반환
            }
            .subscribe(onNext: { [weak self] searchResult in
                guard let self else { return }

                var sectionList: [BookSection] = []  // 최종 섹션 목록

                // 최근 본 책 섹션 추가
                if !self.recentBooks.isEmpty {
                    sectionList.append(.recent(title: "최근 본 책", items: self.recentBooks))
                }

                // 검색 결과 섹션 추가
                sectionList.append(.search(title: "검색 결과", items: searchResult))

                // 섹션 상태 업데이트 → CollectionView 갱신 트리거
                self.sections.accept(sectionList)
            })
            .disposed(by: disposeBag)

        // 책 선택 처리
        bookSelected
            .do(onNext: { [weak self] book in
                guard let self else { return }

                // 같은 책이 이미 있으면 제거
                self.recentBooks.removeAll { $0.title == book.title }

                // 가장 앞에 삽입 (가장 최근)
                self.recentBooks.insert(book, at: 0)

                // 최대 10개까지만 유지
                self.recentBooks = Array(self.recentBooks.prefix(10))
            })
            .bind(to: selectedBook)  // 선택된 책을 selectedBook으로 바인딩
            .disposed(by: disposeBag)
    }
}
