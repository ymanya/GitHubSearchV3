//
//  RepositoryListItem.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2020/01/05.
//  Copyright © 2020 ymanya. All rights reserved.
//

import SwiftUI

struct RepositoryListItem: View {
    var repository: GitHubRepository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(repository.fullName).font(.title)
            
            Text(repository.desc ?? "").font(.body)
            
            HStack(alignment: .top, spacing: 8) {
                HStack {
                    Text("🗒")
                        .font(.subheadline)
                    Text(repository.language ?? "")
                        .font(.subheadline)
                }
                HStack {
                    Text("⭐️")
                        .font(.subheadline)
                    Text(repository.stargazersCount.toStringWithComma())
                        .font(.subheadline)
                }
            }
        }
        .padding(.all)
    }
}

struct RepositoryListItem_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryListItem(
            repository: GitHubRepository(
                fullName: "apple/swift",
                desc: "hoge",
                htmlUrl: URL(string: "https://github.com/apple/swift")!,
                stargazersCount: 100000,
                language: "swift",
                updatedAt: Date()
        ))
            .previewLayout(.fixed(width: 320, height: 150))
    }
}
