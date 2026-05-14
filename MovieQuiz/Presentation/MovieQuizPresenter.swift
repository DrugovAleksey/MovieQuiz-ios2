//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Flymetric on 04.05.2026.
//
import Foundation

class MovieQuizPresenter: QuestionFactoryDelegate {
    
    
    // задаем общее количество вопросов для квиза. Оно будет равно 10
    let questionAmount: Int = 10
    
    // задаем счетчик вопросов
    var currentQuestionIndex : Int = 0
    
    // создаем экземпляр структуры ГеймРезульт в воторый будем вносить текущие изменения по ходу игры
    var gameResult = GameResult(correct: 0, total: 0, date: Date())
    
    // Слабая ссылка на контроллер (устраняет циклическую зависимость)
    weak var viewController: MovieQuizViewController?
    
    // создаем экземпляр класса статистики
    var statisticService = StatisticService()
    
    // фабрика вопросов. Контроллер будет обращаться к ней за вопросами
    var questionFactory: QuestionFactoryProtocol?
    
    // MARK: - yesButtonClicked() Кнопка Да - перенесли бизнес-логику
    func yesButtonClicked() {
        let givenAnswer = true // эта константа говорит, Да
        
        guard let viewController = viewController else {
            print("Караул! вьюконтроллер не поднялся!")
            return
        }
        
        guard let currentQuestion = viewController.currentQuestion else { return }
        
        viewController.showAnswerResult(isCorrect: givenAnswer, quizQuestion: currentQuestion)
        
        // блокируем ОБЕ кнопки, чтобы ИХ нельзя было нажать несколько раз в любом порядке
        viewController.yesButtonUIButton.isEnabled = false
        viewController.noButtonUIButton.isEnabled = false
        
        QueueSoundManage.shared.playSoundsInSequence(with: ["accepted"], fileExtension: "wav")
    }
    
    // MARK: - noButtonClicked() Кнопка Нет - перенесли бизнес-логику
    func noButtonClicked() {
        let givenAnswer = false // эта константа говорит, Нет
        
        guard let viewController = viewController else {
            print("Караул! вьюконтроллер не поднялся!")
            return
        }
        
        guard let currentQuestion = viewController.currentQuestion else { return }
        
        viewController.showAnswerResult(isCorrect: givenAnswer, quizQuestion: currentQuestion)
        
        // блокируем ОБЕ кнопки, чтобы ИХ нельзя было нажать несколько раз в любом порядке
        viewController.noButtonUIButton.isEnabled = false
        viewController.yesButtonUIButton.isEnabled = false

        QueueSoundManage.shared.playSoundsInSequence(with: ["accepted"], fileExtension: "wav")
    }
    
    
    
    // MARK: - convert(model: QuizQuestion) -> QuizStepViewModel
    // функци конвертации из структуры вопроса QuizQuestion -> во вью модель экрана QuizStepViewModel
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = model.image
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionAmount)"
        print ("questionNumber -", questionNumber)
        return QuizStepViewModel(
            image: image,
            question: question,
            questionNumber: String(questionNumber)
        )
    }
    
    
    // MARK: - showNextQuestionOrResults()
    // метод перехода в один из сценариев : либо в следующий вопрос, либо в результаты квиза. Этот метод ничего не получает и ничего не возвращает
    func showNextQuestionOrResults() {
                
        if currentQuestionIndex == questionAmount - 1 {
            // здесь результаты квиза
            
            statisticService.store(correct: gameResult.correct, total: gameResult.total)
            
            guard let viewController = viewController else { return }
            
            // средняя точность правильных ответов
            var totalAccuracy = statisticService.totalAccuracy
            
            
            viewController.showAlert()
           
        } else {
            print("Следующий вопрос")
            currentQuestionIndex += 1
            
            // идем в состояние "вопрос показан"
            // обзаательно self!!!!! из за этого произошла рассинхронизация. Теперь уже не обязательно!
            questionFactory?.requestNextQuestion()
        }
    }
    
    
    // MARK: - QuestionFactoryDelegate
    // эта функция принимает question (вопрос) и выводит его на экран
    func didReceiveNextQuestion(_ question: QuizQuestion) {
        
        guard let viewController = viewController else { return }
        
        viewController.currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async {
            viewController.showQuiz(quiz: viewModel)
            viewController.activityIndicatorView.stopAnimating()
            viewController.activityIndicatorView.isHidden = true
        }
    }
    
    
    
    // MARK: - resetQuiz()
    // метод сброса игры
    func resetQuiz() {
        // сбрасываем на ноль текущий счетчик уже заданных вопросов
        currentQuestionIndex = 0
        
        // сбрасываем gameResult
        gameResult = GameResult(correct: 0, total: 0, date: Date())
        
        // Запрашиваем первый вопрос из уже загруженных вопросов
        questionFactory?.requestNextQuestion()
    }
    
    
    // MARK: - resetStatistic (полный сброс статистики)
    func resetStatistic() {
        // сбрасываем на ноль текущий счетчик показанных вопросов
        currentQuestionIndex = 0
        
        // сбрасываем текущий результат игры gameResult
        gameResult = GameResult(correct: 0, total: 0, date: Date())
        
        // очищаем статистику через сервис
        statisticService.resetStatistics()
        
        print ("✅ Статистика успешно сброшена!")

        // для того, чтобы все потереть нужно сначала выгрузить все из памяти, а потом все прогнать через цикл с обнулением
        // func dictionaryRepresentation() -> [String : Any]
        
        // получаем словарь всех значений
        let defaults = UserDefaults.standard
        
        let dictionary = defaults.dictionaryRepresentation()
        
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        
        // принудительно сохраняем изменения в UserDefaults
        do {
            try defaults.synchronize()
            print("✅ Статистика успешно сброшена и синхронизирована!")
        } catch {
            print("❌ Ошибка при синхронизации UserDefaults: \(error)")
        }
        
        for (key, value) in dictionary {
            print("\(key) - \(value)")
        }
        
        // Запрашиваем первый вопрос из уже загруженных вопросов
        questionFactory?.requestNextQuestion()
    }
}


