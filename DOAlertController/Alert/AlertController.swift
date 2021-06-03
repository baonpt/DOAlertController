//
//  AlertController.swift
//  amoda-ios
//
//  Created by Bao Nguyen on 04/06/2021.
//  Copyright © 2021 KST. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

// MARK: AlertController Class
class AlertController: UIViewController {
  
  // Message
  var message: String?
  
  // AlertController Style
  var preferredStyle: AlertControllerStyle?
  
  // OverlayView
  var overlayView = UIView()
  var overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
  
  // ContainerView
  var containerView = UIView()
  var containerViewBottomSpaceConstraint: NSLayoutConstraint?
  
  // AlertView
  var alertView = UIView()
  var alertViewBgColor = UIColor(red: 239/255, green: 240/255, blue: 242/255, alpha: 1.0)
  var alertViewWidth: CGFloat = 270.0
  var alertViewHeightConstraint: NSLayoutConstraint?
  var alertViewPadding: CGFloat = 15.0
  var innerContentWidth: CGFloat = 240.0
  let actionSheetBounceHeight: CGFloat = 20.0
  
  // TextAreaScrollView
  var textAreaScrollView = UIScrollView()
  var textAreaHeight: CGFloat = 0.0
  
  // TextAreaView
  var textAreaView = UIView()
  
  // TextContainer
  var textContainer = UIView()
  var textContainerHeightConstraint: NSLayoutConstraint?
  
