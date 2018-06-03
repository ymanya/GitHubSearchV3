//
//  SearchRepositories.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/02.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import Foundation

typealias SearchRepositoriesResult = Result<SearchRepositoriesResponse, GitHubClientError>

extension GitHubClient {
  struct SearchRepositories: GitHubRequest {
    typealias Response = SearchRepositoriesResponse
    
    let query: String
    
    var path: String {
      return "/search/repositories"
    }
    
    var queries: [URLQueryItem]? {
      return [
        URLQueryItem(name: "q", value: query),
      ]
    }
    
    func send(completion: @escaping (SearchRepositoriesResult) -> Void) {
      var urlComponents = URLComponents(string: buildUrl)!
      urlComponents.queryItems = queries
      
      let task = URLSession.shared.dataTask(with: urlComponents.url!) { data, response, error in
        guard error == nil else {
          completion(SearchRepositoriesResult(error: .connectionError(error)))
          return
        }
        guard let jsonData = data, let response = response as? HTTPURLResponse else {
          completion(SearchRepositoriesResult(error: .invalidResponse(error)))
          return
        }

        switch response.statusCode {
        case 200:
          do {
            let result = try JSONDecoder().decode(SearchRepositoriesResponse.self, from: jsonData)
            completion(SearchRepositoriesResult(value: result))
          } catch(let e) {
            completion(SearchRepositoriesResult(error: .invalidResponse(e)))
          }
        case 400...599:
          completion(SearchRepositoriesResult(error: .httpError(String(data: jsonData, encoding: .utf8))))
        default:
          // TODO: 他のステータスは無視しているが必要あれば実装する
          break
        }
      }
      task.resume()
    }
  }
}

struct SearchRepositoriesResponse: Decodable {
  var items: [GitHubRepository]
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

struct GitHubRepository: Decodable {
  var fullName: String
  var description: String
  var htmlUrl: URL
  
  private enum CodingKeys: String, CodingKey {
    case fullName = "full_name"
    case description = "description"
    case htmlUrl = "html_url"
  }
}
