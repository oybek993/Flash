//
//  ChatViewController.swift
//  Flash
//
//  Created by Oybek on 1/31/21.
//

import UIKit
import Firebase
class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadData()
        navigationItem.hidesBackButton = true
        title = K.appName
        
        // Do any additional setup after loading the view.
    }
    let db = Firestore.firestore()
    var messages: [Message] = []
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let msgBody = messageTextField.text, let msgSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName)
                .addDocument(data: [
                K.FStore.senderField: msgSender,
                K.FStore.bodyField: msgBody,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    print("Error adding document: \(e)")
                } else {
                    print("Success")
                }
            }
        }
        messageTextField.text = ""
    }
    func loadData() {
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener{ (querySnapshot, error) in
            if let e = error {
                print("Error getting documents: \(e)")
            } else {
                self.messages = []
                if let snapshotDocs = querySnapshot?.documents {
                    for doc in snapshotDocs {
                        let data = doc.data()
                        if let sender = data[K.FStore.senderField] as? String,
                           let body = data[K.FStore.bodyField] as? String {
                            self.messages.append(Message(sender: sender, body: body))
                            DispatchQueue.main.async {
                                
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
}
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label?.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        return cell
    }
    
    
}
