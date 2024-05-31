//
//  AddNewAccount.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/16/24.
//

import SwiftUI

struct AddNewAccountView: View {
    @Environment(\.modelContext) private var dataModel
    @State private var account = Account.emptyAccount

    @EnvironmentObject var navigationModel: NavigationStateManager
    @State private var apiKey: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add New Account")
                .font(.largeTitle)
            Form {
                Section(content: {
                    TextField("Account Name", text: $account.title)
                    SecureField("API Key", text: $apiKey)
                }, footer: {
                    Text("Your API key is stored within Keychain and not persisted within the app.")
                        .font(.callout)
                        .padding(.top, 4)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                })
                HStack(alignment: .center) {
                    Button(action: {
                        doSaveAccount()
                    }, label: {
                        Text("Save")
                    })
                    .buttonStyle(NiceButton())
                }
                .padding(.top)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
            .onSubmit {
                doSaveAccount()
            }
            Spacer()
        }
        .navigationTitle("Accounts")
        .padding()
        Spacer()
    }
    
    func doSaveAccount() {
        if (!apiKey.isEmpty) {
            dataModel.insert(account)
            
            do {
                try dataModel.save()
                try account.saveApiKey(for: apiKey, service: "bugsnag", account: account.title)
            } catch {
            }
            navigationModel.navigateTo(account: account)
        }
    }
}


#Preview {
    NavigationSplitView {
        SidebarView()
    } detail: {
        AddNewAccountView()
    }
    .environmentObject(NavigationStateManager())
    .modelContainer(for: [Account.self])
    
}
