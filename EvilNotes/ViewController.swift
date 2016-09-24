//
//  ViewController.swift
//  EvilNotes
//
//  Created by Roque Rueda on 09/09/16.
//  Copyright © 2016 RoqueRueda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, EvilNoteCallBack {

    @IBOutlet weak var notesTable : UITableView!
    
    // This variable is used to store the cell title
    // and pass it to the note detail view controller.
    var cellTitle : String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupTableView() {
        self.notesTable.delegate = self
        self.notesTable.dataSource = self
        //self.notesTable.editing
        //self.notesTable.end
    }
    
    private func setupNavigationBar() {
        let addNewNoteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        self.navigationItem.rightBarButtonItem = addNewNoteButton
    }
    
    func addNewNote() {
        cellTitle = ""
        self.performSegue(withIdentifier: "noteDetails", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noteDetails" {
            if segue.destination is EvilNoteDetailVC {
                let evilNoteDetail = segue.destination as! EvilNoteDetailVC
                evilNoteDetail.fileTitle = cellTitle
            }
        }
    }
    
    func isNoteAdded(noteIsAdded: Bool)  {
        
        print(noteIsAdded)
        
        if noteIsAdded {
            // Create the index again
            createIndex()
            
            // Update the datasource
            self.notesTable.reloadData()
            
        } else {
            // Nothing happend.
        }
        
    }
    
    func createIndex () {
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        
        do {
            let directoryContents = try fm.contentsOfDirectory(atPath: documentsUrl[0].path)
            var notesTitles : [String] = []
            for fileName in directoryContents {
                if !(fileName == "EvilNote.json" || fileName == ".EvilNote.json.swp") {
                    let noteTitle = fileName.characters.split(separator: ".").map(String.init)
                    print(noteTitle[0])
                    notesTitles.append(noteTitle[0])
                }
            }
            
            // write new index
            writeIndexFile(notesTitles: notesTitles);
            
            print(directoryContents)
        } catch {
            print(error.localizedDescription)
        }
        
        
        print(documentsUrl)
        // get the file path as a url.
        //let filePath = documentsUrl[0].appendingPathComponent("EvilNote.json")
    }
    
    
    func writeIndexFile(notesTitles: [String])  {
        // file manager.
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("EvilNote.json")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: notesTitles, options: .prettyPrinted)
            try data.write(to: filePath)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("item selected at section:\(indexPath.section) and row:\(indexPath.row)")
        
        let cell = tableView.cellForRow(at: indexPath) as! EvilNoteTableViewCell
        cellTitle = (cell.titleLabel.text)!
        self.performSegue(withIdentifier: "noteDetails", sender: nil)
    }
    
    
}

extension ViewController : UITableViewDataSource {
    
//    func tableView(tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCellEditingStyle.delete {
//            // Delete.
//        }
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let cell : EvilNoteTableViewCell = tableView.cellForRow(at: indexPath) as! EvilNoteTableViewCell
            
            deleteNote(fileName: cell.titleLabel.text!)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func deleteNote(fileName: String) {
        // get file manager
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("\(fileName).json")
        
        do {
            try fm.removeItem(atPath: filePath.path)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numberOfRows = getNumberOfItems()
        
        if numberOfRows > 0 {
            // Return number of rows.
            notesTable.separatorStyle = .singleLine
            tableView.backgroundView = nil
        } else {
            // We dont have rows.
            let noDataLabel: UILabel     =
                UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width,
                                      height: tableView.bounds.size.height))
            noDataLabel.text             = "You don't have notes, add one :D!"
            noDataLabel.textColor        = UIColor.black
            noDataLabel.textAlignment    = .center
            tableView.backgroundView     = noDataLabel
            tableView.separatorStyle     = .none
            
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") as! EvilNoteTableViewCell
        let titles = getTitles()
        cell.titleLabel.text = titles[indexPath.row]
        return cell
    }
    
    private func getTitles() -> [String] {
        // get file manager
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("EvilNote.json")
        
        // Get the contents of the file as a String.
        let contentOfFile = openFile(fm, path: filePath)
        
        do {
            if let data = contentOfFile.data(using: .utf8) {
                if let json = try JSONSerialization.jsonObject(with: data,
                                                               options: .mutableContainers) as?                                                                [String] {
                    return json
                }
            }
        } catch {
            // In any error we assume there is no items.
            print(error.localizedDescription)
        }
        return [String]()
    }
    
    private func getNumberOfItems() -> Int {
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("EvilNote.json")
        
        // check if the file exist.
        if !fm.fileExists(atPath: filePath.path) {
            // there is no file... lest create a new one.
            createFile(fm, path: filePath)
        }
        
        // Get the contents of the file as a String.
        let contentOfFile = openFile(fm, path: filePath)
        
        do {
            if let data = contentOfFile.data(using: .utf8) {
                if let json = try JSONSerialization.jsonObject(with: data,
                                                               options: .mutableContainers) as?
                                                                [String] {
                    return json.count
                }
            }
        } catch {
            // In any error we assume there is no items.
            return 0
        }
        
        // If we reach here something went wrong
        return 0
    }
    
    private func openFile(_ fileManager: FileManager, path: URL) -> String {
        do {
            let contentOfFile : String = try String.init(contentsOf: path, encoding: .utf8)
            return contentOfFile
        } catch {
            print(error.localizedDescription)
        }
        return "File was not found"
    }
    
    private func createFile(_ fileManager: FileManager, path: URL) {
        do {
            try "[{}]".write(to: path, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }

}

