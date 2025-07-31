//
//  DetailViewController.swift
//  AdvanceApp
//
//  Created by 김이든 on 7/28/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Then
import Kingfisher

class DetailViewController: UIViewController {
    
    var viewModel: DetailViewModel!
    
    private let disposeBag = DisposeBag()
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    private let authorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 1
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .darkGray
        $0.layer.cornerRadius = 12
    }
    
    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .heavy)
        $0.numberOfLines = 1
    }
    
    private let contentsLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
    }
    
    private let closeButton = UIButton().then {
        $0.setTitle("X", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 12
    }
    
    private let addButton = UIButton().then {
        $0.setTitle("담기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 12
    }
    
    private lazy var buttonStack = UIStackView(arrangedSubviews: [closeButton, addButton]).then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.distribution = .fillProportionally
    }
    
    private lazy var contentStack = UIStackView(arrangedSubviews: [
        titleLabel, authorLabel, imageView, priceLabel, contentsLabel
    ]).then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .center
    }
    
    private let scrollView = UIScrollView()
    private let scrollContentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(contentStack)
        view.addSubview(buttonStack)

        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonStack.snp.top).offset(-16)
        }
        
        scrollContentView.snp.makeConstraints {
            $0.edges.width.equalTo(scrollView)
        }
        
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.height.equalTo(imageView.snp.width).multipliedBy(1.6)
        }

        buttonStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(44)
        }
    }
    
    private func bind() {
        let book = viewModel.book
        
        if let urlString = book.thumbnail, let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "book")
        }
        
        if let title = book.title,
           let authors = book.authors,
           let price = book.price,
           let contents = book.contents{

            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal

            let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "\(price)"

            titleLabel.text = title
            authorLabel.text = authors.joined(separator: ", ")
            priceLabel.text = "\(formattedPrice)원"
            contentsLabel.text = contents
        }
    }
    
    private func setupActions() {
        closeButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
