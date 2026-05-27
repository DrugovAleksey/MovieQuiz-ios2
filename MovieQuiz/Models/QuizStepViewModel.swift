//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Flymetric on 04.04.2026.
//

import UIKit

// вью модель для состояния "Вопрос показан"
struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

// Расширение для теста QuizStepViewModelTests
extension QuizStepViewModel {
    init(model: QuizQuestion) {
        self.image = model.image
        self.question = model.text
        self.questionNumber = "1/10" // или логика для вычисления номера
    }
}
