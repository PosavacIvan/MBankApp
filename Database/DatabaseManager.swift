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
    
    let dbPath = "/Users/ivanposavac/Documents/Diplomski/Database/MBankApp.sqlite"

    // Tablica i polja
    private let users = Table("User")
    private let id = Expression<Int64>("id")
    private let ime = Expression<String>("ime")
    private let prezime = Expression<String>("prezime")
    private let adresa = Expression<String>("adresa")
    private let pin = Expression<String>("pin")

    private init() {
        let dbPath = "/Users/ivanposavac/Documents/Diplomski/Database/MBankApp.sqlite"
        print("📂 Baza spremljena ovdje: \(dbPath)")

        do {
            db = try Connection(dbPath)
            createTables()
        } catch {
            print("❌ Greška pri otvaranju baze: \(error)")
        }
    }

    private func createTables() {
        do {
            try db?.run(users.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(ime)
                t.column(prezime)
                t.column(adresa)
                t.column(pin)
            })
        } catch {
            print("❌ Greška pri kreiranju tablica: \(error)")
        }
    }

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
}
