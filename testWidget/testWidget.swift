import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Toggle Visibility Intent
struct ToggleBalanceVisibilityIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Balance Visibility"
    
    func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: "group.com.yourcompany.bankingapp")
        let currentlyHidden = userDefaults?.bool(forKey: "balancesHidden") ?? false
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
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
            
            switch family {
            case .systemSmall:
                smallWidgetView
            case .systemMedium:
                mediumWidgetView
            case .systemLarge:
                largeWidgetView
            case .systemExtraLarge:
                extraLargeWidgetView
            @unknown default:
                mediumWidgetView
            }
        }
    }
    
    // MARK: - Small Widget
    var smallWidgetView: some View {
        VStack(spacing: 4) {
            // Header with logo and eye button
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
                    .padding(4)
                    .background(Color.blue)
                    .cornerRadius(4)
                
                Spacer()
                
                Button(intent: ToggleBalanceVisibilityIntent()) {
                    Image(systemName: entry.isHidden ? "eye.slash" : "eye")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            
            // Total balance
            VStack(alignment: .center, spacing: 2) {
                Text("Total Balance")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                if entry.isHidden {
                    Text("$****.**")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                } else {
                    Text("$30,000.00")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                }
                
                Text("USD")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 10)
            
            // Compact accounts list
            VStack(spacing: 2) {
                HStack {
                    Text("Chequing")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if entry.isHidden {
                        Text("$****.**")
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                    } else {
                        Text("$5,000.00")
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                    }
                }
                
                HStack {
                    Text("Savings")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if entry.isHidden {
                        Text("$****.**")
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                    } else {
                        Text("$10,000.00")
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                    }
                }
                
                HStack {
                    Text("Investment")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if entry.isHidden {
                        Text("$****.**")
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                    } else {
                        Text("$15,000.00")
                            .font(.system(size: 10))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
    }
    
    // MARK: - Medium Widget
    var mediumWidgetView: some View {
        VStack(spacing: 0) {
            // Header with bank logo and eye toggle button
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
                    .padding(6)
                    .background(Color.blue)
                    .cornerRadius(6)
                
                Spacer()
                
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                
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
    
    // MARK: - Large Widget
    var largeWidgetView: some View {
        VStack(spacing: 0) {
            // Header with bank logo, name and toggle
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
                    .padding(8)
                    .background(Color.blue)
                    .cornerRadius(8)
                
                Text("My Banking")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(intent: ToggleBalanceVisibilityIntent()) {
                    Image(systemName: entry.isHidden ? "eye.slash" : "eye")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.blue.opacity(0.1))
            
            
            // Accounts list with more details
            ScrollView {
                VStack(spacing: 12) {
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
                        name: "My savings",
                        accountNumber: "5678",
                        balance: 10000.00,
                        currency: "USD",
                        monthlyChange: 1200,
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
                    
                    
                    // Recent activity section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Activity")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.bottom, 4)
                        
                        transactionRow(
                            merchant: "Grocery Store",
                            date: "Today",
                            amount: -85.40,
                            isHidden: entry.isHidden
                        )
                        
                        transactionRow(
                            merchant: "Salary Deposit",
                            date: "Yesterday",
                            amount: 3000.00,
                            isHidden: entry.isHidden
                        )
                        
                        transactionRow(
                            merchant: "Coffee Shop",
                            date: "Feb 15",
                            amount: -4.75,
                            isHidden: entry.isHidden
                        )
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
        }
    }
    
    // MARK: - Extra Large Widget (iPad)
    var extraLargeWidgetView: some View {
        HStack(spacing: 0) {
            // Left side: Summary & Stats
            VStack(spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(10)
                    
                    Text("Financial Dashboard")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(intent: ToggleBalanceVisibilityIntent()) {
                        Image(systemName: entry.isHidden ? "eye.slash" : "eye")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 10)
                
                // Total Balance
                VStack(spacing: 4) {
                    Text("Total Balance")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    HStack {
                        if entry.isHidden {
                            Text("$****.**")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                        } else {
                            Text("$30,000.00")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Text("USD")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(.leading, -4)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                
                // Monthly Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("February Summary")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Income")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            if entry.isHidden {
                                Text("$****.**")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.green)
                            } else {
                                Text("$5,600.00")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Spending")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            if entry.isHidden {
                                Text("$****.**")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.red)
                            } else {
                                Text("$4,400.00")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Savings")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            if entry.isHidden {
                                Text("$****.**")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.blue)
                            } else {
                                Text("$1,200.00")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1)
            
            // Right side: Accounts & Transactions
            VStack(spacing: 16) {
                // Accounts Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("My Accounts")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    largeAccountRow(
                        name: "My chequing",
                        accountNumber: "1234",
                        balance: 5000.00,
                        currency: "USD",
                        monthlyChange: 1200,
                        month: "February",
                        isHidden: entry.isHidden
                    )
                    
                    largeAccountRow(
                        name: "My savings",
                        accountNumber: "5678",
                        balance: 10000.00,
                        currency: "USD",
                        monthlyChange: 1200,
                        month: "February",
                        isHidden: entry.isHidden
                    )
                    
                    largeAccountRow(
                        name: "Investment",
                        accountNumber: "9012",
                        balance: 15000.00,
                        currency: "USD",
                        monthlyChange: -1200,
                        month: "February",
                        isHidden: entry.isHidden
                    )
                }
                
                // Recent Transactions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Transactions")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    VStack(spacing: 8) {
                        transactionRow(
                            merchant: "Grocery Store",
                            date: "Today",
                            amount: -85.40,
                            isHidden: entry.isHidden
                        )
                        
                        Divider()
                        
                        transactionRow(
                            merchant: "Salary Deposit",
                            date: "Yesterday",
                            amount: 3000.00,
                            isHidden: entry.isHidden
                        )
                        
                        Divider()
                        
                        transactionRow(
                            merchant: "Coffee Shop",
                            date: "Feb 15",
                            amount: -4.75,
                            isHidden: entry.isHidden
                        )
                        
                        Divider()
                        
                        transactionRow(
                            merchant: "Online Store",
                            date: "Feb 14",
                            amount: -49.99,
                            isHidden: entry.isHidden
                        )
                        
                        Divider()
                        
                        transactionRow(
                            merchant: "Utility Bill",
                            date: "Feb 12",
                            amount: -128.50,
                            isHidden: entry.isHidden
                        )
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Helper Views
    
    // Helper function for regular account rows (medium widget)
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
    
    // Helper function for large account rows (large & extra large widgets)
    private func largeAccountRow(name: String, accountNumber: String, balance: Double, currency: String,
                               monthlyChange: Double, month: String, isHidden: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // Account icon based on type
                Image(systemName: name.contains("savings") ? "banknote" : (name.contains("Investment") ? "chart.line.uptrend.xyaxis" : "creditcard"))
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .frame(width: 30, height: 30)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text("\(name.contains("Investment") ? "Investment" : "Chequing") (\(accountNumber))")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    if isHidden {
                        Text("$****.**")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    } else {
                        Text("$\(String(format: "%,.2f", balance))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    HStack(spacing: 2) {
                        let changeColor = monthlyChange >= 0 ? Color.green : Color.red
                        let changePrefix = monthlyChange >= 0 ? "+" : ""
                        
                        if isHidden {
                            Text("\(monthlyChange >= 0 ? "+" : "-")$****")
                                .font(.system(size: 12))
                                .foregroundColor(changeColor)
                        } else {
                            Text("\(changePrefix)$\(String(format: "%,.0f", monthlyChange))")
                                .font(.system(size: 12))
                                .foregroundColor(changeColor)
                        }
                        
                        Text("in \(month)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
    
    // Helper function for transaction rows
    private func transactionRow(merchant: String, date: String, amount: Double, isHidden: Bool) -> some View {
        HStack {
            // Transaction icon (deposit or payment)
            Image(systemName: amount >= 0 ? "arrow.down" : "arrow.up")
                .font(.system(size: 12))
                .foregroundColor(amount >= 0 ? .green : .red)
                .frame(width: 24, height: 24)
                .background(Color(amount >= 0 ? .green : .red).opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(merchant)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                
                Text(date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isHidden {
                Text("\(amount >= 0 ? "+" : "")-$****.**")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(amount >= 0 ? .green : .black)
            } else {
                Text("\(amount >= 0 ? "+" : "")\(String(format: "$%.2f", amount))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(amount >= 0 ? .green : .black)
            }
        }
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

// MARK: - Widget Bundle
@main
struct BankingWidgets: WidgetBundle {
    var body: some Widget {
        BankingWidget()
    }
}
