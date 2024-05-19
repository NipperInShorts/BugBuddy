//
//  AddNewAccount.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/16/24.
//

import SwiftUI

struct AddNewAccountView: View {
    
    @State private var account = Account.emptyAccount
    @EnvironmentObject var dataModel: DataModel
    @EnvironmentObject var navigationModel: NavigationStateManager
    @State private var apiKey: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add New Account")
                .font(.largeTitle)
            Form {
                TextField("Account Name", text: $account.title)
                SecureField("API Key", text: $apiKey)
            }
            .onSubmit {
                if (!apiKey.isEmpty) {
                    if let account = dataModel.addAccount(for: account) {
                        do {
                            try account.saveApiKey(for: apiKey, service: "bugsnag", account: account.title)
                        } catch {
                            print("Failed to save \(error)")
                        }
                        navigationModel.navigateTo(account: account)
                    }
                    
                }
            }
            Spacer()
        }
        .padding()
        Spacer()
    }
}


#Preview {
    NavigationSplitView {
        SidebarView()
    } detail: {
        AddNewAccountView()
    }
    .environmentObject(NavigationStateManager())
    .environmentObject(DataModel())
    
}
