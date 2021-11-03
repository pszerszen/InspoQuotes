//
//  PurchaseService.swift
//  InspoQuotes
//
//  Created by Piotr Szerszeń on 19/10/2021.
//  Copyright © 2021 London App Brewery. All rights reserved.
//

import StoreKit

protocol PurchaseServiceDelegate {
    func premiumQuotesUnlocked()
    func premiumQuotesTransactionRestored()
}

class PurchaseService: NSObject {

    private let productID = "com.perunit.InspoQuotes"

    var delegate: PurchaseServiceDelegate?

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    func buyPremiumQuotes() {
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("User can't make payments")
        }
    }

    func showPremiumQuotesIfPurchased() {
        if isPurchased() {
            showPremiumQuotes()
        }
    }

    private func showPremiumQuotes() {
        UserDefaults.standard.set(true, forKey: productID)
        delegate?.premiumQuotesUnlocked()
    }

    func isPurchased() -> Bool {
        let purchaseStatus = UserDefaults.standard.bool(forKey: productID)
        // let purchaseStatus = true

        if purchaseStatus {
            print("Previously purchased")
        } else {
            print("Never purchased")
        }

        return purchaseStatus
    }

    func restoreCompletedTransactions() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension PurchaseService: SKPaymentTransactionObserver {

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                print("Transaction successful!")
                showPremiumQuotes()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    print("Transaction failed due to error: \(errorDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .restored {
                showPremiumQuotes()
                print("Transaction restored")
                delegate?.premiumQuotesTransactionRestored()
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}
