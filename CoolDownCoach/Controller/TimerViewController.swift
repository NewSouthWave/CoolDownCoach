//
//  ViewController.swift
//  CoolDownCoach
//
//  Created by Nam on 2/8/25.
//

import UIKit

class TimerViewController: UIViewController {

    @IBOutlet weak var circleView: CircularProgress!
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var backgroundImgView: UIImageView!
    
    @IBOutlet weak var recoveryTimeTitle: UILabel!
    @IBOutlet weak var wastedTimeTitle: UILabel!
    @IBOutlet weak var workoutTimeTitle: UILabel!
    @IBOutlet weak var breakTimeTitle: UILabel!
    @IBOutlet weak var setsTitle: UILabel!
    
    
    @IBOutlet weak var recoveryTimeLabel: UILabel!
    @IBOutlet weak var wastedTimeLabel: UILabel!
    @IBOutlet weak var workoutTimeLabel: UILabel!
    @IBOutlet weak var breakTimeLabel: UILabel!
    @IBOutlet weak var setsLabel: UILabel!
    
    @IBOutlet weak var add10SecButton: UIButton!
    @IBOutlet weak var add30SecButton: UIButton!
    @IBOutlet weak var add1MinButton: UIButton!
    @IBOutlet weak var startRecoveryButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var startWorkoutButton: UIButton!
    @IBOutlet weak var doneWorkeoutButton: UIButton!
    
    var workoutStartTime = Date()
    var workoutEndTime = Date()
    
    var timerStartTime = Date()
    var timerEndTime = Date()
    
    var wasteStartTime = Date()
    var wasteEndTime = Date()
    
    var targetRecoveryTime = 0
    var globalInterval = 0
    
    var tempWastedTime = 0
    var totalWastedTime = 0
    var totalWorkoutTime = 0
    var totalBreakTime = 0
    var totalSetsCount = 0
    
    var totalWorkoutTimer = Timer()
    var timer = Timer()
    var wastedTimer = Timer()
    var timerBrain = TimerBrain()
    
