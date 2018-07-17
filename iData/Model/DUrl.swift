//
//  DUrl.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let dURL = try? JSONDecoder().decode(DURL.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseDURL { response in
//     if let dURL = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

public struct DURL: Codable {
    public let data: DURLDataClass?
    public let status: Int?
    
    public init(data: DURLDataClass?, status: Int?) {
        self.data = data
        self.status = status
    }
}

public struct DURLDataClass: Codable {
    public let durl: String?
    public let isPDF: Bool?
    public let previewURL, url: String?
    
    enum CodingKeys: String, CodingKey {
        case durl
        case isPDF = "is_pdf"
        case previewURL = "preview_url"
        case url
    }
    
    public init(durl: String?, isPDF: Bool?, previewURL: String?, url: String?) {
        self.durl = durl
        self.isPDF = isPDF
        self.previewURL = previewURL
        self.url = url
    }
}

// MARK: - Alamofire response handlers

public extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try JSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    public func responseDURL(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<DURL>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}

