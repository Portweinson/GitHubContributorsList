//
//  PushAnimator.swift
//  GitHubContributorsList
//
//  Created by Viacheslav Embaturov on 18.05.2021.
//

import UIKit

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //MARK: - Variables
    
    private let fromVC: ContributorsListVC
    private let toVC: ContributorDetailVC
    private let cellImageViewRect: CGRect
    private let duration: TimeInterval
    
    //MARK: -
    
    init?(duration: TimeInterval, from: ContributorsListVC, to: ContributorDetailVC) {
        
        self.duration = duration
        self.fromVC = from
        self.toVC = to
        
        let window = from.view.window
        guard let w = window else { return nil }
        guard let cell = fromVC.selectedCell else {return nil}

        cellImageViewRect = cell.convert(cell.imgViewAvatar.bounds, to: w)
    }
    
    
    //MARK: -

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let toView = toVC.view else {
                transitionContext.completeTransition(false)
                return
        }
        
        containerView.addSubview(toView)

        guard let window = fromVC.view.window,
              let controllerImageSnapshot = toVC.imageView.snapshotView(afterScreenUpdates: true),
              let backgroundView = fromVC.view.snapshotView(afterScreenUpdates: true) else {
            transitionContext.completeTransition(true)
            return
        }
        
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = toVC.view.backgroundColor
        
        backgroundView.frame = containerView.bounds

        [backgroundView, fadeView, controllerImageSnapshot].forEach {
            containerView.addSubview($0)
        }
        
        toVC.view.setNeedsLayout()
        toVC.view.layoutIfNeeded()
        let controllerImageViewRect = toVC.imageView.convert(toVC.imageView.bounds, to: window)
        controllerImageSnapshot.frame = cellImageViewRect
        
        let labelSnapshot = toVC.labelLogin.snapshotView(afterScreenUpdates: true)!
        labelSnapshot.frame = toVC.labelLogin.convert(toVC.labelLogin.bounds, to: window)
        fadeView.addSubview(labelSnapshot)
        
        fadeView.frame = CGRect(x: containerView.frame.maxX,
                                y: fadeView.frame.minY,
                                width: fadeView.frame.width,
                                height: fadeView.frame.height)

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                controllerImageSnapshot.frame = controllerImageViewRect
                fadeView.frame = CGRect(x: containerView.frame.minX,
                                        y: fadeView.frame.minY,
                                        width: fadeView.frame.width,
                                        height: fadeView.frame.height)
            }
        }, completion: { _ in
            controllerImageSnapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()
            toView.alpha = 1
            fadeView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}
