//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Flymetric on 19.04.2026.
//
import Foundation

struct GameResult {     // результаты текущей игры
    var correct: Int    // количество правильных ответов
    var total: Int      // количество вопросов квиза текущего
    var date: Date      // дата завершения раунда
    
    // метод сравнения по количеству верных ответов
    func isBetterThan (_ another: GameResult) -> Bool {
        correct > another.correct // сравнивает текущий с новым GameResult
    }
}
