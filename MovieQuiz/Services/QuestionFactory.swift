//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Flymetric on 07.04.2026.
//

import UIKit

class QuestionFactory: QuestionFactoryProtocol {
    
    
    // Таким образом перетаскиваем в переменную фабрики все мок вопросы
    // дальше будем работать с фабрикой
    private var questionsFromFactory: [QuizQuestion]
    
    // Добавляем алертПрезентер в свойство класса иначе внутри класса глобальный не инициализируется, кроме того, его надо вызывать в главном потоке!
    private var alertPresenter = AlertPresenter()
    
    weak var delegate: QuestionFactoryDelegate?
    // Мы объявляем делегат, функция requestNextQuestion теперь будет передавать вопрос делегату QuestionFactoryDelegate в функцию didReceiveNextQuestion(question:)
    
    init(delegate: QuestionFactoryDelegate?){
        self.questionsFromFactory = questions // Используем глобальный массив
        self.delegate = delegate
        // Инициализируем questionsFromFactory после создания экземпляра se
    }
    
    
    // MARK: - requestNextQuestion() функция формирует следующий вопрос
    func requestNextQuestion() {
        guard let index = (0..<questionsFromFactory.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        
        let question = questionsFromFactory[index]
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    // MARK: - loadFromFile() функция загрузки из файла
    func loadFromFile(in viewController: UIViewController) {
        // 1. Задаем пустой массив вопросов, который будем наполнять из файла
        var quizQuestions = [QuizQuestion]()
        
        // 2. Переменная в которую запихну весь файл json и потом распарсю
        guard let fileURLJSON = Bundle.main.url(forResource: "top250MoviesIMDB", withExtension: "json") else {
            ErrorsHandler.showErrorAlert(.fileNotFound, questionFactory: self)
            print("Файл не найден: 404")
            return
        }
        
        do {
            // 3. Читаем данные (работа с data)
            let dataFromJSON = try Data(contentsOf: fileURLJSON)
            //print("dataFromJSON - > \n",dataFromJSON)
            
            // 4. Парсим данные в переменную top250MoviesIMDB в массив объектов LoadFromJSON (то есть, декодируем в LoadFromJSON)
            let top250MoviesIMDB = try JSONDecoder().decode(LoadFromJSON.self, from: dataFromJSON)
            
            // Теперь переменная top250MoviesIMDB содержит полные данные файла джейсон
            //print ("top250MoviesIMDB \n", top250MoviesIMDB)
            
            // А. Создаем группу
            let dispatchGroup = DispatchGroup()
            
            // 5. Соберем массив вопросов questions из ДАТЫ
            for item in top250MoviesIMDB.items {
                
                // Б. помечаем начало операции
                dispatchGroup.enter()
                
                // 5.1 получим картинку из сети
                // url в виде строки лежит в item.image. Надо получить картинку
                guard let url = URL(string: item.image) else {
                    // Ошибка. не верный URL
                    ErrorsHandler.showErrorAlert(.invalidURL, questionFactory: self)
                    print("Ошибка! Не верный URL: \(item.image)")
                    continue // пропускаем этот элемент и переходим к следующему в цикле
                }
                
                // 5.2 создадим сначала запрос
                let request = URLRequest(url: url)
                
                // 5.3 создаем задачу сразу
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    // В. Гарантированно завершаем операцию
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    // 5.4 проверяем на ошибку любую, она будет неизвестной unknown
                    if let error = error {
                        ErrorsHandler.showErrorAlert(.unknown(error.localizedDescription), questionFactory: self)
                        return
                    }
                    
                    // 5.5 получаем ответ и проверяем его на ошибку
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        ErrorsHandler.showErrorAlert(.invalidRequest(error?.localizedDescription ?? "Опочки!"), questionFactory: self)
                        print("Ошибка запроса -----------")
                        return
                    }
                    print("statusCode ->", httpResponse.statusCode)

                    
                    // 5.6 получаем дату и проверяем на наличие этой самой даты
                    guard let dataFromNetwork = data else {
                        ErrorsHandler.showErrorAlert(.noData, questionFactory: self)
                        print("Даты нет!")
                        return
                    }
                    
                    // 5.7 получаем картику и проверяем на ее наличие
                    guard let imageFromNetwork = UIImage(data: dataFromNetwork) else {
                        ErrorsHandler.showErrorAlert(.invalidRequest("Не удалось получить изобразение из данных"), questionFactory: self)
                        return
                    }
                    
                    
                    // 6. Соберем вопрос
                    let question = QuizQuestion(
                        image: imageFromNetwork,
                        text: "Рейтинг у этого фильма > чем 6?",
                        correctAnswer : Double(item.imDbRating) ?? 0 > 6
                    )
                    // 7. Соберем вопросы quizQuestion для передачи его на конвертацию convert()
                    //print("\n question ->\n",question)
                    quizQuestions.append(question)
                }
                task.resume()
            }
            // 8. Полученные вопросы присваиваем переменной questionsFromFactory
            // Д. выполняется когда все операции завершены
            dispatchGroup.notify(queue: .main){
                self.questionsFromFactory = quizQuestions
                self.requestNextQuestion()
            }
        } catch {
            // 9. Обработка ошибок
            if error is DecodingError {
                ErrorsHandler.showErrorAlert(.invalidJSON(error.localizedDescription), questionFactory: self)
            } else {
                ErrorsHandler.showErrorAlert(.unknown(error.localizedDescription), questionFactory: self)
            }
        }
        //print("questionsFromFactory\n",questionsFromFactory)
    }
    
    
    // MARK: - loadFromNetwork() функция загрузки из сети
    func loadFromNetwork(in viewController: UIViewController) {
        // 0. Задаем пустой массив вопросов, который будем наполнять из файла
        var quizQuestionsNetwork = [QuizQuestion]()
        
        // 1. Зададим адрес сервера окуда будет брать данные
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            ErrorsHandler.showErrorAlert(.invalidURL, questionFactory: self)
            print("\n Ошибочка вышла! Адресочек-то битый!")
            return
        }
        print ("\n URL прошел!")
        
