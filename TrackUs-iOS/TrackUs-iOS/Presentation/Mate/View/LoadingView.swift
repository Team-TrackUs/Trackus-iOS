//
//  LoadingView.swift
//  TrackUs-iOS
//
//  Created by 박선구 on 5/30/24.
//

import UIKit

class LoadingView: UIView {
    
    // MARK: - Properties
    
    let circleSize: CGFloat = 20.0
    let circleSpacing: CGFloat = 16.0
    let animationDuration: TimeInterval = 0.1
    
    var circles: [UIView] = []
    var currentCircleIndex = 0
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        
        configureUI()
        startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        
        backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        let totalWidth = CGFloat(3) * circleSize + CGFloat(2) * circleSpacing
        let startX = (bounds.width - totalWidth) / 2.0
        let startY = (bounds.height - circleSize) / 2.0
        
        for _ in 0..<3 {
            let circleFrame = CGRect(x: startX + CGFloat(circles.count) * (circleSize + circleSpacing),
                                     y: startY,
                                     width: circleSize,
                                     height: circleSize)
            let circleView = UIView(frame: circleFrame)
            circleView.backgroundColor = .white
            circleView.layer.cornerRadius = circleSize / 2
            addSubview(circleView)
            circles.append(circleView)
        }
    }
    
    func startAnimation() {
        animateCircle(at: currentCircleIndex)
    }
    
    func animateCircle(at index: Int) {
        let circle = circles[index]
        
        let moveUp = CABasicAnimation(keyPath: "position.y")
        moveUp.fromValue = circle.center.y
        moveUp.toValue = circle.center.y - 20.0
        moveUp.duration = animationDuration
        moveUp.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let moveDown = CABasicAnimation(keyPath: "position.y")
        moveDown.fromValue = circle.center.y - 20.0
        moveDown.toValue = circle.center.y
        moveDown.duration = animationDuration
        moveDown.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        moveDown.beginTime = animationDuration
        
        let group = CAAnimationGroup()
        group.animations = [moveUp, moveDown]
        group.duration = animationDuration * 2
        group.repeatCount = 1
        group.delegate = self
        group.setValue(index, forKey: "circleIndex")
        
        circle.layer.add(group, forKey: "move")
    }
    
    deinit {
        circles.forEach { $0.removeFromSuperview() }
        circles.removeAll()
    }
}

extension LoadingView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            if currentCircleIndex < circles.count - 1 {
                currentCircleIndex += 1
            } else {
                currentCircleIndex = 0
            }
            animateCircle(at: currentCircleIndex)
        }
    }
}
