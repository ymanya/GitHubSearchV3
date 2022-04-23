//
//  RepositoryTableViewCell.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/04.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {
  @IBOutlet weak var fullNameLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var languageLabel: UILabel!
  @IBOutlet weak var starLabel: UILabel!
  @IBOutlet weak var updatedLabel: UILabel!
  
  func configure(with repository: GitHubRepository) {
    fullNameLabel.text = repository.fullName
    descLabel.text = repository.desc
    languageLabel.text = repository.language ?? "-"
    starLabel.text = repository.stargazersCount.toStringWithComma()
    updatedLabel.text = "Updated on \(repository.updatedAt.toRelativeDateString())"
  }
}
