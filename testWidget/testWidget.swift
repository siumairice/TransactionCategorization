import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Toggle Visibility Intent
struct ToggleBalanceVisibilityIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Balance Visibility"
    
    func perform() async throws -> some IntentResult {
        // Get current visibility state
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.bankingapp")
        let currentlyHidden = userDefaults?.bool(forKey: "balancesHidden") ?? false
        
        // Toggle the state
        userDefaults?.set(!currentlyHidden, forKey: "balancesHidden")
        userDefaults?.synchronize()
        
        return .result()
    }
}

// MARK: - Simple Entry Structure
struct SimpleEntry: TimelineEntry {
    let date: Date
    let isHidden: Bool
}

// MARK: - Provider with UserDefaults Integration
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), isHidden: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.bankingapp")
        let isHidden = userDefaults?.bool(forKey: "balancesHidden") ?? false
        
        let entry = SimpleEntry(date: Date(), isHidden: isHidden)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.bankingapp")
        let isHidden = userDefaults?.bool(forKey: "balancesHidden") ?? false
        
        let entry = SimpleEntry(date: Date(), isHidden: isHidden)
        
        // Update every hour or when the widget is refreshed
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

// MARK: - Widget View
struct BankingWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
            
            VStack(spacing: 0) {
                // Header with bank logo and eye toggle button
                HStack {
                    // Bank logo
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.yellow)
                        .padding(6)
                        .background(Color.blue)
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    // Refresh button - could be made interactive with another intent
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                    
                    // Interactive eye toggle button
                    Button(intent: ToggleBalanceVisibilityIntent()) {
                        Image(systemName: entry.isHidden ? "eye.slash" : "eye")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                
                // Accounts list
                VStack(spacing: 0) {
                    // Account 1
                    accountRow(
                        name: "My chequing",
                        accountNumber: "1234",
                        balance: 5000.00,
                        currency: "USD",
                        monthlyChange: 1200,
                        month: "February",
                        isHidden: entry.isHidden
                    )
                    
                    Divider().padding(.horizontal, 12)
                    
                    // Account 2
                    accountRow(
                        name: "My savings",
                        accountNumber: "5678",
                        balance: 10000.00,
                        currency: "USD",
                        monthlyChange: 1200,
                        month: "February",
                        isHidden: entry.isHidden
                    )
                    
                    Divider().padding(.horizontal, 12)
                    
                    // Account 3
                    accountRow(
                        name: "Investment",
                        accountNumber: "9012",
                        balance: 15000.00,
                        currency: "USD",
                        monthlyChange: -1200,
                        month: "February",
                        isHidden: entry.isHidden
                    )
                    Divider().padding(.horizontal, 12)
                    accountRow(
                        name: "Investment",
                        accountNumber: "9012",
                        balance: 15000.00,
                        currency: "USD",
                        monthlyChange: -1200,
                        month: "February",
                        isHidden: entry.isHidden
                    )
                    Divider().padding(.horizontal, 12)
                    
                    accountRow(
                        name: "Investment",
                        accountNumber: "9012",
                        balance: 15000.00,
                        currency: "USD",
                        monthlyChange: -1200,
                        month: "February",
                        isHidden: entry.isHidden
                    )
                }
            }
        }
    }
    
    // Helper function to create account rows
    private func accountRow(name: String, accountNumber: String, balance: Double, currency: String,
                           monthlyChange: Double, month: String, isHidden: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                if isHidden {
                    Text("$****.**")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                } else {
                    Text("$\(String(format: "%.2f", balance))")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Text(currency)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding(.leading, -4)
            }
            
            HStack {
                Text("\(name.contains("Investment") ? "Investment" : "Chequing") (\(accountNumber))")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                let changeColor = monthlyChange >= 0 ? Color.green : Color.red
                let changePrefix = monthlyChange >= 0 ? "+" : ""
                
                if isHidden {
                    Text("\(monthlyChange >= 0 ? "+" : "-")$****")
                        .font(.system(size: 12))
                        .foregroundColor(changeColor)
                } else {
                    Text("\(changePrefix)$\(String(format: "%.0f", monthlyChange))")
                        .font(.system(size: 12))
                        .foregroundColor(changeColor)
                }
                
                Text("in \(month)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

// MARK: - Widget Configuration
struct BankingWidget: Widget {
    let kind: String = "BankingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BankingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Banking Widget")
        .description("View your account balances")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Widget Bundle
@main
struct BankingWidgets: WidgetBundle {
    var body: some Widget {
        BankingWidget()
    }
}
