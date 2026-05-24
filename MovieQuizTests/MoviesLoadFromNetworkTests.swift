//
//  MoviesLoadFromNetworkTests.swift
//  MovieQuiz
//
//  Created by Flymetric on 16.05.2026.
//

import XCTest

@testable import MovieQuiz // импортируем приложение для тестирования

class MoviesLoadFromNetworkTests: XCTestCase {
    
    let movieQuizViewController = MovieQuizViewController()
    
    
    func testSuccessLoading() {
        // Given
        let expectation = self.expectation(description: "Загрузка данных из файла")
        var receivedQuestion: QuizQuestion?
        
        // Создаем мок делегата для перехвата результата
        class MockDelegate: QuestionFactoryDelegate {
            var receivedQuestion: QuizQuestion?
            
            func didReceiveNextQuestion(_ question: QuizQuestion) {
                receivedQuestion = question
            }
        }
        
        let mockDelegate = MockDelegate()
        let loader = QuestionFactory(delegate: mockDelegate)
        

        // When
        // функция загрузки фильмов асинхронная , то нужно ожидание
        loader.loadFromFile(in: movieQuizViewController)
        
        // Ожидание результата (с таймаутом достаточным, чтобы прогрузились все данные из сети)
        DispatchQueue.main.asyncAfter(deadline: .now() + 65.0) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 120.0) { error in
            if let error = error {
                XCTFail("Таймаут ожидания \(error)")
            }
            
            // Then
            receivedQuestion = mockDelegate.receivedQuestion
            XCTAssertNotNil(receivedQuestion, "Должен быть получен вопрос после успешной загрузки")
            XCTAssertTrue(receivedQuestion!.image != nil, "Изобразение не должно быть nil")
            XCTAssertFalse(receivedQuestion!.text.isEmpty, "Текст вопроса не должен быть пустым")
        }
    }
    
    func testFailureLoading() throws {
        // Given
        let expectation = self.expectation(description: "Обработака ошибки загрузки из сети")
        var receivedQuestion: QuizQuestion?

        // Мок делегата - нам важно проверить, что вопрос НЕ пришел
        class MockDelegate: QuestionFactoryDelegate {
            var receivedQuestion: QuizQuestion?
            
            func didReceiveNextQuestion(_ question: QuizQuestion) {
                receivedQuestion = question
            }
        }
        
        let mockDelegate = MockDelegate()
        let loader = QuestionFactory(delegate: mockDelegate)
        
        
        // When
        loader.loadFromNetwork(in: movieQuizViewController)
        
        // Ожидание результата (с таймаутом меньшим, чем успеют загрузиться данные, тем самым иметируем недоступность данных)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { error in
            if let error = error {
                XCTFail("Таймаут ожидания \(error)")
            }
            
            // Then
            receivedQuestion = mockDelegate.receivedQuestion
            XCTAssertNil(receivedQuestion, "Должен быть получен nil")
        }
    }
}
