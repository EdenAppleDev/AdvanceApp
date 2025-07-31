//
//  NetworkManager.swift
//  AdvanceApp
//
//  Created by 김이든 on 7/29/25.
//

import Foundation
import os
import RxSwift

final class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://dapi.kakao.com/v3/search/book"
    
    private let apiKey = Bundle.main.apiKey ?? ""
    
    func searchBooks(query: String) -> Observable<[Book]> {
        guard var components = URLComponents(string: baseURL) else {
            return Observable.just([])
        }
        
        components.queryItems = [
            URLQueryItem(name: "query", value: query),    // 사용자 입력값
            URLQueryItem(name: "target", value: "title")
        ]
        
        guard let url = components.url else {
            return Observable.just([])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.rx.data(request: request)
            .map { data in
                try JSONDecoder().decode(BookResponse.self, from: data).documents
            }
            .catchAndReturn([])
    }
}

extension Bundle {
    
    var apiKey: String? {
        guard let file = self.path(forResource: "Secrets", ofType: "plist"),
              let resource = NSDictionary(contentsOfFile: file),
              let key = resource["API_KEY"] as? String else {
            os_log(.error, log: .default, "⛔️ API KEY를 가져오는데 실패하였습니다.")
            return nil
        }
        return key
    }
    
}
