//
//  ShowAlertProtocol.swift
//  GitHubContributorsList
//
//  Created by Viacheslav Embaturov on 18.05.2021.
//

import UIKit

protocol ShowAlertProtocol {
    func isViewAviableToShowAlert() -> Bool
    func showAlert(with title: String, message: String, actions: [UIAlertAction]?)
}


extension ShowAlertProtocol where Self: UIViewController {
    
    func showAlert(with title: String, message: String, actions: [UIAlertAction]? = nil) {
        
        guard isViewAviableToShowAlert() else {
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        actions?.forEach { action in
            alertController.addAction(action)
        }
        present(alertController, animated: true)
    }
    
    func isViewAviableToShowAlert() -> Bool {
        return self.viewIfLoaded?.window != nil
    }
}

