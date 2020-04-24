//
//  UIViewControllerExt.swift
//  Loster
//
//  Created by Malovic, Milos on 4/22/20.
//  Copyright © 2020 Malovic, Milos. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController: UIViewControllerPresenting {
    
    static var className: String {
        return String(describing: self)
    }
    
    func presentAlertController(withTitle title: String? = nil,
                                message: String? = nil,
                                textField: (placeholder: String?, keyboardType: UIKeyboardType)?,
                                actions: (title: String, style: UIAlertAction.Style, handler: ((_ text: String?) -> Void)?)...) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let textField = textField {
            alertController.addTextField {
                $0.placeholder = textField.placeholder
                $0.keyboardType = textField.keyboardType
            }
        }
        
        for action in actions {
            alertController.addAction(UIAlertAction(title: action.title, style: action.style, handler: { (_) in
                action.handler?(alertController.textFields?.first?.text)
            }))
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func presentAlertSheet(withTitle title: String? = nil,
                           message: String? = nil,
                           textField: (placeholder: String?, keyboardType: UIKeyboardType)?,
                           actions: (title: String, style: UIAlertAction.Style, handler: ((_ text: String?) -> Void)?)...) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        if let textField = textField {
            alertController.addTextField {
                $0.placeholder = textField.placeholder
                $0.keyboardType = textField.keyboardType
            }
        }
        
        for action in actions {
            alertController.addAction(UIAlertAction(title: action.title, style: action.style, handler: { (_) in
                action.handler?(alertController.textFields?.first?.text)
            }))
        }
        present(alertController, animated: true, completion: nil)
    }
}

protocol UIViewControllerPresenting {}

extension UIViewControllerPresenting where Self: UIViewController {
    
    static func instantiate(from storyboardName: String, withIdentifier identifier: String = className) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
}

extension UIViewController {
    
    func configureNavigationBar(largeTitleColor: UIColor, backgoundColor: UIColor, tintColor: UIColor, title: String, preferredLargeTitle: Bool) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
        navBarAppearance.titleTextAttributes = [.foregroundColor: largeTitleColor]
        navBarAppearance.backgroundColor = backgoundColor
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.compactAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = tintColor
        navigationItem.title = title
    }
}
