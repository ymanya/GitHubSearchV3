//
//  GitHubRequest.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/02.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import Foundation

/// リクエストのプロトコル
protocol GitHubRequest {
  /// レスポンスの型を指定
  associatedtype Response
  /// リクエストのベースURL
  var baseUrl: String { get }
  /// ベースURLを除くリクエストしたいパス
  var path: String { get }
  /// クエリ配列
  var queries: [URLQueryItem]? { get }
  
  /// APIへのリクエストを行うメソッド
  func send(completion: @escaping (Result<Response, GitHubClientError>) -> Void)
}

extension GitHubRequest {
  var baseUrl: String {
    return "https://api.github.com"
  }
  /// ベースURLとパスを組み合わせてリクエストするURL
  var buildUrl: String {
    return baseUrl + path
  }
}

/// リクエスト結果のenum
enum Result<Value, Error> {
  case success(Value)
  case failure(GitHubClientError)
  
  init(value: Value) {
    self = .success(value)
  }
  
  init(error: GitHubClientError) {
    self = .failure(error)
  }
}
