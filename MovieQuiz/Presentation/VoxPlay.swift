//
//  VoxPlay.swift
//  MovieQuiz
//
//  Created by Flymetric on 06.05.2026.
//

import UIKit
import AVFoundation

// Заведем класс обработчик очереди
class QueueSoundManage {
    
    // 1. Создадим переменную для очереди
    static let shared = QueueSoundManage()
    // 2. Создадим плеер
    private var queuePlayer: AVQueuePlayer?
    
    // 3. Создадим функцию playSoundsInSequence (последовательность воспроизведения звуков)
    func playSoundsInSequence(with soundName: [String], fileExtension: String) {
        
        // 4. Создадим пустой массив который будем заполнять звуками
        var items: [AVPlayerItem] = []
        
        // 5. Циклом заполним массив звуками
        for name in soundName {
            
            // 6. Проверим все файлы в папке со звуками
            guard let soundURL = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
                print("Файл \(name).\(fileExtension) не найден")
                continue
            }
            
            // 7. Вытаскиваем в элемент массива готовый звук
            let item = AVPlayerItem(url: soundURL)
            // 8. Собираем массив звуков для одного проигрывания
            items.append(item)
        }
        // 9. Фформируем очередь из последовательности звуковых элементов
        queuePlayer = AVQueuePlayer(items: items)
        // 10. Запускаем проигрыветель очереди
        queuePlayer?.play()
    }
}
