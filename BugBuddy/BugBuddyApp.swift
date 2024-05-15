//
//  BugBuddyApp.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/9/24.
//

import SwiftUI

@main
struct BugBuddy: App {
    var body: some Scene {
        Window("Bug Buddy", id: "main") {
            ContentView()
            #if os(macOS)
                .frame(minWidth: 500, minHeight: 500)
            #endif
        }
        #if os(macOS)
        .commands {
            SidebarCommands()
        }
        #endif
    }
}
