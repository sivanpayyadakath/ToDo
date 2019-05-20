//
//  TodosViewController.swift
//  ToDo
//
//  Created by Sivan.Payyadakath on 2019/05/16.
//  Copyright © 2019 Sivan.Payyadakath. All rights reserved.
//

import UIKit
import CoreData

class TodosViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var todos: [NSManagedObject] = []
    var doing: [NSManagedObject] = []
    var done: [NSManagedObject] = []
    var sections: [NSManagedObject] = []
    let titleForSections = ["Not Started", "On Progress", "Done"]
    
    @IBOutlet weak var addTextField: UITextField!
    @IBOutlet weak var addTextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isEditing = true
        tableView.rowHeight = UITableView.automaticDimension
        // tableView.estimatedRowHeight = 80
        
        // Do any additional setup after loading the view.
     
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }

        let managedView = appDelegate.persistentContainer.viewContext

        let todofetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        let doingfetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        let donefetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")
        
        let predicate = NSPredicate(format: "status == %d",0)
        todofetchRequest.predicate = predicate
        
        let doingpredicate = NSPredicate(format: "status == %d",1)
        doingfetchRequest.predicate = doingpredicate
        
        let donepredicate = NSPredicate(format: "status == %d",2)
        donefetchRequest.predicate = donepredicate
        
        
        do {
            try todos = managedView.fetch(todofetchRequest)
            try doing = managedView.fetch(doingfetchRequest)
            try done = managedView.fetch(donefetchRequest)
            
            } catch let error as NSError {
            print("couldnt fetch \(error) \(error.userInfo)")
        }
        
//        navigationItem .leftBarButtonItem = editButtonItem
        
        //add todo via textfield is disabled at first
        addTextButton.isEnabled = false
        
    }

    
    @IBAction func addTodo(_ sender: Any) {
        let alert = UIAlertController(title: "Add Todo", message: "What is it?", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter some todo"
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "anything more?"
        })
        
        
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in
            
            let title = alert.textFields![0].text!
            let sub = alert.textFields![1].text!
            
            self.save(title: title, sub: sub)
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            
            print("nigga cancelled")
            
        }))
        
        self.present(alert, animated: true)
    }
    
    func save(title: String, sub: String){
        print(sub)
        print(title)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let entityTodo = NSEntityDescription.entity(forEntityName: "Todo", in: managedContext)!
        
        let todo = NSManagedObject(entity: entityTodo, insertInto: managedContext)
        
        todo.setValue(title, forKey: "title")
        todo.setValue(sub, forKey: "sub")
        todo.setValue(0, forKey: "status")
        
        do {
            try managedContext.save()
            todos.append(todo)
            
    
            
        } catch let error as NSError {
            print("couldnt be saved \(error) \(error.userInfo)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            print("deleting \(indexPath.row)")
            
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                return
        }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            switch(indexPath.section){
            case 0:
                let itemToDelete = todos.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .right)
                managedContext.delete(itemToDelete)
            case 1:
                let itemToDelete = doing.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .right)
                managedContext.delete(itemToDelete)
            case 2:
                let itemToDelete = done.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .right)
                managedContext.delete(itemToDelete)
            default:
                print("error in deleting")
            }
            
        
        }
        
    }
    
    
}

extension TodosViewController : UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var k: Int = 0
        switch section {
        case 0:
            k = todos.count
        case 1:
            k = doing.count
        case 2:
            k = done.count
        default:
            print("error")
        }
        return k
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForSections[section]
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TodosTableViewCell
        switch indexPath.section {
        case 0:
            let todo = todos[indexPath.row]
            cell.todoTitle?.text = todo.value(forKey: "title") as? String
            cell.todoSubTitle?.text = todo.value(forKey: "sub") as? String
        case 1:
            let todo = doing[indexPath.row]
            cell.todoTitle?.text = todo.value(forKey: "title") as? String
            cell.todoSubTitle?.text = todo.value(forKey: "sub") as? String
        case 2:
            let todo = done[indexPath.row]
            cell.todoTitle?.text = todo.value(forKey: "title") as? String
            cell.todoSubTitle?.text = todo.value(forKey: "sub") as? String
        default:
            print("error")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var itemToMove: NSManagedObject?

        switch sourceIndexPath.section {
        case 0:
            itemToMove = todos[sourceIndexPath.row]
            todos.remove(at: sourceIndexPath.row)
        case 1:
            itemToMove = doing[sourceIndexPath.row]
            doing.remove(at: sourceIndexPath.row)
        case 2:
            itemToMove = done[sourceIndexPath.row]
            done.remove(at: sourceIndexPath.row)
        default:
            print("error in fetching item to move")
        }

        switch destinationIndexPath.section {
        case 0:
            todos.insert(itemToMove!, at: destinationIndexPath.row)
            itemToMove?.setValue(0, forKey: "status")
        case 1:
            doing.insert(itemToMove!, at: destinationIndexPath.row)
            itemToMove?.setValue(1, forKey: "status")
        case 2:
            done.insert(itemToMove!, at: destinationIndexPath.row)
            itemToMove?.setValue(2, forKey: "status")
        default:
            print("error in actual moving")
            }
        }

}


extension TodosViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newText = textField.text, textField.text != ""{
        save(title: newText, sub: "")
        textField.text = ""
        tableView.reloadData()
        
        }
        return true
    }

    
}
