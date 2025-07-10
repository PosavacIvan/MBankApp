//
//  DatabaseManager.swift
//  MBankApp
//
//  Created by Ivan Posavac on 06.05.2025..
//

import SQLite
import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    // MARK: - Baza put
    let dbPath: String = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = urls[0]
        return documentsDirectory.appendingPathComponent("MBankApp.sqlite").path
    }()

    // MARK: - Tablice i polja
    private let users = Table("User")
    private let id = Expression<Int64>("id")
    private let ime = Expression<String>("ime")
    private let prezime = Expression<String>("prezime")
    private let adresa = Expression<String>("adresa")
    private let pin = Expression<String>("pin")

    // Polja za kartice
    private let cards = Table("Cards")
    private let name = Expression<String>("name")
    private let iban = Expression<String>("iban")
    private let balance = Expression<Double>("balance")
    private let userId = Expression<Int64>("userId")
    private let color = Expression<String>("color")
    
    private let transactions = Table("Transactions")
    private let transactionId = Expression<Int64>("id")
    private let transactionTitle = Expression<String>("title")
    private let transactionAmount = Expression<Double>("amount")
    private let transactionDate = Expression<String>("date")
    private let transactionCardIban = Expression<String>("cardIban")

    // MARK: - Init
    private init() {
        print("📂 Baza spremljena ovdje: \(dbPath)")

        do {
            db = try Connection(dbPath)
            createTables()
        } catch {
            print("❌ Greška pri otvaranju baze: \(error)")
        }
    }

    // MARK: - Tablice
    private func createTables() {
        do {
            try db?.run(users.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(ime)
                t.column(prezime)
                t.column(adresa)
                t.column(pin)
            })

            try db?.run(cards.create(ifNotExists: true) { t in
                t.column(name)
                t.column(iban, unique: true)
                t.column(balance)
                t.column(userId)
                t.column(color)
            })
            
            try db?.run(transactions.create(ifNotExists: true) { t in
                t.column(transactionId, primaryKey: .autoincrement)
                t.column(transactionTitle)
                t.column(transactionAmount)
                t.column(transactionDate)
                t.column(transactionCardIban)
            })

        } catch {
            print("❌ Greška pri kreiranju tablica: \(error)")
        }
    }

    // MARK: - Korisnici
    func insertUser(_ user: User) throws {
        let insert = users.insert(
            ime <- user.ime,
            prezime <- user.prezime,
            adresa <- user.adresa,
            pin <- user.pin
        )
        try db?.run(insert)
    }

    func fetchUser() throws -> User? {
        if let row = try db?.pluck(users) {
            return User(
                id: row[id],
                ime: row[ime],
                prezime: row[prezime],
                adresa: row[adresa],
                pin: row[pin]
            )
        }
        return nil
    }

    func deleteAllUsers() throws {
        try db?.run(users.delete())
    }

    func login(with pinInput: String) -> User? {
        do {
            let query = users.filter(pin == pinInput)
            if let row = try db?.pluck(query) {
                return User(
                    id: row[id],
                    ime: row[ime],
                    prezime: row[prezime],
                    adresa: row[adresa],
                    pin: row[pin]
                )
            }
        } catch {
            print("❌ Greška prilikom prijave: \(error)")
        }
        return nil
    }
    
    // MARK: - Transakcije
    func addTransaction(_ transaction: Transaction) {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: transaction.date)

        let insert = transactions.insert(
            transactionTitle <- transaction.title,
            transactionAmount <- transaction.amount,
            transactionDate <- dateString,
            transactionCardIban <- transaction.cardIban
        )

        do {
            try db?.run(insert)
        } catch {
            print("❌ Greška pri dodavanju transakcije: \(error)")
        }
    }
    
    func getTransactions(forIban iban: String) -> [Transaction] {
        var list: [Transaction] = []
        let formatter = ISO8601DateFormatter()

        do {
            let query = transactions.filter(transactionCardIban == iban)
            for row in try db!.prepare(query) {
                let date = formatter.date(from: row[transactionDate]) ?? Date()
                let tx = Transaction(
                    id: row[transactionId],
                    title: row[transactionTitle],
                    amount: row[transactionAmount],
                    date: date,
                    cardIban: row[transactionCardIban]
                )
                list.append(tx)
            }
        } catch {
            print("❌ Greška pri dohvaćanju transakcija: \(error)")
        }

        return list
    }

    // MARK: - Kartice
    func insertCard(_ card: BankCard) throws {
        guard let currentUserId = getCurrentUserId() else { return }

        let insert = cards.insert(
            name <- card.name,
            iban <- card.iban,
            balance <- card.balance,
            userId <- currentUserId,
            color <- card.color
        )
        try db?.run(insert)
    }

    func getUserCards() -> [BankCard] {
        var cardList: [BankCard] = []

        guard let currentUserId = getCurrentUserId(),
              let db = db else { return [] }

        do {
            let query = cards.filter(userId == currentUserId)
            for card in try db.prepare(query) {
                let bankCard = BankCard(
                    name: card[name],
                    iban: card[iban],
                    balance: card[balance],
                    color: card[color]
                )
                cardList.append(bankCard)
            }
        } catch {
            print("❌ Greška pri dohvaćanju kartica: \(error)")
        }

        return cardList
    }

    private func getCurrentUserId() -> Int64? {
        return UserDefaults.standard.value(forKey: "loggedInUserId") as? Int64
    }
    
    func insertTransaction(title: String, amount: Double, date: String, cardIban: String) throws {
        let insert = transactions.insert(
            transactionTitle <- title,
            transactionAmount <- amount,
            transactionDate <- date,
            transactionCardIban <- cardIban
        )
        try db?.run(insert)
    }

    func getTransactions(forCardIban iban: String) -> [Transaction] {
        var result: [Transaction] = []

        do {
            let query = transactions.filter(transactionCardIban == iban)
            for row in try db!.prepare(query) {
                let parsedDate = ISO8601DateFormatter().date(from: row[transactionDate]) ?? Date()
                result.append(Transaction(
                    id: row[transactionId],
                    title: row[transactionTitle],
                    amount: row[transactionAmount],
                    date: parsedDate,
                    cardIban: row[transactionCardIban]
                ))
            }
        } catch {
            print("❌ Greška pri dohvaćanju transakcija: \(error)")
        }

        return result
    }
    
    func updateUserPin(newPin: String) {
        guard let userId = getCurrentUserId() else { return }

        let userToUpdate = users.filter(id == userId)
        do {
            try db?.run(userToUpdate.update(pin <- newPin))
            print("✅ PIN ažuriran")
        } catch {
            print("❌ Greška pri ažuriranju PIN-a: \(error)")
        }
    }
    
    // MARK: - Brisanje kartice i transakcija
    func deleteCard(withIban ibanToDelete: String) {
        let cardQuery = cards.filter(iban == ibanToDelete)
        let txQuery = transactions.filter(transactionCardIban == ibanToDelete)

        do {
            try db?.run(txQuery.delete())
            try db?.run(cardQuery.delete())
            print("✅ Kartica i sve povezane transakcije obrisane.")
        } catch {
            print("❌ Greška pri brisanju kartice i/ili transakcija: \(error)")
        }
    }
    
    func updateBalance(for iban: String, newBalance: Double) {
        let cardToUpdate = cards.filter(self.iban == iban)
        do {
            try db?.run(cardToUpdate.update(balance <- newBalance))
            print("✅ Ažuriran saldo kartice \(iban)")
        } catch {
            print("❌ Greška pri ažuriranju salda: \(error)")
        }
    }

}

