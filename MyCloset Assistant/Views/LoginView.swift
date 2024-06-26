//
//  ViewController.swift
//  StyleSense Assistant
//
//  Created by Michael Obi on 4/3/24.
//

import UIKit

class LoginView: UIViewController {

  @IBOutlet weak var usernameField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var usernameErrorLabel: UILabel!
  @IBOutlet weak var passwordErrorLabel: UILabel!
  @IBOutlet weak var loginErrorLabel: UILabel!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  let queue = DispatchQueue.global(qos: .userInitiated)

  // MARK: Overrides

  override func viewDidLoad() {
    super.viewDidLoad()
    loadingIndicator.isHidden = true
    loadingIndicator.layer.cornerRadius = 5
    usernameErrorLabel.isHidden = true
    passwordErrorLabel.isHidden = true
    loginErrorLabel.isHidden = true
    usernameField.delegate = self
    passwordField.delegate = self
  }

  @IBAction func onLoginTapped(_ sender: Any) {
    let username = usernameField!.text!
    let password = passwordField!.text!

    if username.isEmpty {
      usernameErrorLabel.text = "Username is required"
      showErrorLabel(for: &usernameErrorLabel)
    } else {
      hideErrorLabel(for: &usernameErrorLabel)
    }
    if password.isEmpty {
      passwordErrorLabel.text = "Password is required"
      showErrorLabel(for: &passwordErrorLabel)
    } else {
      hideErrorLabel(for: &passwordErrorLabel)
    }

    User.login(username: username, password: password) { [unowned self] result in
      switch result {
      case .success(let user):
        print("INFO: Logged in as user \(user.username!)")
        loadingIndicator.isHidden = false
        hideErrorLabel(for: &loginErrorLabel)
        queue.asyncAfter(
          deadline: .now() + 0.5,
          execute: {
            NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
          })
      case .failure(let error):
        loginErrorLabel.text = error.message.capitalized
        showErrorLabel(for: &self.loginErrorLabel)
      }
    }
  }

  // MARK: Private Helpers

  private func showErrorLabel(for label: inout UILabel) {
    UILabel.transition(
      with: label, duration: 0.33, options: [.transitionCrossDissolve],
      animations: { [label] in
        label.isHidden = false
      })
  }

  private func hideErrorLabel(for label: inout UILabel) {
    UILabel.animate(
      withDuration: 0.33,
      animations: { [label] in
        label.isHidden = true
      })
  }
}

// Conform LoginView to UITextFieldDelegate
extension LoginView: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
