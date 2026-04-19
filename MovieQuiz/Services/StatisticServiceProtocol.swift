//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Flymetric on 19.04.2026.
//
import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double {get} // средняя точность за все игры
    var gamesCount: Int {get}       // результат текущей игры
    var bestGame: GameResult? {get}  // лучшая игра

    // метод для сохранения текущего результата игры
    func store(correct count: Int, total amount: Int)
}
