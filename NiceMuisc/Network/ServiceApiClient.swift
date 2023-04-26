//
//  ServiceApiClient.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//


import Moya
import RxCocoa
import RxSwift


struct ServiceApiClient {
    
    
    private static let apiProvider = MoyaProvider<ServiceApiProvider>(plugins: [CustomPlugIn()])
//    private static let apiProvider = MoyaProvider<ServiceApiProvider>(plugins:
//                                                                        [NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter), logOptions: .verbose))])
    
    private static func JSONResponseDataFormatter(_ data: Data) -> String {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
        } catch {
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
      
    static func request<T: Decodable>(_ api: ServiceApiProvider, visibleIndicator: Bool = true) -> Single<T> {
      
        Log.d("network requests \(api.apiMethod)")
        let request = Single<T>.create { observer in
            let observable = ServiceApiClient.apiProvider.rx.request(api).subscribe { event in
                switch event {
                case .success(let response):
                    do {
                        Log.d("network requests - success")
                        let data = try JSONDecoder().decode(T.self, from: response.data)
                        observer(.success(data))
                    } catch {
                        Log.e("network error api : \(api), \ndesc :\(error.localizedDescription), error \(error)")
                        let e = ServiceApiProvider.Error.serverMaintenance(message: error.localizedDescription + "\ncode: ")
                        observer(.failure(e))
                    }
                case .failure(let error):
                    Log.e("network error :\(error.localizedDescription)")
                    observer(.failure(ServiceApiProvider.Error.failureResponse(api: api, code: .http_999_99999, desc: "")))
                    print(error.localizedDescription)
                }
            }

            return Disposables.create {
                observable.dispose()
            }
        }.observe(on: MainScheduler.instance)
        
        return request
    }
}

class CustomPlugIn : PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
//        Log.d("URL Request - \(target) : \(request.url?.absoluteString ?? "없음")")
        return request
    }

    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
//        Log.d("URL Response - \(target) : \(result)")
        return result
    }
}



// branchMain
// branchMain2
// branchMain3
// branchSub
