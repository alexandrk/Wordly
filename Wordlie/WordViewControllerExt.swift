//
//  ViewControllerExtension.swift
//  Wordlie
//
//  Used to control keyboard notifications and screen touches:
//      - to hide keyboard
//      - and adjust screen, if keyboard hides UI elements
//
//  Created by Alexander on 10/2/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import UIKit

extension WordViewController : UITextFieldDelegate {
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector:
            #selector(keyboardWillShow),name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:
            #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchButtonClick()
        return true
    }
    
    func keyboardWillShow(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                
                // Screen height
                let screenHeight = UIScreen.main.bounds.height
                
                // Keyboard height
                let keyboardHeight = keyboardFrame.height
                
                // TextFieldBottom position on screen
                var textFieldBottomY: CGFloat = 0
                // Pick proper text field, depending on the ViewController state
                var textField: UITextField? = nil
                if (wordField.isFirstResponder){
                    textField = wordField
                }
                if textField != nil {
                    textFieldBottomY = textField!.frame.origin.y +
                        textField!.frame.height
                }
                else {
                    return
                }
                
                // Add other elements heights (below textfield, if need to be present)
                var otherHeightAdjustments: CGFloat = 0.0
                let extraSpacing = Constants.App.Spacing.Medium
                let element = searchButton
                
                otherHeightAdjustments += element.frame.height + extraSpacing
                
                // Difference between textFieldBottom and Bottom of the Screen
                let textFieldToBottom = screenHeight - textFieldBottomY
                
                // Shift screen up on the difference between keyboard height and textFieldToBottom
                let shiftAmount = keyboardHeight - textFieldToBottom
                if shiftAmount > 0 {
                    view.frame.origin.y -= shiftAmount + 10 + otherHeightAdjustments
                }
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
    }
    
}

