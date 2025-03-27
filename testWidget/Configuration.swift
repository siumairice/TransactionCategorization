import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Account Model
class AccountModel: Identifiable {
    let id = UUID()
    let accountName: String?
    let accountNumber: String
    let accessibleAccountNumber: String?
    let balance: String
    
    init(accountName: String?, accountNumber: String, balance: String){
        self.accountName = accountName
        self.accountNumber = accountNumber
        self.accessibleAccountNumber = ""
        self.balance = balance
    }
    
    var displayName: String {
        accountName ?? "Account \(accountNumber)"
    }
}

// MARK: - AppEntity Model
struct AccountDetail: AppEntity {
    let id: String
    let accountName: String
    let accountNumber: String
    let balance: String
    let isAvailable = true
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Account"
    static var defaultQuery = AccountQuery()
            
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(accountName) (\(accountNumber))")
    }
    
    // New function to display formatted balance based on visibility setting
    func displayBalance(isHidden: Bool) -> String {
        if isHidden {
            return "$****.**"
        } else {
            return balance
        }
    }

    // Convert the mock data to AccountDetail objects
    static let allAccounts: [AccountDetail] = [
        AccountDetail(id: "Checking", accountName: "My Checking Account", accountNumber: "1234", balance: "$5,432.10"),
        AccountDetail(id: "Savings", accountName: "Savings Account", accountNumber: "5678", balance: "$12,345.67"),
        AccountDetail(id: "Investment", accountName: "Investment Portfolio", accountNumber: "9012", balance: "$87,654.32"),
        AccountDetail(id: "Emergency", accountName: "Emergency Fund", accountNumber: "2468", balance: "$7,500.00"),
        AccountDetail(id: "Vacation", accountName: "Vacation Savings", accountNumber: "1357", balance: "$2,750.88"),
        AccountDetail(id: "Account9999", accountName: "Account 9999", accountNumber: "9999", balance: "$1,000.00")
    ]
}

struct AccountQuery: EntityQuery {
    func entities(for identifiers: [AccountDetail.ID]) async throws -> [AccountDetail] {
        AccountDetail.allAccounts.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [AccountDetail] {
        AccountDetail.allAccounts.filter { $0.isAvailable }
    }
    
    func defaultResult() async -> AccountDetail? {
        try? await suggestedEntities().first
    }
}

// MARK: - Dynamic Options Provider for Accounts
struct AccountOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [AccountDetail] {
        // In a real app, you might fetch these from a database or API
        // For now, we'll use our mock data
        
        // Sort accounts alphabetically
        return AccountDetail.allAccounts.sorted { $0.accountName < $1.accountName }
    }
}


// MARK: - Configuration Intent
struct SelectAccountsIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Accounts"
    static var description = IntentDescription("Selects the bank accounts to display information for.")
    
    @Parameter(
            title: "Accounts",
            description: "Select accounts to display in the widget",
            optionsProvider: AccountOptionsProvider()
        )
    var accounts: [AccountDetail]
    
    init(accounts: [AccountDetail]) {
        self.accounts = accounts
    }

    init() {
        self.accounts = []
    }
}



// MARK: - Toggle Visibility Intent
struct ToggleBalanceVisibilityIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Balance Visibility"
    func perform() async throws -> some IntentResult {
        let userDefaults = UserDefaults(suiteName: BankWidgetConstants.appGroupSuite)
        let currentlyHidden = userDefaults?.bool(forKey: BankWidgetConstants.Keys.balancesHidden) ?? false
        userDefaults?.set(!currentlyHidden, forKey: BankWidgetConstants.Keys.balancesHidden)
        userDefaults?.synchronize()
        return .result()
    }
}

struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Widget"
    
    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadTimelines(ofKind: "AccountPreviewWidget")
        return .result()
    }
}



// MARK: - Widget Entry
struct AccountPreviewEntry: TimelineEntry {
    let date: Date
    let accounts: [AccountDetail]
    let isBalancesHidden: Bool
    
}

// MARK: - Timeline Provider
struct AccountPreviewWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> AccountPreviewEntry {
        AccountPreviewEntry(
            date: Date(),
            accounts: [AccountDetail.allAccounts[0], AccountDetail.allAccounts[1]],
            isBalancesHidden: false
        )
    }
    
    func snapshot(for configuration: SelectAccountsIntent, in context: Context) async -> AccountPreviewEntry {
        // If no accounts selected, use the first two as placeholders
        let accounts = configuration.accounts.isEmpty
            ? [AccountDetail.allAccounts[0], AccountDetail.allAccounts[1]]
            : configuration.accounts
        let userDefaults = UserDefaults(suiteName: BankWidgetConstants.appGroupSuite)
        let isHidden = userDefaults?.bool(forKey: BankWidgetConstants.Keys.balancesHidden) ?? false
            
        return AccountPreviewEntry(
            date: Date(),
            accounts: accounts,
            isBalancesHidden: isHidden
        )
    }
    
    func timeline(for configuration: SelectAccountsIntent, in context: Context) async -> Timeline<AccountPreviewEntry> {
        let userDefaults = UserDefaults(suiteName: BankWidgetConstants.appGroupSuite)
        let isHidden = userDefaults?.bool(forKey: BankWidgetConstants.Keys.balancesHidden) ?? false
        
        // Create the timeline entry
        let entry = AccountPreviewEntry(
            date: Date(),
            accounts: configuration.accounts,
            isBalancesHidden: isHidden
        )
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        return timeline
    }
}


// MARK: - Widget Configuration
struct AccountPreviewWidget: Widget {
    let kind: String = "AccountPreviewWidget"
    @Environment(\.widgetFamily) var family
    
    var body: some WidgetConfiguration {
        let config = AppIntentConfiguration(
            kind: kind,
            intent: SelectAccountsIntent.self,
            provider: AccountPreviewWidgetProvider()) { entry in
            AccountPreviewWidgetView(entry: entry)
        }
        .configurationDisplayName("Banking Accounts")
        .description(getConfigurationDescription())
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        
        // Apply contentMarginsDisabled only on iOS 17+
        if #available(iOS 17.0, *) {
            return config.contentMarginsDisabled()
        } else {
            return config
        }
    }
    
    func getConfigurationDescription() -> String {
        switch family {
        case .systemSmall:
            "Select an account to display"
        case .systemMedium:
            "Select 2 accounts to display"
        case .systemLarge:
            "Select up to 5 accounts to display"
        case .systemExtraLarge:
            "Select up to 5 accounts to display"
        @unknown default:
            "Select an account to display"
        }
        
    }
}

@main
struct BankWidgetBundle: WidgetBundle {
    var body: some Widget {
        AccountPreviewWidget()
    }
}
