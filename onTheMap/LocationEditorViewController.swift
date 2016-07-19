//
//  LocationEditorViewController.swift
//  onTheMap
//
//  Created by Anna Rogers on 7/18/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import UIKit

class LocationEditorViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerText: UITextView!
    
    let textDelegate = AnswerTextViewDelegate()
    
    override func viewDidLoad() {
        answerText.textAlignment = .Center
        answerText.delegate = textDelegate
    }
    
}
