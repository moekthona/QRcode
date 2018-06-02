//
//  QRCodeUITextField.swift
//  QRcode
//
//  Created by Thona on 6/2/18.
//  Copyright © 2018 Thona. All rights reserved.
//

import UIKit
@IBDesignable
class QRCodeUITextField: UITextField,ClassQRcodeDelegate {
    func getValueBack(value: String) {
        self.text = value
    }
    
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= rightPadding
        return textRect
    }
    
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            self.setupTextField()
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            self.setupTextField()
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.gray {
        didSet {
            self.setupTextField()
        }
    }
    
    
    @IBInspectable var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var rightPadding: CGFloat = 0
    
    @IBInspectable var placeholderColor: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = rightImage {
            rightViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.height - 10, height: self.bounds.size.height - 10))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.tintColor = placeholderColor
            rightView = imageView
            
            //action in image
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGestureRecognizer)
            
        } else {
            rightViewMode = UITextFieldViewMode.never
            rightView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: placeholderColor])
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        // let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        //print("OK it work")
        
        let qrcodeVC = QRCodeViewController()
        qrcodeVC.modalPresentationStyle = .custom
        qrcodeVC.delegate = self
        let currentController = self.getCurrentViewController()
        let navigationController = UINavigationController(rootViewController: qrcodeVC)
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionMoveIn
        //transition.subtype = CGFIn;
        //qrcodeVC.view.layer.add(transition, forKey: kCATransition)
        
        currentController?.present(navigationController, animated: true, completion: nil)
        //svc.presentedViewController
        
    }
    
    func setupTextField() {
        
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
    }
    
    func getCurrentViewController() -> UIViewController? {
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
        
    }
    
}
