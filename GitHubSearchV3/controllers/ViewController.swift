//
//  ViewController.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/02.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import UIKit
import SafariServices

// MARK: - ViewController
class ViewController: UIViewController {
  // MARK: - クラス内変数
  /// 取得したリポジトリ配列
  var repositories = [GitHubRepository]() {
    didSet {
      if repositories.isEmpty {
        tableView.separatorStyle = .none
        resultText = ""
      } else {
        tableView.separatorStyle = .singleLine
      }
      tableView.reloadData()
    }
  }
  /// 結果件数表示文字列
  var resultText = "" {
    didSet {
      resultLabel.text = resultText
    }
  }
  /// インクリメンタルサーチのスロットリングを行うタイマー
  var timer: Timer?
  /// 検索バー
  let searchBar = UISearchBar()
  
  // MARK: - IBOutlet
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var resultLabel: UILabel!

  // MARK: - ViewController Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    repositories = []
    
    searchBar.delegate = self
    searchBar.placeholder = "Search"
    searchBar.returnKeyType = .done
    searchBar.keyboardType = .alphabet
    searchBar.returnKeyType = .search
    searchBar.becomeFirstResponder()
    navigationItem.titleView = searchBar
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
extension ViewController: UISearchBarDelegate {
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    guard searchText.count > 0 else {
      repositories = []
      return
    }
    
    activityIndicator.startAnimating()
    resultText = ""

    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) {_ in 
      GitHubClient.SearchRepositories(query: searchText).send { [unowned self] result in
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
          switch result {
          case .success(let response):
            self.repositories = response.items
            self.resultText = "\(self.repositories.count) of \(response.totalCount)"
          case .failure(let error):
            self.showAlert(withMessage: error.localizedDescription)
          }
        }
      }
    }
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
extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let safariVC = SFSafariViewController(url: repositories[indexPath.row].htmlUrl)
    present(safariVC, animated: true, completion: nil)
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    searchBar.resignFirstResponder()
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return repositories.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let repository = repositories[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RepositoryTableViewCell
    cell.configure(with: repository)
    return cell
  }
}
