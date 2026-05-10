//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Flymetric on 05.04.2026.
//

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var buttonText2: String?     // Опциональная вторая кнопка
    var buttonText3: String?     // Опциональная вторая кнопка
    var completion: () -> Void
    var completion2: (() -> Void)? // Опциональный второй обработчик
    var completion3: (() -> Void)? // Опциональный второй обработчик
}

// можно дописать и третью кнопку
