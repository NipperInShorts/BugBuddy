//
//  SidebarView.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/14/24.
//

import SwiftUI

struct SidebarView: View {
    
    @EnvironmentObject var navigationManager: NavigationStateManager
    @EnvironmentObject var dataModel: DataModel
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List(selection: $navigationManager.selectionState) {
                Section(header: Text("Connected Accounts")) {
                    ForEach(dataModel.accounts, id:\.id) { account in
                        Text(account.title)
                            .tag(SelectionState.accounts(account))
                    }
                }
            }
            Spacer()
            Button {
                navigationManager.goToSettings()
            } label: {
                Text("Account Settings")
            }
            .buttonStyle(.plain)
            .tag(SelectionState.settings)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(navigationManager.selectionState == .settings ? Color.gray.opacity(0.2) : nil)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(8)
        }
        .frame(minWidth: 175)
    }
}

#Preview {
    SidebarView()
        .environmentObject(NavigationStateManager())
        .environmentObject(DataModel())
}
