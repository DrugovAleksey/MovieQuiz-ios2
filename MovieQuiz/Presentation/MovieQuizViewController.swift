import UIKit
import Foundation

class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    
    @IBAction func yesButtonClicked(_ sender: Any) {
        
        let givenAnswer = true // эта константа говорит, Да
        
        guard let currentQuestion = currentQuestion else { return }
        
        showAnswerResult(isCorrect: givenAnswer, quizQuestion: currentQuestion)
        print("YES currentQuestion: ", currentQuestion)
        print("Yes нажата \n")
    }
    
    @IBAction func noButtonClicked(_ sender: Any) {
        let givenAnswer = false // эта константа говорит, Нет
        
        guard let currentQuestion = currentQuestion else { return }
        
        showAnswerResult(isCorrect: givenAnswer, quizQuestion: currentQuestion)
        print("NO currentQuestion: ", currentQuestion)
        print("No нажата \n")
    }
    
    // фабрика вопросов. Контроллер будет обращаться к ней за вопросами
    // теперь изменяем свойство questionFactory и делаем его опциональным
    // чтобы пропустить инициализацию этого свойства при создании класса MovieQuizViewController и сделать это позднее во viewDidLoad() (мутно!)
    var questionFactory: QuestionFactoryProtocol?
    
    // вопрос который видит пользователь
    var currentQuestion: QuizQuestion?
    
    // задаем общее количество вопросов для квиза. Оно будет равно 10
    private let questionAmount: Int = 10
    
    // задаем счетчик вопросов
    private var currentQuestionIndex : Int = 0
    
    // переменная счетчика правильных ответов
    var currentAnswer: Int = 0
    
    // переменная счетчика правильных ответов за все игры
    var correctAnswerAll: Double = 0
    
    // переменная счетчика количества сыгрынх игр
    private var currentQuiz: Int = 0
    
    // средняя точность correctAnswerAll / (questions.count * 10)
    private var mediumAnswerAll: Double = 0
    
    private var alertPresenter = AlertPresenter()
