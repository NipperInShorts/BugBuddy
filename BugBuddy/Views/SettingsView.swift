//
//  SettingsView.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/15/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var dataModel
    @EnvironmentObject var navigationModel: NavigationStateManager
    @Query(sort: [SortDescriptor(\Account.title)]) private var accounts: [Account]
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Accounts")
                    .multilineTextAlignment(.leading)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                Spacer()
            }
            
            NavigationStack(path: $navigationModel.path) {
                if (!accounts.isEmpty) {
                    AccountListView()
                        .scrollContentBackground(.hidden)
                } else {
                    Spacer()
                    ContentUnavailableView {
                        Text("No accounts added yet")
                    } description: {
                        Text("Tap Add Account below to get started")
                    }
                }
                Spacer()
                NavigationLink(value: navigationModel.path) {
                    Button {
                        navigationModel.path.append(Account(title: "Placeholder"))
                    } label: {
                        Label("Add Account", systemImage: "person.circle")
                    }
                    .buttonStyle(NiceButton())
                }
                .buttonStyle(.plain)
                .navigationDestination(for: Account.self) { _ in
                    AddNewAccountView()
                }
            }
        }
        .padding()
        .navigationTitle("Account Settings")
    }
}

struct NiceButton: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.brandPurple)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension Color {
    public static var brandPurple: Color {
        return Color(NSColor(red: 68/255.0, green: 24/255.0, blue: 143/255.0, alpha: 1.0))
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Account.self])
        .environmentObject(NavigationStateManager())
}
