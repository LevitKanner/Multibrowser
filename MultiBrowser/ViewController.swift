//
//  ViewController.swift
//  MultiBrowser
//
//  Created by Levit Kanner on 22/06/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    //MARK: - PROPERTIES
    @IBOutlet var addressBar: UITextField!
    @IBOutlet var stackView: UIStackView!
    weak var activeWebview: WKWebView?
    
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultTitle()
        addressBar.delegate = self
        addressBar.autocorrectionType = .no
        addressBar.clearsOnBeginEditing = true
        addressBar.placeholder = "https://"
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebview))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeWebview))
        
        navigationItem.rightBarButtonItems = [add , delete]
    }
    
    
    
    //Watches for changes in size class and adapts UI
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        }else {
            stackView.axis = .horizontal
        }
    }
    
    
    //MARK: - METHODS
    @objc func addWebview() {
        let webview = WKWebView()
        webview.layer.borderColor = UIColor.blue.cgColor
        webview.navigationDelegate = self
        
        stackView.addArrangedSubview(webview)
        
        let request = URLRequest(url: URL(string: "https://blckbirds.com")!)
        webview.load(request)
        
        selectWebview(webview)
        
        let gestureRecognizer = UIGestureRecognizer(target: self, action: #selector(webviewTapped))
        gestureRecognizer.delegate = self
        webview.addGestureRecognizer(gestureRecognizer)
    }
    
    
    
    //Actives view when tapped
    @objc func webviewTapped(_ gesture: UIGestureRecognizer) {
        if let view = gesture.view as? WKWebView {
            selectWebview(view)
        }
    }
    
    
    @objc func removeWebview() {
        //Check if a view is selected
        if let selectedView = activeWebview {
            
            //Get the index of the selected view in the stack view's arranged views
            if let index = stackView.arrangedSubviews.firstIndex(of: selectedView){
                //remove selected view from parent view
                selectedView.removeFromSuperview()
                
                if stackView.arrangedSubviews.count == 0 {
                    setDefaultTitle()
                    
                }else {
                    // convert the Index value into an integer
                    var currentIndex = Int(index)
                    
                    // if that was the last web view in the stack, go back one
                    if currentIndex == stackView.arrangedSubviews.count {
                        currentIndex = stackView.arrangedSubviews.count - 1
                    }
                    
                    // find the web view at the new index and select it
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
                        selectWebview(newSelectedWebView)
                    }
                }
            }
        }
        
    }
    
    
    func setDefaultTitle() {
        title = "MultiBrowser"
    }
    
    
    func updateUI(for webView: WKWebView) {
        title = webView.title
        addressBar.text = webView.url?.absoluteString ?? ""
    }
    
    
    func selectWebview(_ view: WKWebView) {
        for subview in stackView.arrangedSubviews{
            subview.layer.borderWidth = 0
        }
        
        activeWebview = view
        view.layer.borderWidth = 3
        updateUI(for: view)
    }
    
    
    //Gets called when the return key is hit
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webview = activeWebview, let text = addressBar.text {
            if let url = URL(string: "https://" + text){
                webview.load(URLRequest(url: url))
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    
    //Sets title when a web view finishes loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let view = activeWebview {
            updateUI(for: view)
        }
    }
    
    
    
    //Tells IOS to trigger our custom gesture along side default gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