        // 2. Делаем запрос request
        let request = URLRequest(url: url)
        print ("\n Запрос сделан")
        
        // 3. Создаем задачу
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print ("\n Задача запустилась!")
            
            // 4. Обрабатываем ошибки
            if let error = error {
                ErrorsHandler.showErrorAlert(.unknown(error.localizedDescription), questionFactory: self)
                print("\n Ошибка! ", error)
                return
            }
            print("\n Ошибки прошли!")
            
            // 5. Обрабатываем ответ
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                ErrorsHandler.showErrorAlert(.invalidRequest(error?.localizedDescription ?? "Ой как не хорошо получилось!"), questionFactory: self)
                print("\n Ошибка запроса -----------")
                return
            }
            print ("\n Ответ получен", httpResponse.statusCode)
            
            // 6. Получаем дату
            guard let data = data else {
                ErrorsHandler.showErrorAlert(.noData, questionFactory: self)
                print("\n ДАТА не пришла!")
                return
            }
            print("\n data пришла -> \n", data)
            
            // 7. Парсим из даты данные в структуру
            do {
                let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                //print ("\n mostPooularMovies ->", mostPopularMovies)
                //print("mostPopularMovies.items", mostPopularMovies.items)
                
                // СОЗДАЕМ ГРУППУ
                let dispatchGroup = DispatchGroup()
                
                // 8. Для того, чтобы собрать вопросы, нужно добыть к каждому вопросу свою картинку. Это делаем через цикл.
                for mostPopularMovie in mostPopularMovies.items {
                    
                    // ПОМЕЧАЕМ НАЧАЛО ОПЕРАЦИИ
                    dispatchGroup.enter()
                    
                    // 9. Из URL добываем картинку. Картинка оказывается приходит как imageURL: https://m.media-amazon.com/images/M/MV5BMjMxNjY2MDU1OV5BMl5BanBnXkFtZTgwNzY1MTUwNTM@._V1_.jpg
                    // поэтому создаем запрос
                    let request = URLRequest(url: mostPopularMovie.imageURL)
                    
                    // 10. Создаем задачу для вытаскивания картинки из сети
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        // 11. Проверяем на ошибку
                        
                        // ГАРАНТИРОВАННО ЗАВЕРШАЕМ ОПЕРАЦИЮ
                        defer {
                            dispatchGroup.leave()
                        }
                        
                        if let error = error {
                            ErrorsHandler.showErrorAlert(.unknown(error.localizedDescription), questionFactory: self)
                            print( "не могу достать картинку из сети")
                            return
                        }
                        
                        // 12. Обрабатываем ответ response
                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                            ErrorsHandler.showErrorAlert(.invalidRequest(error?.localizedDescription ?? "Опочки!"), questionFactory: self)
                            print("Ошибка запроса по получении картики -----------")
                            return
                        }
                        print("statusCode ->", httpResponse.statusCode)
                        
                        // 13. получаем дату и проверяем на наличие этой самой даты
                        guard let dataFromNetwork = data else {
                            ErrorsHandler.showErrorAlert(.noData, questionFactory: self)
                            print("Даты нет!")
                            return
                        }
                        
                        // 14. вытаскиваем картинку из полученной ДАТЫ
                        guard let imageFromNetwork = UIImage(data: dataFromNetwork) else {
                            ErrorsHandler.showErrorAlert(.invalidRequest("Не удалось получить изобразение из данных"), questionFactory: self)
                            print( "Ошибка! Картинку не добыли!")
                            return
                        }
                        print("Добываем картинку: ", imageFromNetwork)
                        
                        // 15. Собираем вопрос
                        let question = QuizQuestion(
                            image: imageFromNetwork,
                            text: mostPopularMovie.title,
                            correctAnswer: Double(mostPopularMovie.rating) ?? 0 > 7)
                        print("question -> \n",question)
                        
                        // 16. Собираем вопросы quizQuestion для передачи его на конвертацию
                        quizQuestionsNetwork.append(question)
                    }
                    task.resume()
                }
                // ВЫПОЛНЯЕТСЯ КОГДА ВСЕ ОПЕРАЦИИ ЗАВЕРШЕНЫ!
                dispatchGroup.notify(queue: .main){
                    
                    // 17. Теперь присваиваем questionsFromFactory то, что было загружено из сети
                    self.questionsFromFactory = quizQuestionsNetwork
                    self.requestNextQuestion()
                }
            } catch {
                // 18. Обработка ошибок
                if error is DecodingError {
                    ErrorsHandler.showErrorAlert(.invalidJSON(error.localizedDescription), questionFactory: self)
                } else {
                    ErrorsHandler.showErrorAlert(.unknown(error.localizedDescription), questionFactory: self)
                }
            }
        }
        task.resume()
    }
}

