import UIKit
//import AVFAudio
import Foundation

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var noButtonUIButton: UIButton!
    
    @IBOutlet weak var yesButtonUIButton: UIButton!
    
    @IBAction func yesButtonClicked(_ sender: Any) {
        
        let givenAnswer = true // эта константа говорит, Да
        
        guard let currentQuestion = currentQuestion else { return }
        
        showAnswerResult(isCorrect: givenAnswer, quizQuestion: currentQuestion)
        print("YES currentQuestion: ", currentQuestion)
        print("Yes нажата \n")
        
        yesButtonUIButton.isEnabled = false
        
        QueueSoundManage.shared.playSoundsInSequence(with: ["accepted"], fileExtension: "wav")
    }
    
    
    @IBAction func noButtonClicked(_ sender: Any) {
        let givenAnswer = false // эта константа говорит, Нет
        
        guard let currentQuestion = currentQuestion else { return }
        
        showAnswerResult(isCorrect: givenAnswer, quizQuestion: currentQuestion)
        print("NO currentQuestion: ", currentQuestion)
        print("No нажата \n")
        
        noButtonUIButton.isEnabled = false
        
        QueueSoundManage.shared.playSoundsInSequence(with: ["accepted"], fileExtension: "wav")
        
        // блокируем кнопку, чтобы ее нельзя было нажать несколько раз
        
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
    
    // создаем экземпляр класса АлертаПрезентера в который будем выводить все алерты
    private var alertPresenter = AlertPresenter()
    
    // создаем экземпляр структуры ГеймРезульт в воторый будем вносить текущие изменения по ходу игры
    private var gameResult = GameResult(correct: 0, total: 0, date: Date())
    
    private var statisticService = StatisticService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ОБЯЗАТЕЛЬНО: устанавливаем ДО вызова loadFromFile иначе алерт не покажется
        ErrorsHandler.currentViewController = self
        
        // Инициализируем сервис по статистике (переменная типа: протокол)
        statisticService = StatisticService()
       
        // Сразу врубаем индикатор активности загрузки
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        questionFactory = QuestionFactory(delegate: self) // инициализация фабрики
        
        // Ниже источники данных. Выбираем один остальные коментируем.
        //questionFactory?.requestNextQuestion()  // Источник данных - МОК!
        //questionFactory?.loadFromFile(in: self) // Источник данных - Файл!
        questionFactory?.loadFromNetwork(in: self) // Источник данных - Сеть!
        
        activityIndicatorView.stopAnimating()
    }
    
    // MARK: - QuestionFactoryDelegate
    // эта функция принимает question (вопрос) и выводит его на экран
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
    
    func didLoadFromFile() {
        print("didLoadFromFile() запустилась в MovieQuizViewController. Что она здесь может выполнять!")
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
    
    //MARK: - show(quiz step: QuizStepViewModel)
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
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
    private func showAnswerResult(isCorrect: Bool, quizQuestion: QuizQuestion) {
        // метод красит рамку
        
        let correctAnswer = quizQuestion.correctAnswer
        
        imageView.layer.masksToBounds = true // даем разрешение на рисование рамки
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 7
        imageView.clipsToBounds = true // Обрезать по рамке!!!!
        
        if isCorrect == correctAnswer {
            //currentAnswer += 1
            gameResult.correct += 1
            gameResult.total += 1
            imageView.layer.borderColor = UIColor(named: "YP Green (iOS)")?.cgColor
            print("ответ правильный")
        } else {
            gameResult.total += 1
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
            // здесь результаты квиза
            
            statisticService.store(correct: gameResult.correct, total: gameResult.total)
            
            
            
            // средняя точность правильных ответов
            var totalAccuracy = statisticService.totalAccuracy
            //mediumAnswerAll = correctAnswerAll / Double(questionAmount * currentQuiz) * 100
           // print ("currentAnswer = ",currentAnswer)
         //   print ("correctAnswerAll = ",correctAnswerAll)
            print ("questions.count = ",questions.count)
          //  print ("mediumAnswerAll = ",mediumAnswerAll)
           // print ("currentQuiz = ", currentQuiz)
            
            print ("gameCount = ",statisticService.gamesCount)
            print ("bestGame = ",statisticService.bestGame)
//            print ("bestGameTotal = ",statisticService.total)
//            print ("bestGameDate = ",statisticService.bestGameDate)
            print ("totalCorrectAnswers = ",statisticService.totalCorrectAnswers)
            print ("totalQuestionsAsked = ",statisticService.totalQuestionsAsked)
            print ("totalAccuracy = ",statisticService.totalAccuracy)
            let bestGameTotal = statisticService.bestGame.isBetterThen(gameResult)
            print ("bestGameTotal = ", bestGameTotal)
            
            let bestGameDate = statisticService.bestGame.date
            print ("bestGameDate = ", bestGameDate)
            
            showAlert()
           
        } else {
            print("Следующий вопрос")
            currentQuestionIndex += 1
            
            // идем в состояние "вопрос показан"
            // обзаательно self!!!!! из за этого произошла рассинхронизация
            self.questionFactory?.requestNextQuestion()

        }
    }
    
    // MARK: - showAlert()
    // приватный метод для показа результатов раунда квиза
    // принмает вью модель QuizResultsViewModel и ничего не возвращает
    private func showAlert() {
        
        QueueSoundManage.shared.playSoundsInSequence(with: ["alert", "activated"], fileExtension: "wav")
        
        print ("\n При вызове финишного Алерта")
        print("gameResult.correct =",gameResult.correct,
              "gameResult.total =", gameResult.total,
              "gameResult.date =", gameResult.date)
        
        print("gameResult.isBetterThen(gameResult) =", gameResult.isBetterThen(gameResult))
        
        print("bestGame = ", statisticService.bestGame)
        let bestGameTotal = statisticService.bestGame.isBetterThen(gameResult)
        print ("bestGameTotal = ", bestGameTotal)
        let bestGameDate = statisticService.bestGame.date
        print ("bestGameDate = ", bestGameDate)

        print("currentQuestionIndex =", currentQuestionIndex)
        print("questionAmount =", questionAmount)
        print("questions.count =", questions.count)
        print("gameCount =", statisticService.gamesCount)

        print ("totalCorrectAnswers = ",statisticService.totalCorrectAnswers)
        print ("totalQuestionsAsked = ",statisticService.totalQuestionsAsked)
        print ("totalAccuracy = ",statisticService.totalAccuracy)
        
        let model = AlertModel(
            title: "Раунд окончен", // Заголовок
            message: "Ваш результат: \(gameResult.correct)/\(gameResult.total)\n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount) \n" +
            "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date) \n" +
            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%", // Сообщение
            buttonText: "Сыграть еще раз.",
            buttonText2: "Сброс статистики.",
            completion: {
                print("Кнопка Сыграть еще раз нажата!")
                self.resetQuiz()
                
                QueueSoundManage.shared.playSoundsInSequence(with: ["accepted"], fileExtension: "wav")
            },
            completion2: { [self] in
                print("Кнопка СБРОСА нажата!")
                resetStatistic()
                
                QueueSoundManage.shared.playSoundsInSequence(with: ["accepted"], fileExtension: "wav")
            }
        )
        alertPresenter.alert(in: self, model: model)
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
        
        print ("\n После нажатия кнопки resetStatistic")
        print("gameResult.correct =",gameResult.correct,
              "gameResult.total =", gameResult.total,
              "gameResult.date =", gameResult.date)
        
        print("gameResult.isBetterThen(gameResult) =", gameResult.isBetterThen(gameResult))
        
        print("bestGame = ", statisticService.bestGame)
        let bestGameTotal = statisticService.bestGame.isBetterThen(gameResult)
        print ("bestGameTotal = ", bestGameTotal)
        let bestGameDate = statisticService.bestGame.date
        print ("bestGameDate = ", bestGameDate)

        print("currentQuestionIndex =", currentQuestionIndex)
        print("questionAmount =", questionAmount)
        print("questions.count =", questions.count)
        print("gameCount =", statisticService.gamesCount)

        print ("totalCorrectAnswers = ",statisticService.totalCorrectAnswers)
        print ("totalQuestionsAsked = ",statisticService.totalQuestionsAsked)
        print ("totalAccuracy = ",statisticService.totalAccuracy)

        
        // Запрашиваем первый вопрос из уже загруженных вопросов
        questionFactory?.requestNextQuestion()
    }
}

// MARK: - Database Operations
// TODO: Add caching
// FIXME: Handle connection errors
