//
//  ContentView.swift
//  GitHubSearchV3
//
//  Created by Yuki Manya on 2020/01/05.
//  Copyright © 2020 ymanya. All rights reserved.
//

import SwiftUI
import SafariServices

struct ContentView: View {
    var repositories = [
        GitHubRepository(
                fullName: "apple/swift",
                desc: "hoge",
                htmlUrl: URL(string: "https://github.com/apple/swift")!,
                stargazersCount: 100000,
                language: "swift",
                updatedAt: Date()
        )
    ]
    @State var showRepository: GitHubRepository? = nil
    
    var body: some View {
        NavigationView {
            List(repositories) { repository in
                VStack {
                    Button(action: {
                        self.showRepository = repository
                    }) {
                        RepositoryListItem(repository: repository)
                    }
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .sheet(item: $showRepository, content: { showRepository in
            SafariView(url: showRepository.htmlUrl)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        var view = ContentView()
        view.repositories = [
            GitHubRepository(
                    fullName: "apple/swift",
                    desc: "hoge",
                    htmlUrl: URL(string: "https://github.com/apple/swift")!,
                    stargazersCount: 100000,
                    language: "swift",
                    updatedAt: Date()
            )
        ]
        return view
    }
}
