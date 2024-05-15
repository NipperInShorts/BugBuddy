//
//  ContentView.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/9/24.
//

import SwiftUI
import Combine
import Foundation

enum SelectionState: Hashable, Codable  {
    case accounts(Account)
    case settings
}


class NavigationStateManager: ObservableObject {
    
    @Published var selectionState: SelectionState? = nil
    
    var data: Data? {
        get {
            // why encolde seleciton state?
            try? JSONEncoder().encode(selectionState)
        }
        
        set {
            guard let data = newValue,
                  let selectionState = try? JSONDecoder().decode(SelectionState.self, from: data) else {
                return
            }
            
            self.selectionState = selectionState
        }
    }
    
    func popToRoot() {
        selectionState = nil
    }
    
    func goToSettings() {
        selectionState = .settings
    }
    
    func setSelectedAccount(to account: Account) {
        selectionState = .accounts(account)
    }
    
    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }
}


struct ContentView: View {
    
    @State private var selectedAccount: String?
    @State private var selectionState: SelectionState?
    
    @StateObject var navigationStateManager = NavigationStateManager()
    @StateObject var dataModel = ModelDataManager()
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
