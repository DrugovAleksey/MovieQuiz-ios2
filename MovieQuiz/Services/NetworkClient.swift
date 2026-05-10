//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Flymetric on 04.05.2026.
//
import UIKit

struct NetworkClient {
    
    func fetch(url: URL, handler: @escaping(Result<Data, Error>) -> Void) {
        
        // 1. Создаем адрес
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
          //  ErrorsHandler.showErrorAlert(.invalidURL, questionFactory: self)
            print("Ошибка! Не верный URL: \(url)")
            return
        }
        
        // 2. Создаем запрос
        let request = URLRequest(url: url)
        
        // 3. Создаем сессию
        let session = URLSession.shared
    }
}
