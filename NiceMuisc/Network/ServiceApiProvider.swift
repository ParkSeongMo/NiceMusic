//
//  ServiceApiProvider.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Moya
import SwiftyJSON

enum ServiceApiProvider {
    case topArtistList(page: Int, limit: Int)                           // Top 아티스트 조회
    case topTrackList(page: Int, limit: Int)                            // Top 음원 조회
    case topArtistListInLocal(page: Int, limit: Int, country: String)   // 국내 Top 아티스트 조회
    case topTrackListInLocal(page: Int, limit: Int, country: String)    // 국내 Top 음원 조회
    case artistSearch(artist: String, page: Int, limit: Int)            // 아티스트 검색
    case trackSearch(track: String, page: Int, limit: Int)              // 음원 검색
    case albumSearch(album: String, page: Int, limit: Int)              // 엘범 검색
    case artistDetail(artist: String)                       // 아티스트 상세 조회
    case trackDetail(artist: String, track: String)         // 음원 상세 조회
    case albumDetail(artist: String, album: String)         // 엘범 상세 조회
}

extension ServiceApiProvider: TargetType {
    var baseURL: URL {
        return URL(string: "http://ws.audioscrobbler.com/2.0/")!
    }
    
    var apiMethod: String {
        switch self {
        case .topArtistList:
            return "chart.gettopartists"
        case .topTrackList:
            return "chart.gettoptracks"
        case .topArtistListInLocal:
            return "geo.gettopartists"
        case .topTrackListInLocal:
            return "geo.gettoptracks"
        case .artistSearch:
            return "artist.search"
        case .trackSearch:
            return "track.search"
        case .albumSearch:
            return "album.search"
        case .artistDetail:
            return "artist.getinfo"
        case .trackDetail:
            return "track.getInfo"
        case .albumDetail:
            return "album.getinfo"
        }
    }
    
    var path: String {
        switch self {
        case .topArtistList,
            .topTrackList,
            .topArtistListInLocal,
            .topTrackListInLocal,
            .artistSearch,
            .trackSearch,
            .albumSearch,
            .artistDetail,
            .trackDetail,
            .albumDetail:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .topArtistList,
            .topTrackList,
            .topArtistListInLocal,
            .topTrackListInLocal,
            .artistSearch,
            .trackSearch,
            .albumSearch,
            .artistDetail,
            .trackDetail,
            .albumDetail:
            return .get
        }
    }
    
    var task: Moya.Task {
        let param: [String: Any] = objectMapper(self)
        return .requestParameters(parameters: param, encoding: parameterEncodingForMethod())
    }
    
    var headers: [String : String]? {
        return nil
    }
        
    func parameterEncodingForMethod() -> ParameterEncoding {
        return self.method == .get ? URLEncoding.default : JSONEncoding.default
    }

    func objectMapper(_ provider: ServiceApiProvider) -> [String: Any] {
        var param: [String: Any] = [:]
        let mirror = Mirror(reflecting: provider)

        for case let (_, api) in mirror.children {
            let task = Mirror(reflecting: api)
            for case let (key?, value) in task.children {
                if let v = value as? String {
                    param.updateValue(v, forKey: key)
                } else if let v = value as? Int {
                    param.updateValue(v, forKey: key)
                } else if let v = value as? Bool {
                    param.updateValue(v, forKey: key)
                }
            }
        }               
            
        param.updateValue("628f6f4f8322b9ce87afb68784ab4dae", forKey: "api_key")
        param.updateValue("json", forKey: "format")
        param.updateValue(apiMethod, forKey: "method")
//        Log.d("objectMapper param = \(param)")
        return param
    }
}

extension ServiceApiProvider {
    enum Error: Swift.Error {
        case serverMaintenance(message: String)
        // 비정상 응답 (오류코드)
        case failureResponse(api: ServiceApiProvider, code: ServiceApiProvider.StateCode, desc: String?)
        // 잘못된 응답 데이터 (발생시 서버 문의)
        case invalidResponseData(api: ServiceApiProvider)
    }
    enum StateCode: String {
        case http_000_00000 = "00000000" // 정의되지 않은 오류
        case http_999_99999 = "99999999" // 네트워크 관련 에러
    }
}
