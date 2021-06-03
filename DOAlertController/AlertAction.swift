//
//  AlertAction.swift
//  amoda-ios
//
//  Created by Bao Nguyen on 04/06/2021.
//  Copyright © 2021 KST. All rights reserved.
//

import Foundation

// MARK: AlertAction
class AlertAction: NSObject {
  var title: String
  var style: AlertActionStyle
  var handler: ((AlertAction?) -> Void)?
  var enabled: Bool {
    didSet {
      if oldValue != enabled {
        NotificationCenter.default.post(name: .alertActionEnabledDidChangeNotification, object: nil)
      }
    }
  }

  required init(title: String, style: AlertActionStyle, handler: ((AlertAction?) -> Void)?) {
    self.title = title
    self.style = style
    self.handler = handler
    self.enabled = true
  }
}
