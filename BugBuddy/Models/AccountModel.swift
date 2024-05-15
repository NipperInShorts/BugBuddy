//
//  AccountModel.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/14/24.
//

import Foundation

struct Account: Identifiable, Hashable, Codable {
    
    var title: String
    let id: UUID
    
    init(title: String) {
        self.title = title
        self.id = UUID()
    }
    
    static func examples() -> [Account] {
        [
            Account(title: "TechStyle"),
            Account(title: "Code Daddys"),
        ]
    }
}

class DataModel: ObservableObject {
    
    @Published var accounts = Account.examples()
    
}
