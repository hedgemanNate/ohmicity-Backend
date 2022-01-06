//
//  RecommendationsViewController.swift
//  Ohmicity Backend
//
//  Created by Nathan Hedgeman on 12/26/21.
//

import Cocoa
import FirebaseFirestore

class RecommendationsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    //Properties
    var currentRecommendation: Recommendation? {
        didSet {
            recommendationSelected()
        }
    }
    var recommendationArray = [Recommendation]()
    
    
    @IBOutlet weak var uidLabel: NSTextField!
    @IBOutlet weak var messageTextView: NSTextField!
    @IBOutlet weak var alertTextView: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tagButton: NSButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Load")
        setupTableView()
        updateViews()
    }
    
    
    private func updateViews() {
        self.preferredContentSize = NSSize(width: 1320, height: 780)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        getRecommendations()
        
        tableView.doubleAction = #selector(doubleClicked)
    }
    
    //MARK: Button Functions
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteRecommendations()
    }
    
    @IBAction func tagButtonTapped(_ sender: Any) {
        
        guard var currentRecommendation = currentRecommendation else {return}
        ref.recommendationDataDataPath.document(currentRecommendation.recommendationID).updateData(["tag" : tagButton.state.rawValue])
        
        currentRecommendation.tag = tagButton.state.rawValue
        
        recommendationArray.removeAll(where: {$0.recommendationID == currentRecommendation.recommendationID})
        recommendationArray.append(currentRecommendation)
        tableView.reloadData()
    }
    
    
    //MARK: Selection Functions
    
    @objc func doubleClicked() {
        let row = tableView.selectedRow
        if row < 0 {return}
        currentRecommendation = recommendationArray[row]
    }
    
    private func recommendationSelected() {
        guard let currentRecommendation = currentRecommendation else {
            return
        }

        DispatchQueue.main.async {
            self.messageTextView.stringValue = currentRecommendation.explanation
            
            if currentRecommendation.tag != 0 {
                self.tagButton.state = .on
            } else {
                self.tagButton.state = .off
            }
            
            self.uidLabel.stringValue = currentRecommendation.user
        }
    }
    
    
    
    //MARK: Database Functions
    private func getRecommendations() {
        FireStoreReferenceManager.recommendationDataDataPath.getDocuments { [self] querySnapshot, err in
            if let err = err {
                self.alertTextView.stringValue = "Error: \(err.localizedDescription)"
            } else {
                alertTextView.stringValue = "Got Recommendation Data"
                recommendationArray = []
                for recommendation in querySnapshot!.documents {
                    let result = Result {
                        try recommendation.data(as: Recommendation.self)
                    }
                    switch result {
                    case .success(let recommendation):
                        alertTextView.stringValue = "Success: Recommendation Created"
                        if let recommendation = recommendation {
                            recommendationArray.append(recommendation)
                        }
                    case .failure(let error):
                        alertTextView.stringValue = "Failure: Recommendation Failed: \(error)"
                    }
                }
            }
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
    }
    
    private func deleteRecommendations() {
        guard let currentRecommendation = currentRecommendation else {
            return
        }
        ref.recommendationDataDataPath.document(currentRecommendation.recommendationID).delete { [self] error in
            if let err = error {
                alertTextView.stringValue = err.localizedDescription
            } else {
                recommendationArray.removeAll(where: {$0 == currentRecommendation})
                
                if recommendationArray.count == 0 {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.uidLabel.stringValue = ""
                        self.messageTextView.stringValue = ""
                        self.alertTextView.stringValue = "\(currentRecommendation.recommendationID) was deleted"
                    }
                    
                } else {
                    self.currentRecommendation = recommendationArray[0]
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.uidLabel.stringValue = ""
                        self.messageTextView.stringValue = ""
                        self.alertTextView.stringValue = "\(currentRecommendation.recommendationID) was deleted"
                    }
                }
            }
        }
    }
    
    //MARK: TableView
    func numberOfRows(in tableView: NSTableView) -> Int {
        return recommendationArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "RecommendationCell"), owner: nil) as? NSTableCellView {
            
            if recommendationArray[row].tag != 0 {
                cell.layer?.backgroundColor = NSColor.red.cgColor
            }
            
            cell.textField?.stringValue = recommendationArray[row].recommendationID
                        
            return cell
        }
        
        return nil
    }
}
