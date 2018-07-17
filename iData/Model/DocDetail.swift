//
//  DocDetail.swift
//  iData
//
//  Created by ios dev on 2018/7/17.
//  Copyright © 2018年 iOSDevLog. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let docDetail = try? JSONDecoder().decode(DocDetail.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseDocDetail { response in
//     if let docDetail = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

public struct DocDetail: Codable {
    public let data: DocDataClass?
    public let status: Int?
    
    public init(data: DocDataClass?, status: Int?) {
        self.data = data
        self.status = status
    }
}

public struct DocDataClass: Codable {
    public let abstract: String?
    public let author: [Author]?
    public let dbcode, dbname, filename, filenameEn: String?
    public let fund: [Author]?
    public let journal: Journal?
    public let kws: [String]?
    public let orgniz: [Author]?
    public let pageCount, tablename, title, ztcls: String?
    
    enum CodingKeys: String, CodingKey {
        case abstract, author, dbcode, dbname, filename
        case filenameEn = "filename_en"
        case fund, journal, kws, orgniz
        case pageCount = "page_count"
        case tablename, title, ztcls
    }
    
    public init(abstract: String?, author: [Author]?, dbcode: String?, dbname: String?, filename: String?, filenameEn: String?, fund: [Author]?, journal: Journal?, kws: [String]?, orgniz: [Author]?, pageCount: String?, tablename: String?, title: String?, ztcls: String?) {
        self.abstract = abstract
        self.author = author
        self.dbcode = dbcode
        self.dbname = dbname
        self.filename = filename
        self.filenameEn = filenameEn
        self.fund = fund
        self.journal = journal
        self.kws = kws
        self.orgniz = orgniz
        self.pageCount = pageCount
        self.tablename = tablename
        self.title = title
        self.ztcls = ztcls
    }
}

public struct Author: Codable {
    public let code, name: String?
    
    public init(code: String?, name: String?) {
        self.code = code
        self.name = name
    }
}

public struct Journal: Codable {
    public let code, issn: String?
    public let issue: Issue?
    public let name, otherinfo, titleEnglish: String?
    
    enum CodingKeys: String, CodingKey {
        case code, issn, issue, name, otherinfo
        case titleEnglish = "title_english"
    }
    
    public init(code: String?, issn: String?, issue: Issue?, name: String?, otherinfo: String?, titleEnglish: String?) {
        self.code = code
        self.issn = issn
        self.issue = issue
        self.name = name
        self.otherinfo = otherinfo
        self.titleEnglish = titleEnglish
    }
}

public struct Issue: Codable {
    public let issue, name, year: String?
    
    public init(issue: String?, name: String?, year: String?) {
        self.issue = issue
        self.name = name
        self.year = year
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
    public func responseDocDetail(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<DocDetail>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
