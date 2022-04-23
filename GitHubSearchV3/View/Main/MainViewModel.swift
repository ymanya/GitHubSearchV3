//
//  MainViewModel.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya.
//  Copyright © ymanya. All rights reserved.
//

import Foundation
import Combine

protocol MainViewModelInputs {
  func searchRepository(query: String?)
  func fetchNextPage()
  func resetSearchQuery()
  func handleDidSelectRowAt(_ indexPath: IndexPath)
}

protocol MainViewModelOutputs {
  var repositoriesSubject: CurrentValueSubject<[GitHubRepository], Never> { get }
  var isLoadingSubject: CurrentValueSubject<Bool, Never> { get }
  var isNextPageLoadingSubject: CurrentValueSubject<Bool, Never> { get }
  var resultTextSubject: PassthroughSubject<String, Never> { get }
  var showWebViewSubject: PassthroughSubject<URL, Never> { get }
  var errorAlertSubject: PassthroughSubject<String, Never> { get }
}

protocol MainViewModelType {
  var inputs: MainViewModelInputs { get }
  var outputs: MainViewModelOutputs { get }
}

final class MainViewModel: MainViewModelType, MainViewModelOutputs {

  var inputs: MainViewModelInputs { return self }
  var outputs: MainViewModelOutputs { return self }

  var repositoriesSubject = CurrentValueSubject<[GitHubRepository], Never>([])
  var isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
  var isNextPageLoadingSubject = CurrentValueSubject<Bool, Never>(false)
  var resultTextSubject = PassthroughSubject<String, Never>()
  var showWebViewSubject = PassthroughSubject<URL, Never>()
  var errorAlertSubject = PassthroughSubject<String, Never>()

  /// 検索テキスト
  var searchText: String? = ""
  /// 現在表示中のページ
  var page = 1
  /// 最終ページに到達したかのフラグ
  var isReachedLastPage = false
  /// インクリメンタルサーチのスロットリングを行うタイマー
  var timer: Timer?

}

extension MainViewModel: MainViewModelInputs {

  func searchRepository(query: String?) {
    guard let query = query else { return }

    timer?.invalidate()

    isLoadingSubject.send(true)
    page = 1
    repositoriesSubject.send([])
    searchText = query
    resultTextSubject.send("")

    timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
      Task { [weak self] in
        do {
          let result = try await GitHubClient.SearchRepositories(query: query, page: "\(self?.page ?? 1)").send()

          self?.isLoadingSubject.send(false)
          self?.repositoriesSubject.value.append(contentsOf: result.items)
          self?.resultTextSubject.send("\(result.items.count) of \(result.totalCount)")
        } catch let error {
          self?.isLoadingSubject.send(false)
          guard let error = error as? GitHubClientError else { return }
          self?.errorAlertSubject.send(error.localizedDescription)
        }
      }
    }
  }

  func fetchNextPage() {
    guard !isReachedLastPage else { return }

    isNextPageLoadingSubject.send(true)

    page += 1

    Task {
      do {
        let result = try await GitHubClient.SearchRepositories(query: searchText ?? "", page: "\(page)").send()

        isNextPageLoadingSubject.send(false)
        repositoriesSubject.value.append(contentsOf: result.items)
        resultTextSubject.send("\(self.repositoriesSubject.value.count) of \(result.totalCount)")
        isReachedLastPage = repositoriesSubject.value.count == result.totalCount
      } catch let error {
        isNextPageLoadingSubject.send(false)
        guard let error = error as? GitHubClientError else { return }
        errorAlertSubject.send(error.localizedDescription)
      }
    }
  }

  func resetSearchQuery() {
    page = 1
    repositoriesSubject.send([])
    searchText = ""
    resultTextSubject.send("")
  }

  func handleDidSelectRowAt(_ indexPath: IndexPath) {
    let item = repositoriesSubject.value[indexPath.row]
    showWebViewSubject.send(item.htmlUrl)
  }

}
