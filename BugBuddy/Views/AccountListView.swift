//
//  AccountListView.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/16/24.
//

import SwiftUI

struct AccountListView: View {
    
    @EnvironmentObject var dataModel: DataModel
    
    var body: some View {
        List(dataModel.accounts) { account in
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
        .environmentObject(DataModel(accounts: Account.examples()))
}
