//
//  CircularProgressBar.swift
//  CoolDownCoach
//
//  Created by Nam on 2/8/25.
//

import UIKit

extension UIBezierPath { // 타원의 경우 대비

    convenience init(ovalInRect rect: CGRect, startAngle: CGFloat, clockwise: Bool) {
        self.init()
        // Create a circle at the origin with diameter 1.
        addArc(withCenter: .zero, radius: 0.5, startAngle: startAngle, endAngle: startAngle + 2 * CGFloat(Double.pi), clockwise: clockwise)
        close()

        // Construct a transform that moves the circle to inscribe `rect`.
        var transform = CGAffineTransformIdentity
        // This part moves the center of the circle to the center of `rect`.
        transform = CGAffineTransformTranslate(transform, rect.midX, rect.midY)
        // This part scales the circle to an oval with the same width and height as `rect`.
        transform = CGAffineTransformScale(transform, rect.width, rect.height)

        apply(transform)
    }

}

class CircularProgress: UIView, CAAnimationDelegate {

    fileprivate var progressLayer = CAShapeLayer()
        fileprivate var tracklayer = CAShapeLayer()
        
        // 트랙 색깔
        @IBInspectable var trackColor: UIColor {
            set {
                tracklayer.strokeColor = newValue.cgColor
            }
            get {
                return UIColor(cgColor: tracklayer.strokeColor ?? UIColor.clear.cgColor)
            }
        }
        // 트랙 두께
        @IBInspectable var trackLineWidth: CGFloat {
            set {
                tracklayer.lineWidth = newValue
            }
            get {
                return tracklayer.lineWidth
            }
        }
        // 진행률 표시 색깔
        @IBInspectable var progressLineColor: UIColor {
            set {
                progressLayer.strokeColor = newValue.cgColor
            }
            get {
                return UIColor(cgColor: progressLayer.strokeColor ?? UIColor.clear.cgColor)
            }
        }
        // 진행률 표시 두께
        @IBInspectable var progressLineWidth: CGFloat {
            set {
                progressLayer.lineWidth = newValue
            }
            get {
                return progressLayer.lineWidth
            }
        }
        // 진행률 값
        var moveValueTo = 0.5 // 기본값
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        override func draw(_ rect: CGRect) {
            // 뷰 사이즈가 정확하게 나오게 하기 위해서
            self.createCircularPath()
        }

        fileprivate func createCircularPath() {
            self.backgroundColor = UIColor.clear

            let circlePath = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: (frame.size.width) , height: (frame.size.height) - tracklayer.cornerRadius), startAngle: CGFloat(-0.5 * Double.pi), clockwise: true)// 시계방향으로 채우기
            // 트랙 설정
            tracklayer.path = circlePath.cgPath
            tracklayer.fillColor = UIColor.clear.cgColor

            tracklayer.strokeEnd = 1.0
            layer.addSublayer(tracklayer)
            // 진행률 설정
            progressLayer.path = circlePath.cgPath
            //MARK: 여기를 round/square/butt 로 변경시 모서리가 모양이 달라집니다.
            progressLayer.lineCap = .round
            progressLayer.fillColor = UIColor.clear.cgColor

            progressLayer.strokeEnd = self.moveValueTo//0.4
            
            layer.addSublayer(progressLayer)
        }
        
        func setProgress(value: Double) {
            self.moveValueTo = value
            progressLayer.strokeEnd = CGFloat(value)
            self.createCircularPath()
            
        }
        
        //0부터 목표까지 애니메이션작동
        func setProgressWithAnimation(duration: TimeInterval, value: Float) {
            self.moveValueTo = Double(value)
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = duration
            // Animate from 0 (no circle) to 1 (full circle)
            animation.fromValue = 0
            animation.toValue = value
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            progressLayer.strokeEnd = CGFloat(value)
            progressLayer.add(animation, forKey: "animateCircle")
        }
        // 지정부분부터 목표까지 애니메이션 작동
        func setProgressWithAnimation(duration: TimeInterval,fromValue: Float ,toVlaue : Float){
            self.moveValueTo = Double(toVlaue)
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = duration
            // Animate from 0 (no circle) to 1 (full circle)
            animation.fromValue = fromValue//0
            animation.toValue = toVlaue
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            progressLayer.strokeEnd = CGFloat(toVlaue)
            progressLayer.add(animation, forKey: "animateCircle")
        }
        
    

}
