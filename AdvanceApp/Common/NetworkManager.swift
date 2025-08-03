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
    static let shared = NetworkManager()  // 싱글톤 패턴
    
    private init() { }  // 외부에서 생성 못하게 막기
    
    private let bookURL = "https://dapi.kakao.com/v3/search/book"
    
    private let apiKey = Bundle.main.apiKey ?? ""  // Secrets.plist에서 apiKey 가져오기
    
    func searchBooks(query: String) -> Observable<[Book]> {  // RxSwift 방식으로 처리하기 위해 Observable로 반환
        guard var components = URLComponents(string: bookURL) else {  // URLComponents는 URL을 파라피터 단위로 다룰 수 있게 해줌
            return Observable.just([]) // 유효한 URL이 아니면 빈배열을 감싼 Observable을 반환
        }
        
        components.queryItems = [
            URLQueryItem(name: "query", value: query),  // 사용자 입력값
            URLQueryItem(name: "target", value: "title")
        ]
        
        guard let url = components.url else {
            return Observable.just([])
        }
        
        var request = URLRequest(url: url)  // URLRequest 객체 생성
        request.httpMethod = "GET"  // 서버에 데이터를 요청할 때 사용하는 GET
        request.addValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")  // HTTP 요청에 헤더 값을 추가함 (Kakao API에서 요구하는 방식으로 인증
        
        return URLSession.shared.rx.data(request: request) // request 보내기
            .map { data in  // 데이터 받기
                try JSONDecoder().decode(BookResponse.self, from: data).documents  // [Book]배열로 반환
            }
            .catchAndReturn([])  // 실패하면 빈 배열 반환
    }
}

// MARK: - API_KEY 가져오기
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
