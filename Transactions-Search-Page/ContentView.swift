//
//  ContentView.swift
//  Transactions-Search-Page
//
//  Created by Nicole Go on 2025-02-26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TransactionClassifierView()
    }
}

@main
struct TransactionsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView() // Use the SwiftUI test screen
        }
    }
}

#Preview {
    ContentView()
}
