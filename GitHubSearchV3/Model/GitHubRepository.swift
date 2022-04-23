//
//  GitHubRepository.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya.
//  Copyright © ymanya. All rights reserved.
//

import Foundation

/// GitHubリポジトリのモデル
struct GitHubRepository: Decodable {
  /// リポジトリ名
  var fullName: String
  /// リポジトリの説明
  var desc: String?
  /// リポジトリのURL
  var htmlUrl: URL
  /// スター数
  var stargazersCount: Int
  /// リポジトリで使われている言語
  var language: String?
  /// 最終更新日
  var updatedAt: Date
  
  private enum CodingKeys: String, CodingKey {
    case fullName = "full_name"
    case desc = "description"
    case htmlUrl = "html_url"
    case stargazersCount = "stargazers_count"
    case language = "language"
    case updatedAt = "updated_at"
  }
}
