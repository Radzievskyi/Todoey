//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Mykhailo Radzievskyi on 2023-05-09.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller doesn't exist")
        }
        
        let navBarColor = UIColor(hexString: "1D9BF6")
        navBar.backgroundColor = navBarColor
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) {
            (action) in
            
            if textField.text != nil && !textField.text!.isEmpty {
                
                let newCategory = Category()
                
                newCategory.name = textField.text!
                newCategory.color = UIColor.randomFlat().hexValue()
                                
                self.save(category: newCategory)
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Model Manipulation Methods
    
    fileprivate func save(category: Category) {
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print(error)
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    // MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Table view Data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let item = categories?[indexPath.row]
        
        cell.textLabel?.text = item?.name ?? "No Categories Added Yet"
        
        cell.accessoryType = .disclosureIndicator
        if let color = UIColor(hexString: item?.color ?? "1D9BF6") {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        return cell
    }
    
    // MARK: - Table view Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: - Table view Data source
}
