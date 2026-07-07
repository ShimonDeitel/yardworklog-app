import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                Form {
                    Section("Preferences") {
                        Toggle("Show category badges", isOn: $store.categoryFilterEnabled)
                            .accessibilityIdentifier("settingsCategoryToggle")
                    }
                    Section("Subscription") {
                        if purchases.isPro {
                            Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                                .foregroundColor(Theme.accent)
                        } else {
                            Button("Restore Purchases") {
                                Task { await purchases.restore() }
                            }
                            .accessibilityIdentifier("settingsRestoreButton")
                        }
                    }
                    Section("Legal") {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/yardworklog-app/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/yardworklog-app/terms.html")!)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}
