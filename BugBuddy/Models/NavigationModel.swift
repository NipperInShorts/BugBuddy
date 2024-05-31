//
//  NavigationModel.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/14/24.
//

import SwiftUI
import Combine

enum SelectionState: Hashable, Codable  {
    case accounts(Account)
    case settings
}


class NavigationStateManager: ObservableObject {
    
    @Published var selectionState: SelectionState? = nil
    @Published var path: [Account] = []
    
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
    
    func resetPath() {
        path = []
    }
    
    func navigateTo(account: Account) {
        resetPath()
        setSelectedAccount(to: account)        
    }
    
    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }
}


