//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Flymetric on 18.05.2026.
//


/* Класс XCUIApplication позволяет:
- запускать и останавливать работу приложения,
- отслеживать и менять статус приложения при прогоне тестов,
- запускать другое приложение на устройстве (если вы знаете его bundleIdentifier),
- управлять авторизацией в приложении для сброса установленного доступа к содержимому и функциям устройства (например, контактов или камеры).
Если мы посмотрим происхождение класса XCUIApplication, то увидим, что он наследуется от класса XCUIElement — наиболее низкоуровневого примитива среди классов, используемых UI-частью фреймворка XCTests — XCUITest.
 */
 
import XCTest
@testable import MovieQuiz // импортируем приложение для тестирования

class MovieQuizUITests: XCTestCase {
    // 1. Эта переменная символизирует приложение которое мы тестируем
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // 2. инициализируем нашу переменную и присваиваем ей значение в настоящем методе
        app = XCUIApplication()
        // 4. Для чистоты тестов приложения будем перед тестом открывать
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошел.
        // то следующие тесты запускаться не будет
        continueAfterFailure = false

        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        // 5. после выполнения теста закрываем приложение
        app.terminate()
        
        // 3. В этом методе мы обнуляем значение нашей переменной
        app = nil
    }

    // XCod сгенерировал простой UI тест. если его запустить
    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    
    // 6. Создаем метот самого тесте
    // этот метод будет хранить код теста
    
    func testScreenCast() throws {
        
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.staticTexts["Да"]/*[[".buttons[\"Да\"].staticTexts[\"Да\"]",".staticTexts[\"Да\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Нет"].tap()
        app.buttons["Да"].tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Нет"]/*[[".buttons[\"Нет\"].staticTexts[\"Нет\"]",".staticTexts[\"Нет\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                
    }
    
    // 7. Создаем метод проверки смены постера при нажатии на кнопку да или нет
    func testYesButton() {
        sleep(93)

        let firstPoster = app.images["Poster"] // находим первоначальный постер

        app.buttons["Yes"].tap() // находим кнопку "да" и нажимаем ее
        sleep(3)

        let secondPoster = app.images["Poster"]
        
        XCTAssertTrue(firstPoster.exists)
        XCTAssertTrue(secondPoster.exists)
        XCTAssertFalse(firstPoster == secondPoster) // проверяем, что постеры разные
        
        // преобразуем изображения постеров в их данные и посчитаем
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        // проверяем совпадают ли данные до байта
       // XCTAssertFalse(firstPosterData == secondPosterData)
        // или так проверить можно
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        // можно проверить меняется ли лейбл с номером вопроса
        // лейблы, как и картинки, кнопки и все остальное можно получить из XCUIApplication
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testBadonButton() {
        sleep(123)

        let firstPoster = app.images["Poster"] // находим первоначальный постер

        app.buttons["Yes"].tap() // находим кнопку "да" и нажимаем ее
        sleep(33)

        let secondPoster = app.images["Poster"]
        
        // преобразуем изображения постеров в их данные и посчитаем
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        // проверяем совпадают ли данные до байта
       // XCTAssertFalse(firstPosterData == secondPosterData)
        // или так проверить можно
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        // можно проверить меняется ли лейбл с номером вопроса
        // лейблы, как и картинки, кнопки и все остальное можно получить из XCUIApplication
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    
    // 8. Тестируем кнопку Нет
    func testNoButton() {
        sleep(123)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()
        sleep(33)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
}
