//
//  AlertAnimation.swift
//  amoda-ios
//
//  Created by Bao Nguyen on 04/06/2021.
//  Copyright © 2021 KST. All rights reserved.
//

import Foundation
import UIKit

// MARK: AlertAnimation
class AlertAnimation: NSObject, UIViewControllerAnimatedTransitioning {

  let isPresenting: Bool

  init(isPresenting: Bool) {
    self.isPresenting = isPresenting
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    if isPresenting {
      return 0.45
    } else {
      return 0.25
    }
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if isPresenting {
      self.presentAnimateTransition(transitionContext)
    } else {
      self.dismissAnimateTransition(transitionContext)
    }
  }

  func presentAnimateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    let alertController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
    guard let alertController = alertController as? AlertController else { return }
    let containerView = transitionContext.containerView

    alertController.overlayView.alpha = 0.0
    if alertController.isAlert() {
      alertController.alertView.alpha = 0.0
      alertController.alertView.center = alertController.view.center
      alertController.alertView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    } else {
      alertController.alertView.transform = CGAffineTransform(translationX: 0,
                                                              y: alertController.alertView.frame.height)
    }
    containerView.addSubview(alertController.view)

    UIView.animate(withDuration: 0.25) {
      alertController.overlayView.alpha = 1.0
      if alertController.isAlert() {
        alertController.alertView.alpha = 1.0
        alertController.alertView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
      } else {
        let bounce = alertController.alertView.frame.height / 480 * 10.0 + 10.0
        alertController.alertView.transform = CGAffineTransform(translationX: 0, y: -bounce)
      }
    } completion: { finished in
      UIView.animate(withDuration: 0.25) {
        alertController.alertView.transform = CGAffineTransform.identity
      } completion: { finished in
        if finished {
          transitionContext.completeTransition(true)
        }
      }
    }
  }

  func dismissAnimateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    let alertController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
    guard let alertController = alertController as? AlertController
    else { return }

    UIView.animate(withDuration: self.transitionDuration(using: transitionContext)) {
      alertController.overlayView.alpha = 0.0
      if alertController.isAlert() {
        alertController.alertView.alpha = 0.0
        alertController.alertView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
      } else {
        alertController.containerView.transform = CGAffineTransform(translationX: 0,
                                                                    y: alertController.alertView.frame.height)
      }
    } completion: { _ in
      transitionContext.completeTransition(true)
    }
  }
}