//    private let presenter = AlertPresenter()  // Инициализация при создании класса

    var statisticService = StatisticService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticService()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверим, что вопрос не nil
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        // вызывать будем в главной очереди (от греха подальше)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    // MARK: - convert(model: QuizQuestion) -> QuizStepViewModel
    // функци конвертации из структуры вопроса QuizQuestion -> во вью модель экрана QuizStepViewModel
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage()
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionAmount)"
        print ("questionNumber -", questionNumber)
        return QuizStepViewModel(
            image: image,
            question: question,
            questionNumber: String(questionNumber)
        )
    }
    
    //MARK: - show(quiz step: QuizStepViewModel)
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderColor = UIColor(named: "YP Background (iOS)")?.cgColor
    }
    
    // MARK: - showAnswerResult(isCorrect: Bool, quizQuestion: QuizQuestion)
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool, quizQuestion: QuizQuestion) {
        // метод красит рамку
        
        let correctAnswer = quizQuestion.correctAnswer
        
        imageView.layer.masksToBounds = true // даем разрешение на рисование рамки
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 7
        imageView.clipsToBounds = true // Обрезать по рамке!!!!
        
        if isCorrect == correctAnswer {
            currentAnswer += 1
            correctAnswerAll += 1
            imageView.layer.borderColor = UIColor(named: "YP Green (iOS)")?.cgColor
            print("ответ правильный")
        } else {
            imageView.layer.borderColor = UIColor(named: "YP Red (iOS)")?.cgColor
            print("ответ НЕ правильный")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self = self else {return} // разворачиваем слабую ссылку
            self.showNextQuestionOrResults()
            print ("showNextQuestionOrResults запущена")
        }
    }
    
    // MARK: - showNextQuestionOrResults()
    // метод перехода в один из сценариев : либо в следующий вопрос, либо в результаты квиза. Этот метод ничего не получает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount - 1 {
            // Сохраняем результаты текущего раунда
            statisticService.store(correct: currentAnswer, total: questionAmount)
            
            // здесь результаты текущего квиза
            currentQuiz += 1
            mediumAnswerAll = correctAnswerAll / Double(questionAmount * currentQuiz) * 100
            print ("currentAnswer = ",currentAnswer)
            print ("correctAnswerAll = ",correctAnswerAll)
            print ("questions.count = ",questions.count)
            print ("mediumAnswerAll = ",mediumAnswerAll)
            print ("currentQuiz = ", currentQuiz)
            
            // Формируем модель для отображения результатов
            let bestGame = statisticService.bestGame
            let formattedDate = DateFormatter.iso8601.string(from: bestGame?.date ?? Date())
            // вызываем конструктор модели и передаем туда данные из макета
            let quizRusultsViewModel = QuizResultsViewModel(
                title: "Раунд окончен", // Заголовок
                text: "Ваш результат: \(currentAnswer)/\(questionAmount) \n" +
                "Количество сыгранных квизов: \(statisticService.gamesCount) \n" +
                "Рекорд: \(bestGame?.correct ?? 0)/\(bestGame?.total ?? 0) \(formattedDate) \n" +
                "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%", // Сообщение
                buttonText: "Сыграть еще раз?"
            )
            show(quiz: quizRusultsViewModel)
            //alert()
        } else {
            print("Следующий вопрос")
            currentQuestionIndex += 1
            // идем в состояние "вопрос показан"
            // обзаательно self!!!!! из за этого произошла рассинхронизация
            questionFactory?.requestNextQuestion()
//            guard let currentQuestion = currentQuestion else { return }
//            
//            print("nextQuestion: ", currentQuestion)
//            let viewModel = convert(model: currentQuestion)
//            
//            show(quiz: viewModel)
        }
    }
    
    // MARK: - alert()
    // Алерт!
    func alert() {
        let alert = UIAlertController(
            title: "Раунд окончен", // Заголовок
            message: "Ваш результат: \(currentAnswer)/\(questionAmount) \n" +
            "Количество сыгранных квизов: \(currentQuiz) \n" +
            "Средняя точность: \(String(format: "%.2f", mediumAnswerAll))%", // Сообщение
            preferredStyle: .alert // может быть .alert или .actionSheet
        )
        
        // создаем кнопку с действием для алерта. В замыкании пишем, что должно происходить с алертом по нажатию
        let action = UIAlertAction(
            title: "Сыграть еще раз.",
            style: .default) { [weak self] _ in
                print("Кнопка алерта нажата!")
                self?.resetQuiz()
            }
        
        // добавляем в алерт кнопку
        alert.addAction(action)
        
        // показываем всплывающее окно
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - resetQuiz()
    // метод сброса игры
    func resetQuiz() {
        // Сброс игровых счётчиков
        currentAnswer = 0
        currentQuestionIndex = 0
        correctAnswerAll = 0  // Если используете этот счётчик
        mediumAnswerAll = 0   // Если используете этот счётчик

        // Полный сброс статистики
       // statisticService.resetStatistics()

        // Перезапрашиваем первый вопрос через существующую фабрику
        questionFactory?.requestNextQuestion()


        // Сброс визуальных элементов
        imageView.image = nil
        textLabel.text = "Загрузка вопроса..."
        counterLabel.text = "0/10"
        imageView.layer.borderColor = UIColor(named: "YP Background (iOS)")?.cgColor
    }
    
   
    // MARK: - show(quiz result: QuizResultsViewModel)
    // приватный метод для показа результатов раунда квиза
    // принмает вью модель QuizResultsViewModel и ничего не возвращает
    func show(quiz result: QuizResultsViewModel) {
        
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
        }
        let buttonText = model.buttonText
        
        alertPresenter.show(in: self, model: model)
        resetQuiz()
    }
}

// MARK: - Database Operations
// TODO: Add caching
// FIXME: Handle connection errors
