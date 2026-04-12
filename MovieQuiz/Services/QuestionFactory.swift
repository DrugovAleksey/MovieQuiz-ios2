//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Flymetric on 07.04.2026.
//

class QuestionFactory: QuestionFactoryProtocol {
    
    // Таким образом перетаскиваем в переменную фабрики все мок вопросы
    // дальше будем работать с фабрикой
    private var questionsFromFactory: [QuizQuestion]
    
    weak var delegate: QuestionFactoryDelegate?
    // Мы объявляем функцию requestNextQuestion теперь будет передавать вопрос делегату QuestionFactoryDelegate в функцию didReceiveNextQuestion(question:)
    
    init(delegate: QuestionFactoryDelegate?){
        self.questionsFromFactory = questions // Используем глобальный массив
        self.delegate = delegate
        // Инициализируем questionsFromFactory после создания экземпляра se
    }
    
    
    
    func requestNextQuestion() {
        guard let index = (0..<questionsFromFactory.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }

        let question = questionsFromFactory[index]
        delegate?.didReceiveNextQuestion(question: question)
        //return question
    }
}
