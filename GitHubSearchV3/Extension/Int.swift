//
//  Int.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2018/06/05.
//  Copyright © 2018年 ymanya. All rights reserved.
//

import Foundation

extension Int {
  /// Intを三桁ごとにカンマが入ったStringへ
  func toStringWithComma() -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = NumberFormatter.Style.decimal
    formatter.groupingSeparator = ","
    formatter.groupingSize = 3
    return formatter.string(from: NSNumber.init(value: self)) ?? ""
  }
}
