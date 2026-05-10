//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Flymetric on 07.05.2026.
//

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    // метод для сохранения текущего результата игры
    func store(correct count: Int, total amount: Int)
}

