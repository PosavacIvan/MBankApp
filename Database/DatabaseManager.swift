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
    private let transId = Expression<Int64>("id")
    private let transAmount = Expression<Double>("amount")
    private let transDate = Expression<String>("date")
    private let transDescription = Expression<String>("description")
    private let transCardId = Expression<Int64>("cardId")


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
                t.column(transId, primaryKey: .autoincrement)
                t.column(transAmount)
                t.column(transDate)
                t.column(transDescription)
                t.column(transCardId)
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
    
    func insertTransaction(amount: Double, date: String, description: String, cardId: Int64) throws {
        let insert = transactions.insert(
            transAmount <- amount,
            transDate <- date,
            transDescription <- description,
            transCardId <- cardId
        )
        try db?.run(insert)
    }
    
    func getTransactions(forCardId id: Int64) -> [Transaction] {
        var result: [Transaction] = []

        do {
            let query = transactions.filter(transCardId == id)
            for row in try db!.prepare(query) {
                result.append(Transaction(
                    id: row[transId],
                    amount: row[transAmount],
                    date: row[transDate],
                    description: row[transDescription],
                    cardId: row[transCardId]
                ))
            }
        } catch {
            print("❌ Greška pri dohvaćanju transakcija: \(error)")
        }

        return result
    }

}
