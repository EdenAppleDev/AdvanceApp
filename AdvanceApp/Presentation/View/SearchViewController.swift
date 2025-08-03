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
import RxDataSources

final class SearchViewController: UIViewController {
    
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    
    private let searchBar = UISearchBar().then {
        $0.placeholder = "검색"
        $0.searchBarStyle = .minimal
        $0.barStyle = .default
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(BookCell.self, forCellWithReuseIdentifier: BookCell.id) // 검색 결과 cell
        $0.register(RecentBookCell.self, forCellWithReuseIdentifier: RecentBookCell.id) // 최근 본 책 cell
        $0.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id)
    }
    
    // MARK: - RxDataSource
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<BookSection>(
        // 각 셀의 UI를 구성하는 클로저
        configureCell: { ds, cv, indexPath, item in
            let section = ds.sectionModels[indexPath.section]  // 현재 섹션 정보 가져오기
            
            switch section {
            case .recent:
                // 최근 본 책 섹션일 경우 RecentBookCell 사용
                guard let cell = cv.dequeueReusableCell(
                    withReuseIdentifier: RecentBookCell.id,
                    for: indexPath
                ) as? RecentBookCell else {
                    return UICollectionViewCell()  // 캐스팅 실패 시 빈 셀 반환
                }

                cell.configure(with: item)  // 셀에 데이터 바인딩
                return cell

            case .search:
                // 검색 결과 섹션일 경우 BookCell 사용
                guard let cell = cv.dequeueReusableCell(
                    withReuseIdentifier: BookCell.id,
                    for: indexPath
                ) as? BookCell else {
                    return UICollectionViewCell()
                }

                cell.configure(with: item)  // 셀에 데이터 바인딩
                return cell
            }
        },

        // 각 섹션의 Supplementary View(Header 등)를 구성하는 클로저
        configureSupplementaryView: { ds, cv, kind, indexPath in
            // 헤더 뷰 재사용 큐에서 꺼내오기
            guard let header = cv.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.id,
                for: indexPath
            ) as? SectionHeaderView else {
                return UICollectionReusableView()  // 캐스팅 실패 시 빈 뷰 반환
            }

            let section = ds.sectionModels[indexPath.section]  // 현재 섹션 정보 가져오기

            // recent와 search 섹션 모두 title이 존재하므로 공통 처리
            switch section {
            case .recent(let title, _), .search(let title, _):
                header.configure(title)  // 섹션 타이틀 바인딩
            }

            return header
        }
    )
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        bindKeyboardDismissGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchBar.becomeFirstResponder() // 서치바 입력상태로
    }
    
    // MARK: - Rx bind
    private func bind() {
        // 검색 버튼 클릭 시 키보드 내리고 검색어를 searchQuery에 바인딩
        searchBar.rx.searchButtonClicked
            .do(onNext: { [weak self] in self?.view.endEditing(true) })  // 키보드 내리기
            .withLatestFrom(searchBar.rx.text.orEmpty)  // 클릭 시 현재 텍스트를 가져옴
            .filter { !$0.isEmpty }  // 빈 문자열은 무시
            .bind(to: viewModel.searchQuery)  // ViewModel의 검색 쿼리에 전달
            .disposed(by: disposeBag)

        // 사용자가 검색창 내용을 모두 지우면 검색 쿼리를 빈 문자열로 설정하여 초기 상태로 전환
        searchBar.rx.text.orEmpty
            .filter { $0.isEmpty }  // 텍스트가 비었을 때만 반응
            .map { _ in "" }  // 빈 문자열 전달
            .bind(to: viewModel.searchQuery)  // ViewModel의 검색 쿼리로 전달
            .disposed(by: disposeBag)

        // ViewModel의 sections를 CollectionView에 바인딩하여 섹션별 셀을 구성
        viewModel.sections
            .bind(to: collectionView.rx.items(dataSource: dataSource))  // RxDataSources와 바인딩
            .disposed(by: disposeBag)

        // 셀 선택 시 해당 Book 모델을 ViewModel에 전달
        collectionView.rx.modelSelected(Book.self)
            .bind(to: viewModel.bookSelected)
            .disposed(by: disposeBag)

        // ViewModel에서 선택된 책이 발생하면 상세 화면으로 이동
        viewModel.selectedBook
            .subscribe(onNext: { [weak self] book in
                let detailVC = DetailViewController()  // 상세 화면 인스턴스 생성
                detailVC.viewModel = DetailViewModel(book: book)  // ViewModel 주입
                detailVC.modalPresentationStyle = .pageSheet  // 모달 방식 설정
                self?.present(detailVC, animated: true)  // 화면 표시
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - CollectionViewCompositionalLayout 설정
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            let sections = self.viewModel.sections.value
            guard sectionIndex < sections.count else { return nil }

            let sectionType = sections[sectionIndex]
            switch sectionType {
            case .recent:
                return self.makeSection(
                    groupWidth: 0.25,
                    groupHeight: 0.4,
                    isHorizontal: true,
                    scrolling: .continuous
                )

            case .search:
                return self.makeSection(
                    groupWidth: 1.0,
                    groupHeight: 0.3,
                    isHorizontal: false,
                    scrolling: .none
                )
            }
        }
    }
    
    // MARK: - CollectionViewCompositionalLayout 중복 코드 줄이기
    private func makeSection(
        groupWidth: CGFloat,
        groupHeight: CGFloat,
        isHorizontal: Bool,
        scrolling: UICollectionLayoutSectionOrthogonalScrollingBehavior
    ) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(groupWidth),
            heightDimension: .fractionalWidth(groupHeight)
        )
        let group: NSCollectionLayoutGroup = isHorizontal
            ? .horizontal(layoutSize: groupSize, subitems: [item])
            : .vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = scrolling
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }

    private func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(44)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
    
    
    // MARK: - UI Setup
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
    
    // MARK: - 키보드 대응
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
