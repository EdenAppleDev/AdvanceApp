//
//  SearchViewController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/25/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    
    private let searchBar = UISearchBar().then {
        $0.placeholder = "검색"
        $0.searchBarStyle = .minimal
        $0.barStyle = .default
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(BookCell.self, forCellWithReuseIdentifier: BookCell.id)
        $0.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        bindKeyboardDismissGesture()
    }
    
    private func bind() {
        // 검색 버튼 클릭 시 → 텍스트를 searchQuery에 전달
        searchBar.rx.searchButtonClicked
            .do(onNext: { [weak self] in self?.view.endEditing(true) })
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)

        // 빈 문자열일 경우 → 빈 배열 전달해서 리스트 초기화
        searchBar.rx.text.orEmpty
            .filter { $0.isEmpty }
            .map { _ in [] }
            .bind(to: viewModel.books)
            .disposed(by: disposeBag)
        
        // ViewModel이 전달한 books를 CollectionView에 바인딩
        viewModel.books
            .bind(to: collectionView.rx.items(
                cellIdentifier: BookCell.id,
                cellType: BookCell.self)
            ) { row, book, cell in
                cell.configure(with: book)
            }
            .disposed(by: disposeBag)
        
        // 셀 클릭 시 ViewModel에 전달
        collectionView.rx.modelSelected(Book.self)
            .bind(to: viewModel.bookSelected)
            .disposed(by: disposeBag)

        // ViewModel → 선택된 책 구독 → 모달 전환
        viewModel.selectedBook
            .subscribe(onNext: { [weak self] book in
                let detailVC = DetailViewController()
                detailVC.viewModel = DetailViewModel(book: book)
                detailVC.modalPresentationStyle = .pageSheet
                self?.present(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(0.3)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(44)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        [
            searchBar,
            collectionView
        ].forEach {
            view.addSubview($0)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // 키보드 대응
    private func bindKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .bind { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
}
