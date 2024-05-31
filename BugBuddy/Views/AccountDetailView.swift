//
//  AccountDetailView.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/16/24.
//

import SwiftUI
import LocalAuthentication

struct AccountDetailView: View {
    @Environment(\.modelContext) private var dataModel
    @EnvironmentObject var navigationModel: NavigationStateManager
    @State private var apiKey: String = ""
    @State private var hasAuthenticated: Bool = false
    let account: Account
    
    func getApiKey() {
        do {
            apiKey = try account.getApiKey(account: account.title)
        } catch {
            apiKey = "nothing"
        }
        
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(account.title)
                    .font(.title)
                    .padding(.bottom)
                HStack(alignment: .center) {
                    Text("API Key: \(hasAuthenticated ? apiKey : "••••••••••••••••••••")")
                        .frame(minWidth: 200, alignment: .leading)
                    Button(action: {
                        
                        hasAuthenticated ?
                        hasAuthenticated.toggle() :
                        
                        authenticate()
                    }, label: {
                        Image(systemName: hasAuthenticated ? "eye" : "eye.slash")
                    })
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text("Your API key is stored within Keychain. Removing it from here will also remove it from Kychain.")
                .font(.callout)
                .padding(.top, 4)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
            Spacer()
            Button(action: {
                do {
                    try account.deleteApiKey(account: account.title, service: "bugsnag")
                    dataModel.delete(account)
                    try dataModel.save()
                    navigationModel.resetPath()
                    navigationModel.popToRoot()
                } catch {
                }
            }, label: {
                Text("Remove Account")
            })
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear {
            getApiKey()
        }
        .padding()
        .navigationTitle(account.title)
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We use Biometrics to show/hide your API key."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        // authenticated successfully
                        hasAuthenticated = true
                    } else {
                        // there was a problem
                    }
                }
            }
        } else {
            // no biometrics
            
        }
    }
}

#Preview {
    NavigationSplitView {
        SidebarView()
    } detail: {
        AccountDetailView(account: Account.examples().first!)
    }
    .environmentObject(NavigationStateManager())
    .modelContainer(for: [Account.self])
}
