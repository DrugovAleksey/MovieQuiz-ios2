//
//  Errors.swift
//  MovieQuiz
//
//  Created by Flymetric on 03.05.2026.
//
import UIKit

// 1. Создаем перечисление со всеми возможными ошибками и новые в нее добаляем
enum LoadError: Error {
    case fileNotFound
    case invalidURL
    case invalidRequest(String)
    case noData
    case invalidJSON(String)
    case unknown(String)
}

// 2. Создаем структуру со свойством-методом выбора ошибки и что писать в алерте
struct ErrorsHandler {
    // Статический экземпляр презентера алерта
    private static let alertPresenter = AlertPresenter()

    // Глобальный контекст для показа алектов
    static var currentViewController: UIViewController?
    
    // флаг alertActive - нужен для того, чтобы сообщение проговорилось один раз при первой ошибки, а остальные ошибки не озвучивались
    static var alertActive : Bool = false
    
    // функция выведения в алерта готового в главный поток
    // Основной метод: обрабатывает ошибку и показывает алерт
    static func showErrorAlert(_ error: LoadError,
                               questionFactory: QuestionFactoryProtocol) {
        
        guard let viewController = currentViewController else {
            print("⚠️ Нет активного viewController для показа алерта")
            return
        }
        
        // получаем модель алерта для конкретной ошибки
        let model = alertModelError(
            for: error,
            questionFactory: questionFactory,
            viewController: viewController
        )
        
        // Показываем алерт в главном потоке
        DispatchQueue.main.async {
            alertPresenter.alert(in: viewController, model: model)
        }
    }
    // Вспомогательный метод: создаёт AlertModel для ошибки
    static func alertModelError(for error: LoadError,
                                questionFactory: QuestionFactoryProtocol,
                                viewController: UIViewController
    ) -> AlertModel {
        // 3. Задаем переключатель
        switch error {
        case .fileNotFound:
            if alertActive == false {
                QueueSoundManage.shared.playSoundsInSequence(with: ["access", "denied", "alert", "activated"], fileExtension: "wav")
                alertActive = true
            }
            return AlertModel(
                title: "Ошибка!",
                message: "Не найден файл JSON с вопросами! \n" +
                "Запустить МОК-данные из массива" +
                "или запустить данные из Сети?",
                buttonText: "Запустить МОК-данные.",
                buttonText2: "Запустить данные из сети.",
                buttonText3: "Полная отмена!",
                completion: {
                    questionFactory.loadFromMock()
                },
                completion2: {
                    questionFactory.loadFromNetwork(in: viewController)
                },
                completion3: {
                    alertPresenter.censelAllAlerts()
                }
            )
        case .invalidURL:
            
            if alertActive == false {
                QueueSoundManage.shared.playSoundsInSequence(with: ["access", "denied", "alert", "activated"], fileExtension: "wav")
                alertActive = true
            }
            return AlertModel(
                title: "Ошибка!",
                message: "Не правильный адрес URL! \n" +
                "Запустить данные из файла JSON \n" +
                "или МОК-данные из массива?",
                buttonText: "Запустить данные из файла JSON.",
                buttonText2: "Запустить МОК-данные.",
                buttonText3: "Полная отмена!",
                completion: {
                    questionFactory.loadFromFile(in: viewController)
                },
                completion2: {
                    questionFactory.loadFromMock()
                },
                completion3: {
                    alertPresenter.censelAllAlerts()
                }
            )
        case .invalidRequest(let details):
            if alertActive == false {
                QueueSoundManage.shared.playSoundsInSequence(with: ["access", "denied", "alert", "activated"], fileExtension: "wav")
                alertActive = true
            }
            return AlertModel(
                title: "Ошибка!",
                message: "Не правильный запрос! \n" +
                "\(details) \n" +
                "Запустить данные из файла JSON \n" +
                "или МОК-данные из массива?",
                buttonText: "Запустить данные из файла JSON.",
                buttonText2: "Запустить МОК-данные.",
                buttonText3: "Полная отмена!",
                completion: {
                    questionFactory.loadFromFile(in: viewController)
                },
                completion2: {
                    questionFactory.loadFromMock()
                },
                completion3: {
                    alertPresenter.censelAllAlerts()
                }
            )
        case .noData:
            if alertActive == false {
                QueueSoundManage.shared.playSoundsInSequence(with: ["access", "denied", "alert", "activated"], fileExtension: "wav")
                alertActive = true
            }
            return AlertModel(
                title: "Ошибка!",
                message: "Нет Data! \n" +
                "Запустить данные из файла JSON \n" +
                "или МОК-данные из массива?",
                buttonText: "Запустить данные из файла JSON.",
                buttonText2: "Запустить МОК-данные.",
                buttonText3: "Полная отмена!",
                completion: {
                    questionFactory.loadFromFile(in: viewController )
                },
                completion2: {
                    questionFactory.loadFromMock()
                },
                completion3: {
                    alertPresenter.censelAllAlerts()
                }
            )
        case .invalidJSON(let details):
            if alertActive == false {
                QueueSoundManage.shared.playSoundsInSequence(with: ["access", "denied", "alert", "activated"], fileExtension: "wav")
                alertActive = true
            }
            return AlertModel(
                title: "Ошибка!",
                message: "Ошибка парсинга JSON! \n" +
                "\(details) \n" +
                "Запустить данные из файла JSON \n" +
                "или МОК-данные из массива?",
                buttonText: "Запустить данные из файла JSON.",
                buttonText2: "Запустить МОК-данные.",
                buttonText3: "Полная отмена!",
                completion: {
                    questionFactory.loadFromFile(in: viewController )
                },
                completion2: {
                    questionFactory.loadFromMock()
                },
                completion3: {
                    alertPresenter.censelAllAlerts()
                }
            )
        case .unknown(let details):
            if alertActive == false {
                QueueSoundManage.shared.playSoundsInSequence(with: ["access", "denied", "alert", "activated"], fileExtension: "wav")
                alertActive = true
            }
            return AlertModel(
                title: "Ошибка!",
                message: "Полная! Не известная ошибка! \n" +
                "\(details) \n" +
                "Запустить данные из файла JSON \n" +
                "или МОК-данные из массива?",
                buttonText: "Запустить данные из файла JSON.",
                buttonText2: "Запустить МОК-данные.",
                buttonText3: "Полная отмена!",
                completion: {
                    questionFactory.loadFromFile(in: viewController )
                },
                completion2: {
                    questionFactory.loadFromMock()
                },
                completion3: {
                    alertPresenter.censelAllAlerts()
                }
            )
        }
    }
}


