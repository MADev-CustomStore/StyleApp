//
//  UploadViewController.swift
//  StyleSense Assistant
//
//  Created by Michael Obi on 4/3/24.
//

import ParseSwift
import PhotosUI
import UIKit

class UploadViewController: UIViewController {

  @IBOutlet weak var uploadImage: UIImageView!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var brandTextField: UITextField!
  @IBOutlet weak var sizeTextField: UITextField!
  @IBOutlet weak var notesTextField: UITextField!
  @IBOutlet weak var errorLabel: UILabel!

  // MARK: IBActions

  @IBAction func tappedCamera(_ sender: Any) {
    print("INFO: Tapped camera button")

    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
      print("ERROR: Camera not available")
      errorLabel.text = "Camera unavailable. Please try again."
      showErrorLabel(for: &errorLabel)
      return
    }

    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.allowsEditing = true
    imagePicker.delegate = self

    present(imagePicker, animated: true)
  }

  @IBAction func tappedGallery(_ sender: Any) {
    print("INFO: Tapped gallery button")

    var config = PHPickerConfiguration()
    config.filter = .images
    config.preferredAssetRepresentationMode = .current
    config.selectionLimit = 1

    let picker = PHPickerViewController(configuration: config)
    picker.delegate = self

    present(picker, animated: true)
  }

  @IBAction func tappedUpload(_ sender: Any) {
    print("INFO: Tapped upload button")
    view.endEditing(true)

    let name = nameTextField.text!
    let category = categoryTextField.text!
    let brand = brandTextField.text!
    let size = sizeTextField.text!
    let notes = notesTextField.text!

    if name.isEmpty {
      errorLabel.text = "Name is required."
      showErrorLabel(for: &errorLabel)
      return
    }
    if category.isEmpty {
      errorLabel.text = "Category is required."
      showErrorLabel(for: &errorLabel)
      return
    }
    if brand.isEmpty {
      errorLabel.text = "Brand is required."
      showErrorLabel(for: &errorLabel)
      return
    }
    if size.isEmpty {
      errorLabel.text = "Size is required."
      showErrorLabel(for: &errorLabel)
      return
    }

    guard let image = uploadImage.image, let imageData = image.jpegData(compressionQuality: 0.1)
    else {
      errorLabel.text = "An image is required."
      showErrorLabel(for: &errorLabel)
      return
    }

    hideErrorLabel(for: &errorLabel)

    var item = ClosetItem(name: name.capitalized, image: nil, size: size.uppercased(), notes: notes)
    item.brand = brand.capitalized
    item.categories = [category.capitalized]
    item.imageFile = ParseFile(name: "image.jpg", data: imageData)

    User.fetchUpdatedUser {
      var current = $0
      if current.closet != nil {
        current.closet!.append(item)
      } else {
        current.closet = [item]
      }

      if current.brands != nil {
        if !current.brands!.contains(brand) {
          current.brands!.append(brand)
        }
      } else {
        current.brands = [brand]
      }

      if current.categories != nil {
        if !current.categories!.contains(category) {
          current.categories!.append(category)
        }
      } else {
        current.categories = [category]
      }

      DispatchQueue.main.async {
        current.save { [unowned self] result in
          switch result {
          case .success(let user):
            print("INFO: Updated user with ID = \(user.id)")
            DispatchQueue.main.async {
              self.navigationController?.popViewController(animated: true)
            }

          case .failure(let error):
            print("FATAL: Unable to update current user: \(error.localizedDescription)")
            self.errorLabel.text = error.localizedDescription
            self.showErrorLabel(for: &self.errorLabel)
          }
        }
      }

    }
  }

  // MARK: Overloads

  override func viewDidLoad() {
    super.viewDidLoad()
    uploadImage.isHidden = true
    errorLabel.isHidden = true
    nameTextField.delegate = self
    categoryTextField.delegate = self
    brandTextField.delegate = self
    sizeTextField.delegate = self
    notesTextField.delegate = self
  }

  // MARK: Private Helpers

  private func showErrorLabel(for label: inout UILabel) {
    UILabel.transition(
      with: label, duration: 0.33, options: [.transitionCrossDissolve],
      animations: { [label] in
        DispatchQueue.main.async {
          label.isHidden = false
        }
      })
  }

  private func hideErrorLabel(for label: inout UILabel) {
    UILabel.animate(
      withDuration: 0.33,
      animations: { [label] in
        DispatchQueue.main.async {
          label.isHidden = true
        }
      })
  }
}

// MARK: Conform UploadViewController to UploadViewController

extension UploadViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let nextTag = textField.tag + 1

    if let nextResponder = textField.superview?.viewWithTag(nextTag) {
      nextResponder.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
    }

    return true
  }
}

// MARK: Conform UploadViewController to PHPickerViewControllerDelegate

extension UploadViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)

    guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self)
    else {
      print("ERROR: Couldn't pick an image")
      errorLabel.text = "An error occurred. Try again."
      showErrorLabel(for: &errorLabel)
      return
    }

    provider.loadObject(ofClass: UIImage.self) { [unowned self] object, error in
      guard let image = object as? UIImage else {
        print("ERROR: Couldn't cast to UIImage")
        DispatchQueue.main.async {
          self.errorLabel.text = "Error loading image. Try again."
        }
        showErrorLabel(for: &self.errorLabel)
        return
      }

      if let error = error {
        print("ERROR: Couldn't load object: \(error.localizedDescription)")
        errorLabel.text = error.localizedDescription
        showErrorLabel(for: &errorLabel)
        return
      }

      DispatchQueue.main.async {
        self.uploadImage.image = image
        self.uploadImage.isHidden = false
      }
    }

  }
}

// MARK: Conform UploadViewController to UIImagePickerControllerDelegate

extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    picker.dismiss(animated: true)
    guard let image = info[.editedImage] as? UIImage else {
      print("ERROR: Unable to get image from camera")
      self.errorLabel.text = "Error loading image from camera. Try again."
      showErrorLabel(for: &errorLabel)
      return
    }

    uploadImage.image = image
    uploadImage.isHidden = false
  }
}
