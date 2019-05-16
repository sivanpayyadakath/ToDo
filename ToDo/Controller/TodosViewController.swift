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
    var names: [String] = ["A","B","C","d","e","f"]
    var todos: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        // Do any additional setup after loading the view.
     
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }

        let managedView = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Todo")

        do {
            try todos = managedView.fetch(fetchRequest)
        } catch let error as NSError {
            print("couldnt fetch \(error) \(error.userInfo)")
        }
        
        navigationItem .leftBarButtonItem = editButtonItem
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
        
        let entity = NSEntityDescription.entity(forEntityName: "Todo", in: managedContext)!
        
        let todo = NSManagedObject(entity: entity, insertInto: managedContext)
        
        todo.setValue(title, forKey: "title")
        todo.setValue(sub, forKey: "sub")
        
        print(todo)
        
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
            
            let itemToDelete = todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
            managedContext.delete(itemToDelete)
        
        }
        
    }
    
}

extension TodosViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = todos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TodosTableViewCell
//        cell.textLabel?.text = todo.value(forKey: "title") as? String
        cell.todoTitle?.text = todo.value(forKey: "title") as? String
//        cell.todoSubTitle
        return cell
    }

}
