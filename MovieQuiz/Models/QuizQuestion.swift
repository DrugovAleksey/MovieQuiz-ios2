//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Flymetric on 04.04.2026.
//

import UIKit
// Структура вопроса который покажется на экране
struct QuizQuestion {
    // строка с названием фильма совподает с названием на картинке в assets
    let image: String
    // строка с вопросом о рейтинге фильма
    let text: String
    // правильный ответ Да или Нет
    let correctAnswer: Bool
}


