//
//  String.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya.
//  Copyright © ymanya. All rights reserved.
//

import Foundation

extension String {
  
  /// 文字列のローカライズ
  ///
  /// - Returns: ローカライズされた文字列
  func localize(_ tableName: String? = nil) -> String {
      return NSLocalizedString(self, tableName: tableName, comment: self)
  }

}
