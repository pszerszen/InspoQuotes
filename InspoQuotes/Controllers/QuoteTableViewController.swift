//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit

class QuoteTableViewController: UITableViewController {

    let quoteHandler = QuoteHandler()
    var purchaseService = PurchaseService()

    override func viewDidLoad() {
        super.viewDidLoad()
        purchaseService.delegate = self

        purchaseService.showPremiumQuotesIfPurchased()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quoteHandler.quotesCount(purchased: purchaseService.isPurchased())
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CELL_IDENTIFIER, for: indexPath)

        if let quote = quoteHandler.getQuote(at: indexPath.row) {
            cell.textLabel?.text = quote
            cell.textLabel?.numberOfLines = 0
        } else {
            cell.textLabel?.text = Constants.GET_MORE_QUOTES
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = #colorLiteral(red: 0.2578833997, green: 0.6651150584, blue: 0.7510885596, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    // MARK: - Table view delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = quoteHandler.getQuote(at: indexPath.row) { } else {
            purchaseService.buyPremiumQuotes()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        purchaseService.restoreCompletedTransactions()
    }

}

// MARK: - PurchaseServiceDelegate

extension QuoteTableViewController: PurchaseServiceDelegate {
    func premiumQuotesUnlocked() {
        self.quoteHandler.addPremiumQuotes()
        self.tableView.reloadData()
    }

    func premiumQuotesTransactionRestored() {
        self.navigationItem.setRightBarButton(nil, animated: true)
    }
}
