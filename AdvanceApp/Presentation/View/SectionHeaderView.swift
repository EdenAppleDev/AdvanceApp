//
//  SectionHeaderView.swift
//  AdvanceApp
//
//  Created by 김이든 on 7/28/25.
//

import UIKit
import SnapKit
import Then

final class SectionHeaderView: UICollectionReusableView {
    static let id = "SectionHeaderView"
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [titleLabel].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview().inset(10)
            $0.directionalVerticalEdges.equalToSuperview().inset(5)
        }
    }
    
    func configure(_ title: String) {
        titleLabel.text = title
    }
}
