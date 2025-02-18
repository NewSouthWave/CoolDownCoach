//
//  ViewController.swift
//  CoolDownCoach
//
//  Created by Nam on 2/8/25.
//

import UIKit

class TimerViewController: UIViewController {
    // MARK: - << 변수 >>

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
    
    var tempWastedTime = 0
    var totalWastedTime = 0
    var totalWorkoutTime = 0
    var totalBreakTime = 0
    var totalSetsCount = 0
    
    
    var totalWorkoutTimer = Timer()
    var timer = Timer()
    var wastedTimer = Timer()
    var timerBrain = TimerBrain()
    
    var isStart = false     // 앱이 시작되었는지의 여부
    var changeToStop = false    // 타이머 시작 버튼의 스탑버튼 전환 여부
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCircleView()     // 타이머 원형 프로그레스바 세팅
        setComponentsUI()   // 버튼 등 기본 UI 추가 설정
        resetUI()   //  변수 등 초기화
        print(#function)
    }
    // MARK: - 원형 프로그레스바 관련 메서드

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
    
    // MARK: - << 버튼 작동 액션함수 >>
    
    @IBAction func addSec(_ sender: UIButton) {   //  시간 추가 버튼
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

    
    @IBAction func startRecovery(_ sender: UIButton) {  //  타이머 시작(종료) 버튼
        
        if !changeToStop {
            totalBreakTime += targetRecoveryTime
            totalSetsCount += 1
            setTimer()      // 회복시간 타이머 시작
            buttonDisable()
            startRecoveryButton.setTitle("STOP", for: .normal)
            changeToStop = true     // 종료 버튼으로 전환
            self.circleView.setProgressWithAnimation(duration: TimeInterval(targetRecoveryTime + 1), value: 1.0)    // 프로그레스바 시작
            doneWorkeoutButton.isEnabled = false    // 운동 종료 버튼 비활성화
        } else {
            print("타이머 종료")
            timer.invalidate()  // 메인 타이머 비활성화
            wastedTimer.invalidate()    // 낭비시간 타이머 비활성화
            buttonEnable()
            changeToStop = false
            updateUI()  //  각종 시간들 업데이트UI
            
            recoveryTimeTitle.textColor = ColorPallete.basicUIBlue
            recoveryTimeLabel.textColor = ColorPallete.basicUIBlue
            self.circleView.progressLineColor = ColorPallete.basicUIBlue
            wastedTimeTitle.textColor = ColorPallete.basicUIBlue
            wastedTimeLabel.textColor = ColorPallete.basicUIBlue
            self.circleView.setProgress(value: 0.0)
            doneWorkeoutButton.isEnabled = true     // 운동 종료 버튼 활성화

        }
        
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {      // 타이머 시간 초기화(재설정)
        targetRecoveryTime = 0
        recoveryTimeLabel.text = timerBrain.getTimeString(seconds: targetRecoveryTime)
        startRecoveryButton.isEnabled = false
    }
    
    @IBAction func startWorkoutPressed(_ sender: UIButton) {    // 운동 시작 버튼
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
    
    @IBAction func doneWorkoutPressed(_ sender: UIButton) {     // 운동 종료 버튼
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
    
    // MARK: - << 결과 화면 이동 세그웨이 >>

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

// MARK: - << 타이머 >>

extension TimerViewController {
    // MARK: - 전체 운동시간 타이머
    /*
     - 모든 타이머는 기본적으로 타이머가 시작되면 해당 서버시간을 시작시간으로 저장
     - 시간이 1초 지날때마다 해당 서버시간을 종료시간으로 저장
     - 두 시간 사이의 갭을 초로 환산하여 소요시간 계산
     */
    func setTotalWorkoutTimer() {
        workoutStartTime = Date()
        
        totalWorkoutTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTotalWorkoutTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTotalWorkoutTimer() {
        workoutEndTime = Date()
        let interval = Int(workoutEndTime.timeIntervalSince(workoutStartTime))
        workoutTimeLabel.text = timerBrain.getTimeString(seconds: interval)
    }
    // MARK: - 회복시간 타이머

    func setTimer() {
        timerStartTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        timerEndTime = Date()
        let interval = Int(timerEndTime.timeIntervalSince(timerStartTime))
                
        if interval <= targetRecoveryTime {
            print("\(interval) seconds")
            recoveryTimeLabel.text = timerBrain.getTimeString(seconds: targetRecoveryTime - interval)
            
        } else {
            
            recoveryTimeTitle.textColor = ColorPallete.basicUIYellow
            recoveryTimeLabel.textColor = ColorPallete.basicUIYellow
            self.circleView.progressLineColor = ColorPallete.basicUIYellow
            recoveryTimeLabel.text = timerBrain.getTimeString(seconds: 0)

            timer.invalidate()
            setWastedTimer()
            wasteStartTime = Date()
            startRecoveryButton.isEnabled = true
            
        }
    }
    // MARK: - 낭비시간 타이머

    func setWastedTimer() {
//        wasteStartTime = Date()
        wastedTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateWastedTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateWastedTimer() {
        wasteEndTime = Date()
        let interval = Int(wasteEndTime.timeIntervalSince(wasteStartTime))
        if interval > 4 {   // 정규 회복타이머 종료 후 4초 후에 낭비시간 카운트
            tempWastedTime = interval - 4
            wastedTimeTitle.textColor = ColorPallete.basicUIYellow
            wastedTimeLabel.textColor = ColorPallete.basicUIYellow
            wastedTimeLabel.text = timerBrain.getTimeString(seconds: tempWastedTime)
            print("Total Wasted Time: \(tempWastedTime)")
        }
    }
}



// MARK: - << 버튼 활성화&비활성화 함수 >>

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



// MARK: - << UI 세팅 >>

extension TimerViewController {
    // MARK: - 원형 프로그레스바 UI

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
    // MARK: - 라벨, 버튼의 UI 추가 설정

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
    // MARK: - 타이머가 끝나면 UI 업데이트

    func updateUI() {
        startRecoveryButton.isEnabled = false

//        wastedTime = 0
        targetRecoveryTime = 0
        
//        view.backgroundColor = .white
        breakTimeLabel.text = timerBrain.getTimeString(seconds: totalBreakTime + targetRecoveryTime)
        
        totalWastedTime += tempWastedTime
        wastedTimeLabel.text = timerBrain.getTimeString(seconds: totalWastedTime)
        tempWastedTime = 0
        
        setsLabel.text = String(totalSetsCount)
        startRecoveryButton.setTitle("COOL-ing", for: .normal)
        

    }
    // MARK: - 변수 & UI 초기화

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
