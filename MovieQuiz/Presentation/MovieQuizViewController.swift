import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(_ question: QuizQuestion) {
        movieQuizPresenter.didReceiveNextQuestion(question)
    }
    
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var noButtonUIButton: UIButton!
    
    @IBOutlet weak var yesButtonUIButton: UIButton!
    
    @IBAction func yesButtonClicked(_ sender: Any) {
        movieQuizPresenter.yesButtonClicked()
    }
    
    @IBAction func noButtonClicked(_ sender: Any) {
        movieQuizPresenter.noButtonClicked()
    }
    
    // вопрос который видит пользователь
    var currentQuestion: QuizQuestion?
    
    // создаем экземпляр класса АлертаПрезентера в который будем выводить все алерты
    private var alertPresenter = AlertPresenter()
    
    var statisticService = StatisticService()
    
    lazy var movieQuizPresenter: MovieQuizPresenter = {
        // проверим, что презентер создается один раз:
        print("MovieQuizPresenter инициализирован")
        let presenter = MovieQuizPresenter()
        presenter.viewController = self
        return presenter
    }()
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async{
            QueueSoundManage.shared.playSoundsInSequence(with: ["voice_on"], fileExtension: "wav")
        }
        
        // ОБЯЗАТЕЛЬНО: устанавливаем ДО вызова loadFromFile иначе алерт не покажется
        ErrorsHandler.currentViewController = self
        
        // Инициализируем сервис по статистике (переменная типа: протокол)
        statisticService = StatisticService()
        
        // Сразу врубаем индикатор активности загрузки
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        // СОЗДАЕМ ФАБРИКУ!!!
        let questionFactory = QuestionFactory(delegate: self) // инициализация фабрики
        
        // Инициализируем презентер и передаем ему фабрику
        movieQuizPresenter = MovieQuizPresenter()
        movieQuizPresenter.viewController = self
        movieQuizPresenter.questionFactory = questionFactory
        // Диагностика: проверяем, что фабрика создана
        print("✅ Фабрика создана: \(questionFactory != nil ? "Да" : "Нет")")
        
        // Ниже источники данных. Выбираем один остальные коментируем.
        //questionFactory.requestNextQuestion()  // Источник данных - МОК!
        //questionFactory.loadFromFile(in: self) // Источник данных - Файл!
        questionFactory.loadFromNetwork(in: self) // Источник данных - Сеть!
    }
    
    
    //MARK: - show(quiz: QuizStepViewModel)
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func showQuiz(quiz: QuizStepViewModel) {
        
        imageView.image = quiz.image
        textLabel.text = quiz.question
        counterLabel.text = quiz.questionNumber
        
        // Разблокируем кнопки
        noButtonUIButton.isEnabled = true
        yesButtonUIButton.isEnabled = true
        
        // Важно! При первой загрузке подгружаются эти параметры рамки
        imageView.layer.masksToBounds = true // даем разрешение на рисование рамки
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 7
        imageView.layer.borderColor = UIColor(named: "YP Background (iOS)")?.cgColor
        imageView.clipsToBounds = true // Обрезать по рамке!!!!
    }
    
    
    // MARK: - showAnswerResult(isCorrect: Bool, quizQuestion: QuizQuestion)
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    func showAnswerResult(isCorrect: Bool, quizQuestion: QuizQuestion) {
        // метод красит рамку
        
        let correctAnswer = quizQuestion.correctAnswer
        
        imageView.layer.masksToBounds = true // даем разрешение на рисование рамки
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 7
        imageView.clipsToBounds = true // Обрезать по рамке!!!!
        
        if isCorrect == correctAnswer {
            //currentAnswer += 1
            movieQuizPresenter.gameResult.correct += 1
            movieQuizPresenter.gameResult.total += 1
            imageView.layer.borderColor = UIColor(named: "YP Green (iOS)")?.cgColor
            print("ответ правильный")
        } else {
            movieQuizPresenter.gameResult.total += 1
            imageView.layer.borderColor = UIColor(named: "YP Red (iOS)")?.cgColor
            print("ответ НЕ правильный")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self = self else {return} // разворачиваем слабую ссылку
            movieQuizPresenter.showNextQuestionOrResults()
        }
    }
    
    
    // MARK: - showAlert()
    // приватный метод для показа результатов раунда квиза
    // принмает вью модель QuizResultsViewModel и ничего не возвращает
    func showAlert() {
        
        QueueSoundManage.shared.playSoundsInSequence(with: ["warning", "alert1", "activated1"], fileExtension: "wav")
        
        
        let model = AlertModel(
            title: "Раунд окончен", // Заголовок
            message: "Ваш результат: \(movieQuizPresenter.gameResult.correct)/\(movieQuizPresenter.gameResult.total)\n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount) \n" +
            "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date) \n" +
            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%", // Сообщение
            buttonText: "Сыграть еще раз.",
            buttonText2: "Сброс статистики.",
            completion: {
                print("Кнопка Сыграть еще раз нажата!")
                self.movieQuizPresenter.resetQuiz()
                
                QueueSoundManage.shared.playSoundsInSequence(with: ["accepted"], fileExtension: "wav")
            },
            completion2: { [self] in
                print("Кнопка СБРОСА нажата!")
                self.movieQuizPresenter.resetStatistic()
                
                QueueSoundManage.shared.playSoundsInSequence(with: ["accepted"], fileExtension: "wav")
            }
        )
        alertPresenter.alert(in: self, model: model)
    }
}

// MARK: - Database Operations
// TODO: Add caching
// FIXME: Handle connection errors
