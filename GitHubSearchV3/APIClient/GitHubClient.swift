//
//  GitHubClient.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/02.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import Foundation

struct GitHubClient {
  // 各APIごとにextensionで追加する
}

enum GitHubClientError: Error {
  /// URLSessionのエラー
  case connectionError(Error?)
  /// レスポンスデータが不正
  case invalidResponse(Error?)
  /// 404もしくはレスポンスボディが空
  case httpError(String?)

  var localizedDescription: String {
    switch self {
    case .connectionError(let error):
      return error?.localizedDescription ?? ""
    case .invalidResponse(let error):
      return error?.localizedDescription ?? ""
    case .httpError(let str):
      return str ?? ""
    }
  }
}
