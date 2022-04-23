//
//  ViewController.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/02.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import UIKit
import Combine
import SafariServices

// MARK: - ViewController
class MainViewController: UIViewController {
  // MARK: - クラス内変数
  
  var subscriptions = Set<AnyCancellable>()
  let viewModel: MainViewModel = MainViewModel()
  
  /// 検索バー
  let searchBar = UISearchBar()
  
  // MARK: - IBOutlet
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var resultLabel: UILabel!
  @IBOutlet weak var footerActivityIndicator: UIActivityIndicatorView!

  // MARK: - ViewController Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.delegate = self
    searchBar.placeholder = "Search"
    searchBar.returnKeyType = .done
    searchBar.keyboardType = .alphabet
    searchBar.returnKeyType = .search
    searchBar.becomeFirstResponder()
    navigationItem.titleView = searchBar
    
    setupViewModel()
  }
  
  func setupViewModel() {
    viewModel.outputs.repositoriesSubject
      .sink(receiveValue: { [weak self] _ in
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      })
      .store(in: &subscriptions)
    
    viewModel.outputs.isLoadingSubject
      .sink(receiveValue: { [weak self] isLoading in
        DispatchQueue.main.async {
          if (isLoading) {
            self?.activityIndicator.startAnimating()
          } else {
            self?.activityIndicator.stopAnimating()
          }
        }
      })
      .store(in: &subscriptions)
    
    viewModel.outputs.isNextPageLoadingSubject
      .sink(receiveValue: { [weak self] isNextPageLoading in
        DispatchQueue.main.async {
          if isNextPageLoading {
            self?.footerActivityIndicator.startAnimating()
          } else {
            self?.footerActivityIndicator.stopAnimating()
          }
        }
      })
      .store(in: &subscriptions)
    
    viewModel.outputs.resultTextSubject
      .sink(receiveValue: { [weak self] resultText in
        DispatchQueue.main.async {
          self?.resultLabel.text = resultText
        }
      })
      .store(in: &subscriptions)
    
    viewModel.outputs.showWebViewSubject
      .sink(receiveValue: { [weak self] url in
        DispatchQueue.main.async {
          let safariVC = SFSafariViewController(url: url)
          safariVC.dismissButtonStyle = .close
          self?.present(safariVC, animated: true, completion: nil)
        }
      })
      .store(in: &subscriptions)
    
    viewModel.outputs.errorAlertSubject
      .sink(receiveValue: { [weak self] errorAlert in
        DispatchQueue.main.async {
          let alert = UIAlertController(title: "Error", message: errorAlert, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
          self?.present(alert, animated: true, completion: nil)
        }
      })
      .store(in: &subscriptions)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

// MARK: - SearchBar
extension MainViewController: UISearchBarDelegate {
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    guard searchText.count > 0 else {
      viewModel.inputs.resetSearchQuery()
      return
    }
    
    viewModel.inputs.searchRepository(query: searchText)
  }
  
  func showAlert(withMessage message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}

// MARK: - TableView
extension MainViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.inputs.handleDidSelectRowAt(indexPath)
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    searchBar.resignFirstResponder()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let currentOffsetY = scrollView.contentOffset.y
    let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
    let distanceToBottom = maximumOffset - currentOffsetY
    guard maximumOffset > 0 else {
      return
    }
    
    guard !viewModel.isLoadingSubject.value && !viewModel.isNextPageLoadingSubject.value else {
      return
    }
    
    if distanceToBottom < 500 {
      viewModel.inputs.fetchNextPage()
    }
  }
}

extension MainViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.repositoriesSubject.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let repository = viewModel.repositoriesSubject.value[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RepositoryTableViewCell
    cell.configure(with: repository)
    return cell
  }
}
