//
//  Date.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/05.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import Foundation

extension Date {
  /// 相対的な日付文字列に変換します
  func toRelativeDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    formatter.doesRelativeDateFormatting = true
    return formatter.string(from: self)
  }
}
