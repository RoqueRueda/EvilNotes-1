//
//  EvilNoteDetailViewController.swift
//  EvilNotes
//
//  Created by Roque Rueda on 09/09/16.
//  Copyright © 2016 RoqueRueda. All rights reserved.
//

import UIKit

class EvilNoteDetailVC : UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBAction func saveNote(){
        // if editMode {
            // We are editing
            
        // } else {
            // We are adding
            let evilNote : [String:String] = ["title" : titleTextField.text!,
                                              "content": contentTextView.text!]
            do {
                let data = try JSONSerialization.data(withJSONObject: evilNote, options: .prettyPrinted)
                writeFile(contentOfFile: data)
                let vc = self.navigationController?.viewControllers[0] as! ViewController
                vc.isNoteAdded(noteIsAdded: true)
                //callBack?.isNoteAdded(noteIsAdded: true)
                self.navigationController!.popViewController(animated: true)
            }catch {
                print(error.localizedDescription)
            }
        //}
    }
    
    var fileTitle : String = ""
    var editMode  : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        
        if fileTitle.isEmpty {
            // New note
            editMode = false
        } else {
            // Edit note
            editMode = true
            titleTextField.text = fileTitle
            self.title = fileTitle
            
            contentTextView.text = getContentOfFile()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if self.contentTextView.isFirstResponder {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // if contentTextView.isFirstResponder
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    func getContentOfFile() -> String {
        // file manager.
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("\(fileTitle).json")
        
        // Get the contents of the file as a String.
        let contentOfFile = openFile(fm, path: filePath)
        
        do {
            if let data = contentOfFile.data(using: .utf8) {
                if let json = try JSONSerialization.jsonObject(with: data,
                options: .mutableContainers) as?
                    [String: String] {
                    return json["content"]!
                }
            }
        } catch {
            // In any error we assume there is no items.
            print(error.localizedDescription)
        }

        return "No content file"
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func writeFile(contentOfFile: Data) {
        // file manager.
        let fm = FileManager.default
        // get the documents urls.
        let documentsUrl = fm.urls(for: .documentDirectory, in: .userDomainMask)
        // get the file path as a url.
        let filePath = documentsUrl[0].appendingPathComponent("\(self.titleTextField.text!).json")
        
        print(filePath)
        
        do {
            try contentOfFile.write(to: filePath)
        } catch {
            print(error.localizedDescription)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
