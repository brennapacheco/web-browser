//
//  ViewController.swift
//  WebBrowser
//
//  Created by Brenna Pacheco da Silva Alves on 29/09/22.
//

import UIKit
import WebKit

class ViewController: UITableViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com", "hackingwithswift.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        navigationController?.isToolbarHidden = false
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        lazy var backButton: UIButton = {
            let element = UIButton()
            element.translatesAutoresizingMaskIntoConstraints = false
            element.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
            element.addTarget(webView, action: #selector(webView.goBack), for: .touchDown)
            element.isUserInteractionEnabled = true
            element.configuration = .plain()
            return element
        }()
        
        let backButtonItem = UIBarButtonItem(customView: backButton)
        backButtonItem.target = webView
        

        lazy var forwardButton: UIButton = {
            let element = UIButton()
            element.translatesAutoresizingMaskIntoConstraints = false
            element.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
            element.addTarget(webView, action: #selector(webView.goForward), for: .touchDown)
            element.isUserInteractionEnabled = true
            element.configuration = .plain()
            element.tintColor = UIColor(named: "Black")
            return element
        }()
        
        let forwardButtonItem = UIBarButtonItem(customView: forwardButton)
        
        toolbarItems = [backButtonItem, forwardButtonItem, progressButton, spacer, refresh]
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

    }
    
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: openPage))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else { return }
        guard let url = URL(string: "https://" + actionTitle) else { return }
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        
        decisionHandler(.cancel)
        
        let dialogMessage = UIAlertController(title: "Oops!", message: "This site is blocked.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        dialogMessage.addAction(ok)
        present(dialogMessage, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Websites", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: "https://" + websites[indexPath.row]) else { return }
        viewWillDisappear(true)
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        setupView()
    }
}
