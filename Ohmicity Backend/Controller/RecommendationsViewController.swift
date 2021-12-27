//
//  RecommendationsViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 12/26/21.
//

import Cocoa

class RecommendationsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    //Properties
    var recommendation: Recommendation?
    var recommendationArray = [Recommendation]()
    
    
    @IBOutlet weak var uidLabel: NSTextField!
    @IBOutlet weak var messageTextView: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    
    private func updateViews() {
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: Button Functions
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
    }
    
    
    //MARK: TableView
    func numberOfRows(in tableView: NSTableView) -> Int {
        return recommendationArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        <#code#>
    }
}
