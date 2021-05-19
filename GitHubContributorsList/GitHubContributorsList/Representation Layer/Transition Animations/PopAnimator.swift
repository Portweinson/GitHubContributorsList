//
//  PopAnimator.swift
//  GitHubContributorsList
//
//  Created by Viacheslav Embaturov on 18.05.2021.
//

import UIKit


class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let fromVC: ContributorDetailVC
    private let toVC: ContributorsListVC
    private let cellImageViewRect: CGRect
    private let duration: TimeInterval
    
    init?(duration: TimeInterval, from: ContributorDetailVC, to: ContributorsListVC) {
        
        self.duration = duration
        self.fromVC = from
        self.toVC = to
        
        let window = from.view.window
        guard let w = window else { return nil }
        guard let cell = toVC.selectedCell else {return nil}

        cellImageViewRect = cell.convert(cell.imgViewAvatar.bounds, to: w)
    }

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

        guard let window = toVC.view.window,
              let fromImageSnapshot = fromVC.imageView.snapshotView(afterScreenUpdates: false) else {
            transitionContext.completeTransition(true)
            return
        }

        let backgroundView = toVC.view.snapshotView(afterScreenUpdates: true)!
        fromVC.imageView.isHidden = true
        let foregroundView = fromVC.view.snapshotView(afterScreenUpdates: true)!
        
        [backgroundView, foregroundView, fromImageSnapshot].forEach {
            containerView.addSubview($0)
        }

        let controllerImageViewRect = fromVC.imageView.convert(fromVC.imageView.bounds, to: window)
        fromImageSnapshot.frame = controllerImageViewRect

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                
                fromImageSnapshot.frame = self.cellImageViewRect
                foregroundView.frame = CGRect(x: containerView.frame.maxX,
                                              y: foregroundView.frame.minY,
                                              width: foregroundView.frame.width,
                                              height: foregroundView.frame.height)
            }

        }, completion: { _ in
            fromImageSnapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()
            toView.alpha = 1
            transitionContext.completeTransition(true)
        })
    }
}