  // TitleLabel
  var titleLabel = UILabel()
  var titleFont = UIFont.boldSystemFont(ofSize: 18 * ScaleFactor.default)
  var titleTextColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1.0)
  
  // MessageView
  var messageView = UILabel()
  var messageFont = UIFont.systemFont(ofSize: 15 * ScaleFactor.default)
  var messageTextColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1.0)
  
  // TextFieldContainerView
  var textFieldContainerView = UIView()
  var textFieldBorderColor = UIColor(red: 203.0/255, green: 203.0/255, blue: 203.0/255, alpha: 1.0)
  
  // TextFields
  var textFields: [AnyObject]?
  let textFieldHeight: CGFloat = 30.0
  var textFieldBgColor = UIColor.white
  let textFieldCornerRadius: CGFloat = 4.0
  
  // ButtonAreaScrollView
  var buttonAreaScrollView = UIScrollView()
  var buttonAreaScrollViewHeightConstraint: NSLayoutConstraint?
  var buttonAreaHeight: CGFloat = 0.0
  
  // ButtonAreaView
  var buttonAreaView = UIView()
  
  // ButtonContainer
  var buttonContainer = UIView()
  var buttonContainerHeightConstraint: NSLayoutConstraint?
  let buttonHeight: CGFloat = 44.0
  var buttonMargin: CGFloat = 10.0
  
  // Actions
  var actions: [AnyObject] = []
  
  // Buttons
  var buttons = [UIButton]()
  var buttonFont: [AlertActionStyle : UIFont] = [
    .default: UIFont.boldSystemFont(ofSize: 16 * ScaleFactor.default),
    .cancel: UIFont.boldSystemFont(ofSize: 16 * ScaleFactor.default),
    .destructive: UIFont.boldSystemFont(ofSize: 16 * ScaleFactor.default)
  ]
  var buttonTextColor: [AlertActionStyle : UIColor] = [
    .default: UIColor.white,
    .cancel: UIColor.white,
    .destructive: UIColor.white
  ]
  var buttonBgColor: [AlertActionStyle : UIColor] = [
    .default: UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1),
    .cancel: UIColor(red: 127/255, green: 140/255, blue: 141/255, alpha: 1),
    .destructive: UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
  ]
  var buttonBgColorHighlighted: [AlertActionStyle : UIColor] = [
    .default: UIColor(red: 74/255, green: 163/255, blue: 223/255, alpha: 1),
    .cancel: UIColor(red: 140/255, green: 152/255, blue: 153/255, alpha: 1),
    .destructive: UIColor(red: 234/255, green: 97/255, blue: 83/255, alpha: 1)
  ]
  var buttonCornerRadius: CGFloat = 4.0
  
  var layoutFlg = false
  var keyboardHeight: CGFloat = 0.0
  var cancelButtonTag = 0
  
  // Initializer
  convenience init(title: String?, message: String?, preferredStyle: AlertControllerStyle) {
    self.init(nibName: nil, bundle: nil)
    
    self.title = title
    self.message = message
    self.preferredStyle = preferredStyle
    
    self.providesPresentationContextTransitionStyle = true
    self.definesPresentationContext = true
    self.modalPresentationStyle = UIModalPresentationStyle.custom
    
    // NotificationCenter
    NotificationCenter.default
      .addObserver(self, selector: #selector(AlertController.alertActionEnabledDidChangeNotification(_:)),
                   name: .alertActionEnabledDidChangeNotification, object: nil)
    NotificationCenter.default
      .addObserver(self, selector: #selector(AlertController.keyboardWillShow(_:)),
                   name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter
      .default.addObserver(self, selector: #selector(AlertController.keyboardWillHide(_:)),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
    
    // Delegate
    self.transitioningDelegate = self
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
  }
  
  required  init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func currentOrientation() -> UIInterfaceOrientation {
    let screenSize = UIScreen.main.bounds.size
    return screenSize.width < screenSize.height
      ? .portrait
      : .landscapeLeft
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !isAlert() && cancelButtonTag != 0 {
      let tapGesture = UITapGestureRecognizer(target: self,
                                              action: #selector(AlertController.handleContainerViewTapGesture(_:)))
      containerView.addGestureRecognizer(tapGesture)
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    layoutView(self.presentingViewController)
  }
  
  
  func layoutView(_ presenting: UIViewController?) {
    if layoutFlg { return }
    layoutFlg = true
    
    // Screen Size
    var screenSize = presenting != nil ? presenting!.view.bounds.size : UIScreen.main.bounds.size
    if (UIDevice.current.systemVersion as NSString).floatValue < 8.0 {
      if currentOrientation().isLandscape {
        screenSize = CGSize(width: screenSize.height, height: screenSize.width)
      }
    }
    
    // variable for ActionSheet
    if !isAlert() {
      alertViewWidth =  screenSize.width
      alertViewPadding = 8.0
      innerContentWidth = (screenSize.height>screenSize.width)
        ? screenSize.width - alertViewPadding * 2
        : screenSize.height - alertViewPadding * 2
      buttonMargin = 8.0
      buttonCornerRadius = 6.0
    }
    
    // self.view
    self.view.frame.size = screenSize
    
    // OverlayView
    self.view.addSubview(overlayView)
    
    // ContainerView
    self.view.addSubview(containerView)
    
    // AlertView
    containerView.addSubview(alertView)
    
    // TextAreaScrollView
    alertView.addSubview(textAreaScrollView)
    
    // TextAreaView
    textAreaScrollView.addSubview(textAreaView)
    
    // TextContainer
    textAreaView.addSubview(textContainer)
    
    // ButtonAreaScrollView
    alertView.addSubview(buttonAreaScrollView)
    
    // ButtonAreaView
    buttonAreaScrollView.addSubview(buttonAreaView)
    
    // ButtonContainer
    buttonAreaView.addSubview(buttonContainer)
    
    //------------------------------
    // Layout Constraint
    //------------------------------
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    containerView.translatesAutoresizingMaskIntoConstraints = false
    alertView.translatesAutoresizingMaskIntoConstraints = false
    textAreaScrollView.translatesAutoresizingMaskIntoConstraints = false
    textAreaView.translatesAutoresizingMaskIntoConstraints = false
    textContainer.translatesAutoresizingMaskIntoConstraints = false
    buttonAreaScrollView.translatesAutoresizingMaskIntoConstraints = false
    buttonAreaView.translatesAutoresizingMaskIntoConstraints = false
    buttonContainer.translatesAutoresizingMaskIntoConstraints = false
    
    // self.view
    containerViewBottomSpaceConstraint = NSLayoutConstraint(item: containerView,
                                                            attribute: .bottom,
                                                            relatedBy: .equal,
                                                            toItem: self.view,
                                                            attribute: .bottom,
                                                            multiplier: 1.0,
                                                            constant: 0.0)
    
    overlayView.snp.makeConstraints { [unowned self] overlayView in
      overlayView.top.right.left.bottom.equalTo(view)
    }
    containerView.snp.makeConstraints { [unowned self] containerView in
      containerView.top.right.left.bottom.equalTo(view)
    }
    
    if isAlert() {
      alertView.snp.makeConstraints { [unowned self] alertView in
        alertView.centerX.centerY.equalTo(containerView)
        alertView.width.equalTo(alertViewWidth)
        alertView.height.equalTo(1000)
      }
      
      alertViewHeightConstraint = NSLayoutConstraint(item: alertView,
                                                     attribute: .height,
                                                     relatedBy: .equal,
                                                     toItem: nil,
                                                     attribute: .height,
                                                     multiplier: 1.0,
                                                     constant: 1000.0)
      
      
    } else {
      alertViewHeightConstraint = NSLayoutConstraint(item: alertView,
                                                     attribute: .height,
                                                     relatedBy: .equal,
                                                     toItem: nil,
                                                     attribute: .height,
                                                     multiplier: 1.0,
                                                     constant: 1000.0)
      alertView.addConstraint(alertViewHeightConstraint!)
      
      alertView.snp.makeConstraints { [unowned self] alertView in
        alertView.centerX.equalTo(containerView)
        alertView.bottom.equalTo(containerView).inset(actionSheetBounceHeight)
        alertView.width.equalTo(containerView)
        alertView.height.equalTo(1000)
      }
    }
    
    textAreaScrollView.snp.makeConstraints { [unowned self] textAreaScrollView in
      textAreaScrollView.top.left.right.equalTo(alertView)
      textAreaScrollView.bottom.equalTo(buttonAreaScrollView.snp.top)
    }
    
    buttonAreaScrollView.snp.makeConstraints { [unowned self] buttonAreaScrollView in
      buttonAreaScrollView.left.right.equalTo(alertView)
      buttonAreaScrollView.bottom.equalTo(isAlert() ? 0.0 : -actionSheetBounceHeight)
    }
    
    textAreaView.snp.makeConstraints { [unowned self] textAreaView in
      textAreaView.top.bottom.left.right.width.equalTo(textAreaScrollView)
      textAreaView.height.equalTo(textContainer)
    }
    
    
    textContainer.snp.makeConstraints { [unowned self] textContainer in
      textContainer.top.centerX.equalTo(textAreaView)
      textContainer.width.equalTo(innerContentWidth)
    }
    
    textContainerHeightConstraint = NSLayoutConstraint(item: textContainer,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: nil,
                                                       attribute: .height,
                                                       multiplier: 1.0,
                                                       constant: 0.0)
    
    buttonAreaScrollViewHeightConstraint = NSLayoutConstraint(item: buttonAreaScrollView,
                                                              attribute: .height,
                                                              relatedBy: .equal,
                                                              toItem: nil,
                                                              attribute: .height,
                                                              multiplier: 1.0,
                                                              constant: 0.0)
    
    buttonAreaView.snp.makeConstraints { [unowned self] buttonAreaView in
      buttonAreaView.top.left.right.bottom.width.equalTo(buttonAreaScrollView)
      buttonAreaView.height.equalTo(buttonContainer)
    }
    
    buttonContainer.snp.makeConstraints { [unowned self] buttonContainer in
      buttonContainer.top.centerX.equalTo(buttonAreaView)
      buttonContainer.width.equalTo(innerContentWidth)
    }
    
    buttonContainerHeightConstraint = NSLayoutConstraint(item: buttonContainer,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: nil,
                                                         attribute: .height,
                                                         multiplier: 1.0,
                                                         constant: 0.0)
    
    //------------------------------
    // Layout & Color Settings
    //------------------------------
    overlayView.backgroundColor = overlayColor
    alertView.backgroundColor = alertViewBgColor
    
    //------------------------------
    // TextArea Layout
    //------------------------------
    let hasTitle: Bool = title != nil && title != ""
    let hasMessage: Bool = message != nil && message != ""
    let hasTextField: Bool = textFields != nil && textFields!.count > 0
    
    var textAreaPositionY: CGFloat = alertViewPadding
    if !isAlert() {textAreaPositionY += alertViewPadding}
    
    // TitleLabel
    if hasTitle {
      titleLabel.frame.size = CGSize(width: innerContentWidth, height: 0.0)
      titleLabel.numberOfLines = 0
      titleLabel.textAlignment = .center
      titleLabel.font = titleFont
      titleLabel.textColor = titleTextColor
      titleLabel.text = title
      titleLabel.sizeToFit()
      titleLabel.frame = CGRect(x: 0, y: textAreaPositionY, width: innerContentWidth, height: titleLabel.frame.height)
      textContainer.addSubview(titleLabel)
      textAreaPositionY += titleLabel.frame.height + 5.0
    }
    
    // MessageView
    if hasMessage {
      messageView.frame.size = CGSize(width: innerContentWidth, height: 0.0)
      messageView.numberOfLines = 0
      messageView.textAlignment = .center
      messageView.font = messageFont
      messageView.textColor = messageTextColor
      messageView.text = message
      messageView.sizeToFit()
      messageView.frame = CGRect(x: 0, y: textAreaPositionY,
                                 width: innerContentWidth,
                                 height: messageView.frame.height)
      textContainer.addSubview(messageView)
      textAreaPositionY += messageView.frame.height + 5.0
    }
    
    // TextFieldContainerView
    if hasTextField {
      if (hasTitle || hasMessage) { textAreaPositionY += 5.0 }
      
      textFieldContainerView.backgroundColor = textFieldBorderColor
      textFieldContainerView.layer.masksToBounds = true
      textFieldContainerView.layer.cornerRadius = textFieldCornerRadius
      textFieldContainerView.layer.borderWidth = 0.5
      textFieldContainerView.layer.borderColor = textFieldBorderColor.cgColor
      textContainer.addSubview(textFieldContainerView)
      
      var textFieldContainerHeight: CGFloat = 0.0
      
      // TextFields
      let textFields = textFields ?? []
      textFields
        .enumerated()
        .forEach { (_, obj) in
          guard let textField = obj as? UITextField else { return }
          textField.frame = CGRect(x: 0.0,
                                   y: textFieldContainerHeight,
                                   width: innerContentWidth,
                                   height: textField.frame.height)
          textFieldContainerHeight += textField.frame.height + 0.5
        }
      
      textFieldContainerHeight -= 0.5
      textFieldContainerView.frame = CGRect(x: 0.0,
                                            y: textAreaPositionY,
                                            width: innerContentWidth,
                                            height: textFieldContainerHeight)
      textAreaPositionY += textFieldContainerHeight + 5.0
    }
    
    if !hasTitle && !hasMessage && !hasTextField {
      textAreaPositionY = 0.0
    }
    
    // TextAreaScrollView
    textAreaHeight = textAreaPositionY
    textAreaScrollView.contentSize = CGSize(width: alertViewWidth, height: textAreaHeight)
    textContainerHeightConstraint?.constant = textAreaHeight
    
    //------------------------------
    // ButtonArea Layout
    //------------------------------
    var buttonAreaPositionY: CGFloat = buttonMargin
    
    // Buttons
    if isAlert() && buttons.count == 2 {
      let buttonWidth = (innerContentWidth - buttonMargin) / 2
      var buttonPositionX: CGFloat = 0.0
      for button in buttons {
        let action = actions[button.tag - 1] as! AlertAction
        button.titleLabel?.font = buttonFont[action.style]
        button.setTitleColor(buttonTextColor[action.style], for: UIControl.State())
        button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), for: UIControl.State())
        button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .highlighted)
        button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .selected)
        button.frame = CGRect(x: buttonPositionX, y: buttonAreaPositionY, width: buttonWidth, height: buttonHeight)
        buttonPositionX += buttonMargin + buttonWidth
      }
      buttonAreaPositionY += buttonHeight
    } else {
      buttons.forEach { button in
        guard let action = actions[button.tag - 1] as? AlertAction,
              let bgColor = buttonBgColor[action.style],
              let bgHighlighted = buttonBgColorHighlighted[action.style]
        else { return }
        if action.style != AlertActionStyle.cancel {
          button.titleLabel?.font = buttonFont[action.style]
          button.setTitleColor(buttonTextColor[action.style], for: UIControl.State())
          button.setBackgroundImage(createImageFromUIColor(bgColor),
                                    for: UIControl.State())
          button.setBackgroundImage(createImageFromUIColor(bgHighlighted),
                                    for: .highlighted)
          button.setBackgroundImage(createImageFromUIColor(bgHighlighted),
                                    for: .selected)
          button.frame = CGRect(x: 0,
                                y: buttonAreaPositionY,
                                width: innerContentWidth,
                                height: buttonHeight)
          buttonAreaPositionY += buttonHeight + buttonMargin
        } else {
          cancelButtonTag = button.tag
        }
      }
      
      // Cancel Button
      if cancelButtonTag != 0 {
        if !isAlert() && buttons.count > 1 {
          buttonAreaPositionY += buttonMargin
        }
        guard let button = buttonAreaScrollView.viewWithTag(cancelButtonTag) as? UIButton,
              let action = actions[cancelButtonTag - 1] as? AlertAction,
              let bgColor = buttonBgColor[action.style],
              let bgHighlighted = buttonBgColorHighlighted[action.style]
        else { return }
        button.titleLabel?.font = buttonFont[action.style]
        button.setTitleColor(buttonTextColor[action.style], for: UIControl.State())
        button.setBackgroundImage(createImageFromUIColor(bgColor),
                                  for: UIControl.State())
        button.setBackgroundImage(createImageFromUIColor(bgHighlighted),
                                  for: .highlighted)
        button.setBackgroundImage(createImageFromUIColor(bgHighlighted),
                                  for: .selected)
        button.frame = CGRect(x: 0,
                              y: buttonAreaPositionY,
                              width: innerContentWidth,
                              height: buttonHeight)
        buttonAreaPositionY += buttonHeight + buttonMargin
      }
      buttonAreaPositionY -= buttonMargin
    }
    buttonAreaPositionY += alertViewPadding
    
    if (buttons.count == 0) {
      buttonAreaPositionY = 0.0
    }
    
    // ButtonAreaScrollView Height
    buttonAreaHeight = buttonAreaPositionY
    buttonAreaScrollView.contentSize = CGSize(width: alertViewWidth, height: buttonAreaHeight)
    buttonContainerHeightConstraint?.constant = buttonAreaHeight
    
    //------------------------------
    // AlertView Layout
    //------------------------------
    // AlertView Height
    reloadAlertViewHeight()
    alertView.frame.size = CGSize(width: alertViewWidth, height: alertViewHeightConstraint?.constant ?? 150)
  }
  
  // Reload AlertView Height
  func reloadAlertViewHeight() {
    
    var screenSize = self.presentingViewController != nil
      ? self.presentingViewController!.view.bounds.size
      : UIScreen.main.bounds.size
    if (UIDevice.current.systemVersion as NSString).floatValue < 8.0 {
      if currentOrientation().isLandscape {
        screenSize = CGSize(width: screenSize.height, height: screenSize.width)
      }
    }
    let maxHeight = screenSize.height - keyboardHeight
    
    // for avoiding constraint error
    buttonAreaScrollViewHeightConstraint?.constant = 0.0
    
    // AlertView Height Constraint
    var alertViewHeight = textAreaHeight + buttonAreaHeight
    if alertViewHeight > maxHeight {
      alertViewHeight = maxHeight
    }
    if !isAlert() {
      alertViewHeight += actionSheetBounceHeight
    }
    alertViewHeightConstraint?.constant = alertViewHeight
    
    // ButtonAreaScrollView Height Constraint
    var buttonAreaScrollViewHeight = buttonAreaHeight
    if buttonAreaScrollViewHeight > maxHeight {
      buttonAreaScrollViewHeight = maxHeight
    }
    buttonAreaScrollViewHeightConstraint?.constant = buttonAreaScrollViewHeight
  }
  
  // Button Tapped Action
  @objc func buttonTapped(_ sender: UIButton) {
    sender.isSelected = true
    guard let action = actions[sender.tag - 1] as? AlertAction else { return }
    if action.handler != nil {
      action.handler!(action)
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  // Handle ContainerView tap gesture
  @objc func handleContainerViewTapGesture(_ sender: AnyObject) {
    // cancel action
    guard let action = actions[cancelButtonTag - 1] as? AlertAction else { return }
    if action.handler != nil {
      action.handler!(action)
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  // UIColor -> UIImage
  func createImageFromUIColor(_ color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    let contextRef: CGContext = UIGraphicsGetCurrentContext()!
    contextRef.setFillColor(color.cgColor)
    contextRef.fill(rect)
    let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return img
  }
  
  // MARK : Handle NSNotification Method
  @objc func alertActionEnabledDidChangeNotification(_ notification: Notification) {
    (0..<buttons.count).forEach({buttons[$0].isEnabled = actions[$0].isEnabled})
  }
  
  @objc func keyboardWillShow(_ notification: Notification) {
    if let userInfo = notification.userInfo as? [String: NSValue],
       let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue.size {
      var _keyboardSize = keyboardSize
      if (UIDevice.current.systemVersion as NSString).floatValue < 8.0 {
        if (currentOrientation().isLandscape) {
          _keyboardSize = CGSize(width: _keyboardSize.height, height: _keyboardSize.width)
        }
      }
      keyboardHeight = _keyboardSize.height
      reloadAlertViewHeight()
      containerViewBottomSpaceConstraint?.constant = -keyboardHeight
      UIView.animate(withDuration: 0.25, animations: {
        self.view.layoutIfNeeded()
      })
    }
  }
  
  @objc func keyboardWillHide(_ notification: Notification) {
    keyboardHeight = 0.0
    reloadAlertViewHeight()
    containerViewBottomSpaceConstraint?.constant = keyboardHeight
    UIView.animate(withDuration: 0.25, animations: { [unowned self] in
      self.view.layoutIfNeeded()
    })
  }
  
  // MARK:  Methods
  
  // Attaches an action object to the alert or action sheet.
  func addAction(_ action: AlertAction) {
    // Error
    if action.style == AlertActionStyle.cancel {
      guard let actions = actions as? [AlertAction] else { return }
      actions.forEach { action in
        if action.style == AlertActionStyle.cancel {
          let error: NSError? = nil
          NSException.raise(NSExceptionName(rawValue: "NSInternalInconsistencyException"),
                            format:"AlertController can only have one action with a style of AlertActionStyleCancel",
                            arguments: getVaList([error ?? "nil"]))
          return
        }
      }
    }
    // Add Action
    actions.append(action)
    
    // Add Button
    let button = UIButton()
    button.layer.masksToBounds = true
    button.setTitle(action.title, for: UIControl.State())
    button.isEnabled = action.enabled
    button.layer.cornerRadius = buttonCornerRadius
    button.addTarget(self, action: #selector(AlertController.buttonTapped(_:)), for: .touchUpInside)
    button.tag = buttons.count + 1
    buttons.append(button)
    buttonContainer.addSubview(button)
  }
  
  // Adds a text field to an alert.
  func addTextFieldWithConfigurationHandler(_ configurationHandler: ((UITextField?) -> Void)!) {
    
    // You can add a text field only if the preferredStyle property is set to DOAlertControllerStyle.Alert.
    if !isAlert() {
      let error: NSError? = nil
      NSException.raise(NSExceptionName(rawValue: "NSInternalInconsistencyException"),
                        format: "Text fields can only be added to an alert controller of style DOAlertControllerStyleAlert",
                        arguments:getVaList([error ?? "nil"]))
      return
    }
    
    if textFields == nil {
      textFields = []
    }
    
    let textField = UITextField()
    textField.frame.size = CGSize(width: innerContentWidth, height: textFieldHeight)
    textField.borderStyle = .none
    textField.backgroundColor = textFieldBgColor
    textField.delegate = self
    
    if configurationHandler != nil {
      configurationHandler(textField)
    }
    
    textFields!.append(textField)
    textFieldContainerView.addSubview(textField)
  }
  
  func isAlert() -> Bool { return preferredStyle == .alert }
}

// MARK: UITextFieldDelegate
extension AlertController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField.canResignFirstResponder {
      textField.resignFirstResponder()
      self.dismiss(animated: true, completion: nil)
    }
    return true
  }
}

// MARK: UIViewControllerTransitioningDelegate
extension AlertController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    layoutView(presenting)
    return AlertAnimation(isPresenting: true)
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return AlertAnimation(isPresenting: false)
  }
}
