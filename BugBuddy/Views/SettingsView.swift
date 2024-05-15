//
//  SettingsView.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/15/24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var dataModel: DataModel
    
    var body: some View {
        NavigationStack {
            List(dataModel.accounts) { account in
                NavigationLink(account.title, value: account)
            }
            .navigationDestination(for: Account.self) { account in
                AccountDetailView(account: account)
            }
        }
        .navigationTitle("Settings")
    }
}

struct AccountDetailView: View {
    let account: Account
    var body: some View {
        Text(account.title)
            .navigationTitle(account.title)
    }
        
}

#Preview {
    SettingsView()
        .environmentObject(DataModel())
}
