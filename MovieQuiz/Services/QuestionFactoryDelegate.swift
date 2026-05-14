//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Flymetric on 12.04.2026.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(_ question: QuizQuestion)
}
