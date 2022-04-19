//
//  ViewController.swift
//  Todo App
//
//  Created by Cristian Sancricca on 13/04/2022.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var categoryName: UINavigationItem!
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colour = selectedCategory?.colour{
            
            guard let navBar = navigationController?.navigationBar else{return}
            
            if let navBarColour = UIColor(hexString: colour){
                navBar.backgroundColor = navBarColour
                searchBar.barTintColor = navBarColour
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
                
            }
           
        }
    }
    //MARK: - Table view datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done == true ? .checkmark : .none
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage:  CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                
            }
            
        }else{
            cell.textLabel?.text = "No se agregaron Items"
        }
        return cell
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write({
                    item.done = !item.done
                })
            }catch{
                print(error)
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items
    
    @IBAction func addNewItems(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Agregar nuevo Todo", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Agregar Todo", style: .default) { [self] action in
            
            if textField.text != ""{
                if let currentCategory = self.selectedCategory{
                    do{
                        try self.realm.write({
                            let newItem = Item()
                            newItem.title = textField.text!
                            currentCategory.items.append(newItem)
                        })
                    }catch{
                        print(error)
                    }
                   
                }
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Ingresar Todo"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation
    
    func loadItems(){
        
        categoryName.title = selectedCategory?.name.capitalized
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemSelectedToDelete = self.todoItems?[indexPath.row]{
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

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        
        if searchBar.text?.count == 0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
