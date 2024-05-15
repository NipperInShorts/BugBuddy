//
//  ContentView.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/9/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedAccount: String?
    @State private var selectionState: SelectionState?
    
    @StateObject var navigationStateManager = NavigationStateManager()
    @StateObject var dataModel = DataModel()
    @SceneStorage("navigationState") var navigationStateData: Data?
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            DetailView()
        }
        .environmentObject(navigationStateManager)
        .environmentObject(dataModel)
        .onAppear {
            navigationStateManager.data = navigationStateData
        }
        .onReceive(navigationStateManager.$selectionState.dropFirst()) { _ in
            navigationStateData = navigationStateManager.data
        }
    }
}

#Preview {
    ContentView()
}
