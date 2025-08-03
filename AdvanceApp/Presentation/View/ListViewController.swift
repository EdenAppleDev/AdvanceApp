//
//  ListViewController.swift
//  AdvanceApp
//
//  Created by 김이든 on 7/28/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class ListViewController: UIViewController {
    
    private let viewModel = BookListViewModel.shared
    private let disposeBag = DisposeBag()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(BookCell.self, forCellWithReuseIdentifier: BookCell.id)
        $0.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
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
        
        title = "담은 책"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "추가",
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "전체 삭제",
            style: .plain,
            target: self,
            action: #selector(allDeleteTapped)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .systemRed
        
        [
            collectionView
        ].forEach {
            view.addSubview($0)
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        viewModel.books
            .bind(to: collectionView.rx.items(
                cellIdentifier: BookCell.id,
                cellType: BookCell.self
            )) { index, book, cell in
                cell.configure(with: book)
            }
            .disposed(by: disposeBag)
    }
    
    @objc private func addTapped() {
        self.tabBarController?.selectedIndex = 0
    }
    
    @objc private func allDeleteTapped() {
        BookListViewModel.shared.removeAll()
    }
}
