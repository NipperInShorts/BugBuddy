//
//  DetailView.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/14/24.
//

import SwiftUI

struct DetailView: View {
    
    @EnvironmentObject var navigationStateManager: NavigationStateManager
    
    var body: some View {
        if let state = navigationStateManager.selectionState {
            switch state {
            case .accounts:
                UploadView()
            case .settings:
                SettingsView()
            }
        } else {
            ContentUnavailableView {
                Text("Let's get started")
            } description: {
                Text("Choose an account from the sidebar\n or add one if none added")
            }
        }
    }
}

#Preview {
    DetailView()
        .environmentObject(NavigationStateManager())
}
