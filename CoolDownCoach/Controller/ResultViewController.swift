//
//  ResultViewController.swift
//  CoolDownCoach
//
//  Created by Nam on 2/11/25.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var workoutTimeView: UIView!
    @IBOutlet weak var breakTimeView: UIView!
    @IBOutlet weak var wastedTimeView: UIView!
    @IBOutlet weak var setsView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    var resultWorkoutTime: String?
    var resultBreakTime: String?
    var resultWastedTime: String?
    var resultSets: String?
    
    @IBOutlet weak var resultWorkoutLabel: UILabel!
    @IBOutlet weak var resultBreakTimeLabel: UILabel!
    @IBOutlet weak var resultWastedTimeLabel: UILabel!
    @IBOutlet weak var resultSetsLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        resultWorkoutLabel.text = resultWorkoutTime
        resultBreakTimeLabel.text = resultBreakTime
        resultWastedTimeLabel.text = resultWastedTime
        resultSetsLabel.text = resultSets
        
//        print(workoutTimeView.isHidden)
//        print(breakTimeView.isHidden)
//        print(wastedTimeView.isHidden)
//        print(setsView.isHidden)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    // MARK: - UI 추가설정

    func setUI() {
        workoutTimeView.backgroundColor = ColorPallete.basicUIDark
        breakTimeView.backgroundColor = ColorPallete.basicUIDark
        wastedTimeView.backgroundColor = ColorPallete.basicUIDark
        setsView.backgroundColor = ColorPallete.basicUIDark
        
        workoutTimeView.layer.cornerRadius = 25
        breakTimeView.layer.cornerRadius = 25
        wastedTimeView.layer.cornerRadius = 25
        setsView.layer.cornerRadius = 25
        backButton.layer.cornerRadius = 25
        
        workoutTimeView.clipsToBounds = false
        breakTimeView.clipsToBounds = false
        setsView.clipsToBounds = false
        wastedTimeView.clipsToBounds = false

    }
    
}
