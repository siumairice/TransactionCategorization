import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Account View Model
class AccountViewModel {
    let account: AccountDetail
    let isHidden: Bool
    let monthlyChange: Double
    let month: String
    let currency: String
    
    init(account: AccountDetail, isHidden: Bool, monthlyChange: Double = 1200, month: String = "March", currency: String = "USD") {
        self.account = account
        self.isHidden = isHidden
        self.monthlyChange = monthlyChange
        self.month = month
        self.currency = currency
    }
    
    var accountType: String {
        account.accountName.contains("Investment") ? "Investment" : "Chequing"
    }
    
    var displayBalance: String {
        account.displayBalance(isHidden: isHidden)
    }
    
    var displayMonthlyChange: String {
        if isHidden {
            return "\(monthlyChange >= 0 ? "+" : "-")$****"
        } else {
            let prefix = monthlyChange >= 0 ? "+" : ""
            return "\(prefix)$\(String(format: "%.0f", monthlyChange))"
        }
    }
    
    var monthlyChangeColor: Color {
        monthlyChange >= 0 ? Color.green : Color.red
    }
}

// MARK: - Reusable UI Components
struct ToggleVisibilityButton: View {
    let isHidden: Bool
    
    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            Button(intent: ToggleBalanceVisibilityIntent()) {
                Image(systemName: isHidden ? "eye.slash" : "eye")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
    }
}


struct RefreshButton: View {
    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            Button(intent: RefreshWidgetIntent()) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct BankingWidgetHeader: View {
    let isHidden: Bool
    var padding: EdgeInsets = EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
    
    var body: some View {
        HStack {
            Image(systemName: "creditcard.fill")
                .foregroundColor(.yellow)
            
            Spacer()
            
            RefreshButton()
            ToggleVisibilityButton(isHidden: isHidden)
        }
        .padding(padding)
        .background(Color.blue.opacity(0.5))
    }
}

struct SmallWidgetHeader: View {
    let isHidden: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 14))
                .foregroundColor(.yellow)
            Spacer()
            
            RefreshButton()
            ToggleVisibilityButton(isHidden: isHidden)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.blue.opacity(0.5))
    }
}

struct AccountRowView: View {
    let viewModel: AccountViewModel
    
    init(account: AccountDetail, isHidden: Bool) {
        self.viewModel = AccountViewModel(account: account, isHidden: isHidden)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(viewModel.account.accountName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text(viewModel.displayBalance)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Text(viewModel.currency)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding(.leading, -4)
            }
            
            HStack {
                Text("\(viewModel.accountType) (\(viewModel.account.accountNumber))")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(viewModel.displayMonthlyChange)
                    .font(.system(size: 12))
                    .foregroundColor(viewModel.monthlyChangeColor)
                
                Text("in \(viewModel.month)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

struct EmptyAccountsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No accounts selected")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
    }
}

// MARK: - Widget View
struct AccountPreviewWidgetView: View {
    var entry: AccountPreviewEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        case .systemMedium:
            mediumWidgetView
        case .systemLarge:
            largeWidgetView
        case .systemExtraLarge:
            largeWidgetView
        @unknown default:
            mediumWidgetView
        }
    }
    
    // Small Widget View
    var smallWidgetView: some View {
        VStack(spacing: 0) {
            // Use reusable small header
            SmallWidgetHeader(isHidden: entry.isBalancesHidden)
            
            if entry.accounts.isEmpty {
                EmptyAccountsView()
            } else {
                let account = entry.accounts[0]
                VStack(spacing: 2) {
                    Text(account.accountName)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("\(account.accountName) (\(account.accountNumber))")
                    Text(account.displayBalance(isHidden: entry.isBalancesHidden))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(.vertical, 10)
            }
        }
    }
    
    // Medium Widget View
    var mediumWidgetView: some View {
        VStack(spacing: 0) {
            // Use reusable header
            BankingWidgetHeader(isHidden: entry.isBalancesHidden)
                .padding(.bottom, 5)
            
            if entry.accounts.isEmpty {
                EmptyAccountsView()
            } else {
                // Accounts list (show first 2 accounts for medium widget)
                VStack(spacing: 0) {
                    ForEach(0..<min(2, entry.accounts.count), id: \.self) { index in
                        if index > 0 {
                            Divider().padding(.horizontal, 12)
                        }
                        
                        AccountRowView(
                            account: entry.accounts[index],
                            isHidden: entry.isBalancesHidden
                        )
                    }
                }
            }
            Spacer()
        }
    }
    
    // Large Widget View
    var largeWidgetView: some View {
        VStack(spacing: 0) {
            // Use reusable header
            BankingWidgetHeader(isHidden: entry.isBalancesHidden)
                .padding(.bottom, 5)
            
            if entry.accounts.isEmpty {
                EmptyAccountsView()
            } else {
                // Accounts list with more details
                VStack(spacing: 0) {
                    // Display all accounts
                    ForEach(0..<min(5, entry.accounts.count), id: \.self) { index in
                        if index > 0 {
                            Divider()
                                .padding(.horizontal, 12)
                        }
                        
                        AccountRowView(
                            account: entry.accounts[index],
                            isHidden: entry.isBalancesHidden
                        )
                    }
                }
            }
        }
    }
}
