//
//  TimerBrain.swift
//  CoolDownCoach
//
//  Created by Nam on 2/8/25.
//

import UIKit

struct TimerBrain {
    
    func getTimeString (seconds: Int) -> String {
        let sec = seconds % 60
        let mins = (seconds % 3600) / 60
        let hours = seconds / 3600
        if hours > 0 {
            return String(format: "%01d:%02d:%02d", hours, mins, sec)
        } else {
            return String(format: "%02d:%02d", mins, sec)
        }
    }

}
