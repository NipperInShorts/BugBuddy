//
//  AccountListView.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/16/24.
//

import SwiftUI
import SwiftData

struct AccountListView: View {
    @Query(sort: [SortDescriptor(\Account.title)]) private var accounts: [Account]
    
    var body: some View {
        List(accounts) { account in
            NavigationLink {
                AccountDetailView(account: account)
            } label: {
                Text(account.title)
            }
        }
        .background(Color.clear)
    }
}

#Preview {
    AccountListView()
        .modelContainer(for: [Account.self])
}
