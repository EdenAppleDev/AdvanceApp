//
//  RecentBookCell.swift
//  AdvanceApp
//
//  Created by 김이든 on 8/1/25.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class RecentBookCell: UICollectionViewCell {
    static let id = "RecentBookCell"
    
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
        
        [imageView].forEach { contentView.addSubview($0) }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(with book: Book) {
        if let urlString = book.thumbnail, let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "book") // 대체 이미지
        }
    }
}
