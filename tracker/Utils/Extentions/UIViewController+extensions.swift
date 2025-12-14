//
//  UICollectionView.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 29.11.2025.
//
import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false // Allows other gestures to be recognized
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true) // Ends the editing session of the currently active text field
    }
}

