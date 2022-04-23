//
//  UIViewController.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2022/04/22.
//  Copyright © 2022 ymanya. All rights reserved.
//

import UIKit

// MARK: - Localizable
protocol Localizable where Self: UIViewController {
    static var tableName: String { get set }
}
