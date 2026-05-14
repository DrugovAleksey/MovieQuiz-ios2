//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Flymetric on 11.04.2026.
//

import UIKit

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadFromMock()
    func loadFromFile(in viewController: UIViewController)       // Вносим функцию, т.к. этот протокол контролирует фабрику
    func loadFromNetwork(in viewController: UIViewController)
}
