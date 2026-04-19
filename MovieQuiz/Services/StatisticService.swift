//
//  Statistic.swift
//  MovieQuiz
//
//  Created by Flymetric on 19.04.2026.
//
import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard

    var gamesCount: Int {
        get {
            storage.integer(forKey: "gamesCount")
        }
        set {
            storage.set(newValue, forKey: "gamesCount")
        }
    }
    
    
    var totalAccuracy: Double {
        get {
            storage.double(forKey: "totalAccuracy")
        }
        set {
            storage.set(newValue, forKey: "totalAccuracy")
        }
    }
    
    var bestGame: GameResult? {
        get {
            let correct = storage.integer(forKey: "bestGame_correct")
            let total = storage.integer(forKey: "bestGame_total")
            guard let dateString = storage.string(forKey: "bestGame_date") else {
                print("❌ bestGame_date не найден в UserDefaults")
                return nil
            }
            guard let date = DateFormatter.iso8601.date(from: dateString) else {
                print("❌ Не удалось распарсить дату: \(dateString)")
                return nil
            }
            print("✅ Прочитали дату: \(dateString) → \(date)")
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            guard let newValue = newValue else {
                storage.removeObject(forKey: "bestGame_correct")
                storage.removeObject(forKey: "bestGame_total")
                storage.removeObject(forKey: "bestGame_date")
                print("✅ bestGame очищен из UserDefaults")
                return
            }
            storage.set(newValue.correct, forKey: "bestGame_correct")
            storage.set(newValue.total, forKey: "bestGame_total")
            let dateString = DateFormatter.iso8601.string(from: newValue.date)
            storage.set(dateString, forKey: "bestGame_date") // Сохраняем строку
            print("✅ Сохранили дату: \(newValue.date) → \(dateString)")
        }
    }
    
    // метод для полного сброса
    func resetStatistics() {
        // Очищаем все ключи из UserDefaults
        storage.removeObject(forKey: "gamesCount")
        storage.removeObject(forKey: "totalAccuracy")
        storage.removeObject(forKey: "bestGame_correct")
        storage.removeObject(forKey: "bestGame_total")
        storage.removeObject(forKey: "bestGame_date")

        
        // Дополнительно: можно явно установить значения по умолчанию
        gamesCount = 0
        totalAccuracy = 0.0
        bestGame = nil
    }
}

extension StatisticService: StatisticServiceProtocol {
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        if amount > 0 {
            // текущая точность
            let currentAccuracy = Double(count) / Double (amount)
            // полная точность с начала времен будет
            totalAccuracy = (totalAccuracy * Double(gamesCount - 1) + currentAccuracy) / Double(gamesCount)
            
            print ("count = ", count)
            print ("amount = ", amount)

            print ("gamesCount = ", gamesCount)
            print ("currentAccuracy = ", currentAccuracy)
            print ("totalAccuracy = ", totalAccuracy)
        }
        
        let newGame = GameResult(correct: count, total: amount, date: Date())
        
        if let currentBest = bestGame {
            if newGame.correct > currentBest.correct {
                bestGame = newGame
            }
        } else {
            bestGame = newGame
        }
    }
}

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss" // 24-часовой формат
        formatter.locale = Locale(identifier: "ru_RU") // локаль для корректного отображения
        formatter.timeZone = TimeZone.current // Текущий часовой пояс
        print("✅ DateFormatter настроен: \(formatter.dateFormat)")
        return formatter
    }()
}
