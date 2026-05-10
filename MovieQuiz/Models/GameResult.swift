//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Flymetric on 07.05.2026.
//
import Foundation

struct GameResult {
    var correct: Int
    var total: Int
    var date: String
    
    // Инициализатор для конкретной даты
    init(correct: Int, total: Int, date: Date) {
        self.correct = correct
        self.total = total
        self.date = DateFormatter.customFormat.string(from: date) // используем переданную date
    }
    
    // Инициализатор для текущей даты
    init(correct: Int, total: Int) {
        self.correct = correct
        self.total = total
        self.date = DateFormatter.customFormat.string(from: Date()) // текущая дата
    }
    
    func isBetterThen(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}

// преобразуем формат даты
extension DateFormatter {
    static let customFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm' 'dd.MM.yyyy"
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
