//
//  AnswerTextViewDelegate.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/18/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import UIKit

class AnswerTextViewDelegate: NSObject, UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
    }
    
    func textView(textView: UITextView, shouldChnageCharactersInRange range: NSRange, replacementText text: String) -> Bool {
        var newText: NSString
        newText = textView.text!
        newText = newText.stringByReplacingCharactersInRange(range, withString: text)
        return true
    }
    
//    func textViewShouldEndEditing(textView: UITextView) -> Bool {
//        print("the should end editing function has been called")
//        
//        return true
//    }
    
}
