//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Flymetric on 07.05.2026.
//
import Foundation

final class StatisticService {
    
}

extension StatisticService: StatisticServiceProtocol {
    
    private enum Keys: String {
        case gamesCount             // счетчик сыгранных игр
        case bestGameCorrect        // количество правильных ответов в лучшей игре
        case bestGameTotal          // общее количество вопросов в лучшей игре
        case bestGameDate           // дата лучшей игры
        case totalCorrectAnswers    // общее количество правильных ответов за все игры
        case totalQuestionsAsked    // общее количество вопросов, заданных за все игры
    }
    
    var gamesCount: Int {
        get {
            UserDefaults.standard.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = UserDefaults.standard.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = UserDefaults.standard.integer(forKey: Keys.bestGameTotal.rawValue)
            
            guard let dateString = UserDefaults.standard.string(forKey: Keys.bestGameDate.rawValue),
                  let dateS = DateFormatter.customFormat.date(from: dateString)
            else {
                return GameResult(correct: 0, total: 0) // используем текущий инициализатор
            }
            return GameResult(
                correct: correct,
                total: total,
                date: dateS
            ) // используем конкретный инициализатор
        }
        set {
            UserDefaults.standard.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            UserDefaults.standard.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            UserDefaults.standard.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalCorrectAnswers: Int {
        get {
            UserDefaults.standard.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var totalQuestionsAsked: Int {
        get {
            UserDefaults.standard.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let correct = totalCorrectAnswers
        let total = totalQuestionsAsked
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total) * 100
    }
    
    // Функция сохранения статистики
    func store(correct count: Int, total amount: Int) {
        // добавляем количество игр, так как игра сыграна
        gamesCount += 1
        // обновляем общие статистики
        totalCorrectAnswers += count // в общую статистику правильных ответов добавляем текущиее количиество правильных ответов
        totalQuestionsAsked += amount // в общую статистику всех ответов добавляем дополнительное количество ответов, которые прошли в последнем раунде
        
        // Проверяем, является ли текущаяя игра лучшей
        let currentBest = bestGame
        if count > currentBest.correct || (count == currentBest.correct && amount < currentBest.total) { bestGame = GameResult(
            correct: count,
            total: amount
            )
        }
    }
    
    // сброс статистики перед началом игры
    func resetStatistics() {
        gamesCount = 0
        bestGame = GameResult(correct: 0, total: 0, date: Date())
        totalCorrectAnswers = 0
        totalQuestionsAsked = 0
    }
}

