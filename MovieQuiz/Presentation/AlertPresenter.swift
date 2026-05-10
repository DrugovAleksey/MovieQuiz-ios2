//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Flymetric on 02.05.2026.
//
import UIKit

// 1. Создаем сам класс алерта который будет презентовать везде сообщения
final class AlertPresenter {
    
    // массив для запоминания алертов
    private var alertQueue: [AlertModel] = []
    private var isShowingAlert = false
    
    //  функция добавления алерта в массив алертов (копим ошибки)
    func alert(in vc: UIViewController, model: AlertModel) {
        if isShowingAlert {
            alertQueue.append(model)
            return
        }
        
        showAlert(in: vc, model: model)
    }
    
    // 2. Функция создания алерта
    private func showAlert(in vc: UIViewController, model: AlertModel) {
        isShowingAlert = true
        
        // 3. создаем окошко (контроллер) из элементов алерта по структуре
        let alert = UIAlertController(
            title: model.title,     // заголовок
            message: model.message, // описание
            preferredStyle: .alert  // представление либо .alert, либо actionSheet
        )
        
        // 4. задаем кнопки (это ПЕРВАЯ кнопка)
        let action = UIAlertAction(title: model.buttonText, style: .default) {_ in
            self.isShowingAlert = false
            model.completion()
            self.showNextAlert(in: vc)
        }
        alert.addAction(action) // сразу добавим первую кнопку

        // 5. это ВТОРАЯ кнопка (только если есть текс и обработчкик!)
        if let buttonText2 = model.buttonText2,
           let completion2 = model.completion2 {
            let action2 = UIAlertAction(title: model.buttonText2, style: .default) {_ in
                self.isShowingAlert = false
                model.completion2?()
                self.showNextAlert(in: vc)
            }
            alert.addAction(action2) // добавляем вторую кнопку
        }
        
        // 6. это ТРЕТЬЯ кнопка (только если есть текс и обработчкик!)
        if let buttonText3 = model.buttonText3,
           let completion3 = model.completion3 {
            let action2 = UIAlertAction(title: model.buttonText3, style: .default) {_ in
                self.isShowingAlert = false
                model.completion3?()
                self.showNextAlert(in: vc)
            }
            alert.addAction(action2) // добавляем вторую кнопку
        }
        // 7. Выводим это теперь на экран
        vc.present(alert, animated: true, completion: nil)
    }
    
    // функция представления следующего алерта
    private func showNextAlert(in viewController: UIViewController) {
            guard let nextModel = alertQueue.first else { return }
            alertQueue.removeFirst()
            showAlert(in: viewController, model: nextModel)
        }
    
    func censelAllAlerts() {
        alertQueue.removeAll()
    }
}


