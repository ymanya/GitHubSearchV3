//
//  ViewController.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/02.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    GitHubClient.SearchRepositories(query: "swift").send { result in
      print(result)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}
