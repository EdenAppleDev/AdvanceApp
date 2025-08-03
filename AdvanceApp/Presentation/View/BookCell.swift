//
//  BookCell.swift
//  AdvanceApp
//
//  Created by 김이든 on 7/28/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class BookCell: UICollectionViewCell {
    static let id = "BookCell"
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 2
    }
    
    private let authorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .light)
        $0.numberOfLines = 1
    }
    
    private let priceContainerView = UIView()
    
    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .heavy)
        $0.numberOfLines = 1
    }
    
    private lazy var vStack = UIStackView(arrangedSubviews:  [titleLabel, authorLabel, priceContainerView]).then {
        $0.axis = .vertical
        $0.spacing = 4
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        $0.layer.cornerRadius = 12
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray3.cgColor
        
        [imageView, vStack].forEach { contentView.addSubview($0) }
        
        priceContainerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(imageView.snp.height).multipliedBy(0.6)
        }
        
        vStack.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(12)
            $0.directionalVerticalEdges.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview().inset(12)
        }
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        authorLabel.setContentHuggingPriority(.required, for: .vertical)
        priceContainerView.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    func configure(with book: Book) {
        if let urlString = book.thumbnail, let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "book") // 대체 이미지
        }
        
        if let title = book.title,
           let authors = book.authors,
           let price = book.price {
            // 가격 숫자 3개씩 ,
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedPrice = formatter.string(from: NSNumber(value: price)) ?? "\(price)"

            titleLabel.text = title
            authorLabel.text = authors.joined(separator: ", ")
            priceLabel.text = "\(formattedPrice)원"
        }
    }
}
