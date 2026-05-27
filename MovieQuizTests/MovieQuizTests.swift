//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Flymetric on 14.05.2026.
//
import XCTest
import Testing
@testable import MovieQuiz

struct ArithmeticOperations {
    func addition(num1: Int, num2: Int) -> Int {
        return num1 + num2
    }
    
    func subtraction(num1: Int, num2: Int) async -> Int {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 наносекунда
        return num1 - num2
    }
    
    func multiplication(num1: Int, num2: Int, x: @escaping(Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            x(num1 * num2)
        }
    }
}

struct MovieQuizTests {

    @Test func addition() async throws {
        // Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let num2 = 2
        
        // When
        let result = arithmeticOperations.addition(num1: num1, num2: num2)
        
        // Then
        #expect(result == 3)
       // XCTAssertEqual(result, 3)
    }
    
    @Test func subtraction() async {
        // Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 2
        let num2 = 3
        
        // When
        let result = await arithmeticOperations.subtraction(num1: num1, num2: num2)
        
        // Then
        #expect(result == -1)
    }
}

class MovieQuizTestsClass : XCTestCase {
    func testAddition() throws {
        // Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 4
        let num2 = 3
        
        // When
        let result = arithmeticOperations.addition(num1: num1, num2: num2)
        
        // Then
        XCTAssertEqual(result, 7) // сравнение результата с ответом
    }
    
    func testMultiplication() throws {
        // Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 2
        let num2 = 3
        
        // When
        let expectation = expectation(description: "Ожидание функции умножения")
        
        arithmeticOperations.multiplication(num1: num1, num2: num2) { result in
            // Then
            XCTAssertEqual(result, 6)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    func testMultiplication1() throws {
        // Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let num2 = 2
        
        // When
        let expectation = expectation(description: "Addition function expectation")
       
       arithmeticOperations.multiplication(num1: num1, num2: num2) { result in
            // Then
            XCTAssertEqual(result, 2)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
}

class QuizStepViewModelTests: XCTestCase {
    func testConvertModelToViewModel() {
        // Given
        let quizQuestion = questions[0]
        
        // When
        let quizStepViewModel = QuizStepViewModel(model: quizQuestion)
        
        // Then
        XCTAssertTrue(quizStepViewModel.image === quizQuestion.image, "Изображение должно быть тем же объектом")
        XCTAssertEqual(quizStepViewModel.question, quizQuestion.text, "Текст вопроса должен совпадать")
        XCTAssertEqual(quizStepViewModel.questionNumber, "1/10", "Номер вопроса должен быть '1/10'")
    }
}


/*
XCTAssertNotEqual — сравниваем два результата и ожидаем, что они не равны
XCTAssertFalse — проверяем, что результат — это false
XCTAssertTrue — проверяем, что результат — это true
XCTAssertGreaterThan — сравниваем два результата и ожидаем, что первый больше второго
XCTAssertGreaterThanOrEqual — сравниваем два результата и ожидаем, что первый больше или равен второму
XCTAssertLessThan — сравниваем два результата и ожидаем, что первый меньше второго
XCTAssertLessThanOrEqual — сравниваем два результата и ожидаем, что первый меньше или равен второму
XCTAssertNil — проверяем что результат — это nil
XCTAssertNotNil — проверяем что результат — это не nil
XCTAssertNoThrow — проверяем, что в процессе получения результата не произошло ошибки
XCTAssertThrowsError — проверяем, что в процессе получения результата произошла ошибка
*/
