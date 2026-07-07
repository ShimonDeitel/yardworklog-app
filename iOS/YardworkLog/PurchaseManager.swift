import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let productID = "com.shimondeitel.yardworklog.pro.monthly"

    @Published private(set) var isPro: Bool = false
    @Published private(set) var products: [Product] = []

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await self?.handle(transaction)
                }
            }
        }
        Task { await self.loadProducts() }
        Task { await self.refreshEntitlements() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.productID])
        } catch {
            products = []
        }
    }

    func purchase() async {
        guard let product = products.first else { return }
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                await handle(transaction)
            }
        } catch {
            // purchase failed or cancelled
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var proFound = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productID {
                proFound = true
            }
        }
        isPro = proFound
    }

    private func handle(_ transaction: Transaction) async {
        if transaction.productID == Self.productID {
            isPro = true
        }
        await transaction.finish()
    }
}