    var isStart = false
    var changeToStop = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCircleView()
        setComponentsUI()
        resetUI()
        print(#function)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        // MARK: 셋중에 원하시는 걸로 골라서 사용하시면 됩니다.
//        // 70% 진행한 상태로 그려주기 (애니메이션 X) - 위에서 설정했으면 안해도 상관 X
//        //        self.circleView.setProgress(value: 0.7) // 필수 아닙니다.
//        // 10%~70% 까지 10초간 애니메이션 진행
//        //        self.circleView.setProgressWithAnimation(duration: 10, fromValue: 0.1, toVlaue: 0.7)
//        // 0%~70% 까지 10초간 애니메이션 진행
//        //        self.circleView.setProgressWithAnimation(duration: 10, value: 0.7)
//        print(#function)
//
//    }
    
    // MARK: - 버튼 작동

    @IBAction func add10Sec(_ sender: UIButton) {
        startRecoveryButton.isEnabled = true
        switch sender {
        case add10SecButton:
            targetRecoveryTime += 10
        case add30SecButton:
            targetRecoveryTime += 30
        case add1MinButton:
            targetRecoveryTime += 60
        default:
            return
        }
        recoveryTimeLabel.text = timerBrain.getTimeString(seconds: targetRecoveryTime)
        print(targetRecoveryTime)
    }

    
    @IBAction func startRecovery(_ sender: UIButton) {
        
        if !changeToStop {
            totalBreakTime += targetRecoveryTime
            totalSetsCount += 1
            setTimer()
            buttonDisable()
            startRecoveryButton.setTitle("STOP", for: .normal)
            changeToStop = true
            self.circleView.setProgressWithAnimation(duration: TimeInterval(targetRecoveryTime + 1), value: 1.0)
            doneWorkeoutButton.isEnabled = false
        } else {
            print("타이머 종료")
            timer.invalidate()
            wastedTimer.invalidate()
            buttonEnable()
            changeToStop = false
            updateUI()
            
            recoveryTimeTitle.textColor = ColorPallete.basicUIBlue
            recoveryTimeLabel.textColor = ColorPallete.basicUIBlue
            self.circleView.progressLineColor = ColorPallete.basicUIBlue
            wastedTimeTitle.textColor = ColorPallete.basicUIBlue
            wastedTimeLabel.textColor = ColorPallete.basicUIBlue
            self.circleView.setProgress(value: 0.0)
            doneWorkeoutButton.isEnabled = true

        }
        
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        targetRecoveryTime = 0
        recoveryTimeLabel.text = timerBrain.getTimeString(seconds: targetRecoveryTime)
        startRecoveryButton.isEnabled = false
    }
    
    @IBAction func startWorkoutPressed(_ sender: UIButton) {
        if !isStart {
            resetUI()
            setTotalWorkoutTimer()
            buttonEnable()
            startRecoveryButton.isEnabled = false
            isStart = true
            startWorkoutButton.isEnabled = false
            doneWorkeoutButton.isEnabled = true
        }
        
    }
    
    @IBAction func doneWorkoutPressed(_ sender: UIButton) {
//        totalTimerCount -= 1
//        print("토탈타이머: \(totalTimerCount)")

        totalWorkoutTimer.invalidate()
        timer.invalidate()
        wastedTimer.invalidate()
        
        self.circleView.setProgress(value: 0.0)

        
        startWorkoutButton.isEnabled = true
        doneWorkeoutButton.isEnabled = false
        isStart = false
        buttonDisable()
        
        if Int(workoutEndTime.timeIntervalSince(workoutStartTime)) <= 0 {
            totalWorkoutTime = 0
        } else {
            totalWorkoutTime = Int(workoutEndTime.timeIntervalSince(workoutStartTime))
        }
        
        
        print("totalWorkoutTime: \(totalWorkoutTime)"
        )
        self.performSegue(withIdentifier: "goToResult", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResult" {
            let destinationVC = segue.destination as! ResultViewController
            
            destinationVC.resultWorkoutTime = timerBrain.getTimeString(seconds: totalWorkoutTime)
            destinationVC.resultBreakTime = timerBrain.getTimeString(seconds: totalBreakTime)
            destinationVC.resultWastedTime = timerBrain.getTimeString(seconds: totalWastedTime)
            destinationVC.resultSets = String(totalSetsCount)
            
        }
    }
}

// MARK: - Timer

extension TimerViewController {
    func setTotalWorkoutTimer() {
//        totalTimerCount += 1
//        print("토탈타이머: \(totalTimerCount)")
        workoutStartTime = Date()
        
        totalWorkoutTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTotalWorkoutTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTotalWorkoutTimer() {
//        totalWorkoutTime += 1
        workoutEndTime = Date()
        let interval = Int(workoutEndTime.timeIntervalSince(workoutStartTime))
        workoutTimeLabel.text = timerBrain.getTimeString(seconds: interval)
    }
    
    func setTimer() {
        timerStartTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        timerEndTime = Date()
        let interval = Int(timerEndTime.timeIntervalSince(timerStartTime))
        globalInterval = Int(timerEndTime.timeIntervalSince(timerStartTime))
        if interval <= targetRecoveryTime {
            print("\(interval) seconds")
            recoveryTimeLabel.text = timerBrain.getTimeString(seconds: targetRecoveryTime - interval)
            
        } else {
//            recoveryTimeLabel.text = String(targetRecoveryTime)
//            print("타이머 종료")
            
            recoveryTimeTitle.textColor = ColorPallete.basicUIYellow
            recoveryTimeLabel.textColor = ColorPallete.basicUIYellow
            self.circleView.progressLineColor = ColorPallete.basicUIYellow

            timer.invalidate()
            setWastedTimer()
            startRecoveryButton.isEnabled = true
            
        }
    }
    
    func setWastedTimer() {
        wasteStartTime = Date()
        wastedTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateWastedTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateWastedTimer() {
//        wastedTime += 1
        wasteEndTime = Date()
        let interval = Int(wasteEndTime.timeIntervalSince(wasteStartTime))
        if interval > 4 {
            tempWastedTime = interval - 4
            wastedTimeTitle.textColor = ColorPallete.basicUIYellow
            wastedTimeLabel.textColor = ColorPallete.basicUIYellow
            wastedTimeLabel.text = timerBrain.getTimeString(seconds: tempWastedTime)
            print("Total Wasted Time: \(interval)")
        }
    }
}



// MARK: - Button

extension TimerViewController {
    func buttonDisable() {
        add10SecButton.isEnabled = false
        add30SecButton.isEnabled = false
        add1MinButton.isEnabled = false
        startRecoveryButton.isEnabled = false
        clearButton.isEnabled = false
    }
    func buttonEnable() {
        add10SecButton.isEnabled = true
        add30SecButton.isEnabled = true
        add1MinButton.isEnabled = true
        startRecoveryButton.isEnabled = true
        clearButton.isEnabled = true
    }
}



// MARK: - UI setting

extension TimerViewController {
    
    func setCircleView() {
        print(#function)
        //MARK: 스토리보드에서 했던 설정 변경
            //스토리보드 - track color
        self.circleView.trackColor = ColorPallete.basicUIDarkGray
        //스토리보드 - track Line Width
        self.circleView.trackLineWidth = 5.0
        //스토리보드 - progress Line Color
        self.circleView.progressLineColor = ColorPallete.basicUIBlue
        //스토리보드 - progress Line Width
        self.circleView.progressLineWidth = 5.2
        // 배경색을 스토리보드에서 지정 안하셨으면 여기서 해주세요.
        self.circleView.backgroundColor = ColorPallete.basicUIDark
        //MARK: 애니메이션 효과를 사용하실분들은 0 /그냥 표기하실분들은 수치를 입력해주세요(0.0 ~. 1.0)
        // 몇퍼센트를 표시할지 지정합니다. (0.0 ~ 1.0)
        self.circleView.setProgress(value: 0.0)
        
        
        // 모서리 둥글게
        statsView.layer.cornerRadius = 25
//        timerBGView.layer.masksToBounds = true
//        statsView.layer.masksToBounds = true
        
        
        print(#function)
    }
    
    func setComponentsUI() {
        recoveryTimeLabel.textColor = ColorPallete.basicUIBlue
        wastedTimeLabel.textColor = ColorPallete.basicUIBlue
        workoutTimeLabel.textColor = ColorPallete.basicUIGray
        breakTimeLabel.textColor = ColorPallete.basicUIGray
        setsLabel.textColor = ColorPallete.basicUIGray
        
        recoveryTimeTitle.textColor = ColorPallete.basicUIBlue
        wastedTimeTitle.textColor = ColorPallete.basicUIBlue
        workoutTimeTitle.textColor = ColorPallete.basicUIGray
        breakTimeTitle.textColor = ColorPallete.basicUIGray
        setsTitle.textColor = ColorPallete.basicUIGray
        
        add10SecButton.layer.cornerRadius = 25
        add30SecButton.layer.cornerRadius = 25
        add1MinButton.layer.cornerRadius = 25
        startRecoveryButton.layer.cornerRadius = 25
        clearButton.layer.cornerRadius = 25
        startWorkoutButton.layer.cornerRadius = 25
        doneWorkeoutButton.layer.cornerRadius = 25
        
        statsView.backgroundColor = ColorPallete.basicUIDark
        
        
    }
    
    func updateUI() {
        startRecoveryButton.isEnabled = false

//        wastedTime = 0
        targetRecoveryTime = 0
        
//        view.backgroundColor = .white
        breakTimeLabel.text = timerBrain.getTimeString(seconds: totalBreakTime + targetRecoveryTime)
        
        totalWastedTime += tempWastedTime
        wastedTimeLabel.text = timerBrain.getTimeString(seconds: totalWastedTime)

        setsLabel.text = String(totalSetsCount)
        startRecoveryButton.setTitle("Recovery", for: .normal)
    }
    
    func resetUI() {
        timer.invalidate()
        totalWorkoutTimer.invalidate()
        wastedTimer.invalidate()
        
        self.circleView.setProgress(value: 0.0)

        
        buttonDisable()
      
        targetRecoveryTime = 0
        tempWastedTime = 0
        
        totalWastedTime = 0
        totalWorkoutTime = 0
        totalBreakTime = 0
        totalSetsCount = 0
        
        doneWorkeoutButton.isEnabled = false
        recoveryTimeLabel.text = "00:00"
        wastedTimeLabel.text = "00:00"
        workoutTimeLabel.text = "00:00"
        breakTimeLabel.text = "00:00"
        setsLabel.text = "0"
    }
}
