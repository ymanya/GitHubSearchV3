//
//  GitHubRequest.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/02.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import Foundation

protocol GitHubRequest {
  associatedtype Response
  var baseUrl: String { get }
  var path: String { get }
  var queries: [URLQueryItem]? { get }
  
  func send(completion: @escaping (Result<Response, GitHubClientError>) -> Void)
}

extension GitHubRequest {
  var baseUrl: String {
    return "https://api.github.com"
  }
  var buildUrl: String {
    return baseUrl + path
  }
}

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
