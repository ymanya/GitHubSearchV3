//
//  SearchRepositories.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/02.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import Foundation

extension GitHubClient {
  struct SearchRepositories: GitHubRequest {
    typealias Response = SearchRepositoriesResponse

    let query: String
    let page: String

    var path: String {
      return "/search/repositories"
    }

    var queries: [URLQueryItem]? {
      return [
        URLQueryItem(name: "q", value: query),
        URLQueryItem(name: "page", value: page)
      ]
    }

    func send() async throws -> SearchRepositoriesResponse {
      var urlComponents = URLComponents(string: buildUrl)!
      urlComponents.queryItems = queries

      let request = URLRequest(url: urlComponents.url!)
      do {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse else {
          throw GitHubClientError.invalidResponse(nil)
        }

        switch response.statusCode {
        case 200:
          do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            let result = try jsonDecoder.decode(SearchRepositoriesResponse.self, from: data)
            return result
          } catch let error {
            throw GitHubClientError.invalidResponse(error)
          }
        case 400...599:
          throw GitHubClientError.httpError(String(data: data, encoding: .utf8))
        default:
          throw GitHubClientError.invalidResponse(nil)
        }
      } catch let error {
        throw GitHubClientError.connectionError(error)
      }
    }
  }
}

/// リポジトリ検索のレスポンスモデル
struct SearchRepositoriesResponse: Decodable {
  ///　取得したリポジトリの配列
  var items: [GitHubRepository]
  /// 検索結果のトータル件数
  var totalCount: Int

  init(from decoder: Decoder) throws {
    let root = try decoder.container(keyedBy: CodingKeys.self)
    items = try root.decode(Array<GitHubRepository>.self, forKey: .items)
    totalCount = try root.decode(Int.self, forKey: .totalCount)
  }

  private enum CodingKeys: String, CodingKey {
    case items = "items"
    case totalCount = "total_count"
  }
}
