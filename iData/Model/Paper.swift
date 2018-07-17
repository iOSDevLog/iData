//
//  Paper.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let paper = try? JSONDecoder().decode(Paper.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responsePaper { response in
//     if let paper = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

public struct Paper: Codable {
    public let data: PaperDataClass?
    public let status: Int?
    
    public init(data: PaperDataClass?, status: Int?) {
        self.data = data
        self.status = status
    }
}

public struct PaperDataClass: Codable {
    public let items: [Item]?
    public let start: String?
    public let totalCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case items, start
        case totalCount = "total_count"
    }
    
    public init(items: [Item]?, start: String?, totalCount: Int?) {
        self.items = items
        self.start = start
        self.totalCount = totalCount
    }
}

public struct Item: Codable {
    public let abstract, author, database, dbcode: String?
    public let downURL, filename, filenameEn, mirrorURL: String?
    public let orgniz, publishTime, source, tablename: String?
    public let title, url, viewonlineURL: String?
    
    enum CodingKeys: String, CodingKey {
        case abstract, author, database, dbcode
        case downURL = "down_url"
        case filename
        case filenameEn = "filename_en"
        case mirrorURL = "mirror_url"
        case orgniz
        case publishTime = "publish_time"
        case source, tablename, title, url
        case viewonlineURL = "viewonline_url"
    }
    
    public init(abstract: String?, author: String?, database: String?, dbcode: String?, downURL: String?, filename: String?, filenameEn: String?, mirrorURL: String?, orgniz: String?, publishTime: String?, source: String?, tablename: String?, title: String?, url: String?, viewonlineURL: String?) {
        self.abstract = abstract
        self.author = author
        self.database = database
        self.dbcode = dbcode
        self.downURL = downURL
        self.filename = filename
        self.filenameEn = filenameEn
        self.mirrorURL = mirrorURL
        self.orgniz = orgniz
        self.publishTime = publishTime
        self.source = source
        self.tablename = tablename
        self.title = title
        self.url = url
        self.viewonlineURL = viewonlineURL
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
    public func responsePaper(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<Paper>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
