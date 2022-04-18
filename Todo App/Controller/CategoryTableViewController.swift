//
//  CategoryTableViewController.swift
//  Todo App
//
//  Created by Cristian Sancricca on 16/04/2022.
//

import UIKit
import RealmSwift


class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    //MARK: - Table view Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No se agregaron categorias"
        
        return cell
    }
    
    //MARK: - table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Agregar nueva Categoria", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Agregar categoria", style: .default) { action in
            
            if textField.text != "" {
                let newCategory = Category()
                newCategory.name = textField.text!
                
                self.save(category: newCategory)
                self.tableView.reloadData()
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Ingresar Categoria"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - model manipulation
    
    func save(category: Category){
        
        do{
            try realm.write({
                realm.add(category)
            })
        } catch{
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(){
        
        categoryArray = realm.objects(Category.self)
        
    }

    override func updateModel(at indexPath: IndexPath) {
        if let itemSelectedToDelete = self.categoryArray?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(itemSelectedToDelete)
                }
            }catch{
                print("Error deleting")
            }
        }
    }
}
