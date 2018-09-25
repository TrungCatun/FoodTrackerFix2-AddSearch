//
//  MealTableViewController.swift
//  FoodTrackerFix2
//
//  Created by Trung on 9/14/18.
//  Copyright © 2018 TrungCatun. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController, UISearchResultsUpdating {


    var meals =  [Meal]()
    var searchData = [Meal]()
    var searchControl: UISearchController?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let saveMeals = loadMeals() {
            meals += saveMeals
        }
        else {
            // Load the sample data.
            loadSampLeMeals()
        }
        // Search in foodtracker
        searchData = meals
        searchControl = UISearchController(searchResultsController: nil)
//        tableView.tableHeaderView = searchControl?.searchBar
        searchControl?.searchResultsUpdater = self
//        tableView.dataSource = self
        searchControl?.dimsBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchControl
        definesPresentationContext = true
        
        

    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchControl?.searchBar.text, !searchText.isEmpty {
            searchData = meals.filter { (item: Meal) -> Bool in
                return (item.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil)
            }

        } else { searchData = meals }
        
        tableView.reloadData()
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchData.count
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MealTableViewCell", for: indexPath)

        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let meal = searchData[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.RatingControl.rating = meal.rating
        

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = searchData[indexPath.row]
            mealDetailViewController.meal = selectedMeal
            
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
   
    
    
    private func loadSampLeMeals() {
        let photo1 = UIImage(named: "Meal1")
        let photo2 = UIImage(named: "Meal2")
        let photo3 = UIImage(named: "Meal3")
        
        guard let meal1 = Meal(name: "Hot girl 500k full service", photo: photo1, rating: 0) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(name: "25k$ one night ", photo: photo2, rating: 0) else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(name: "Girl 3 600k", photo: photo3, rating: 0) else {
            fatalError("Unable to instantiate meal2")
        }
        meals += [meal1, meal2, meal3]
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if let index = meals.index(of: searchData[selectedIndexPath.row]) {
                    meals[index] = meal
                    searchData[selectedIndexPath.row] = meal
                }
//                searchData[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
            // Add a new meal.
            let newIndexPath = IndexPath(row: searchData.count, section: 0)
            searchData.append(meal)
            meals = searchData
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // Save the meals.
            saveMeals()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let index = meals.index(of: searchData[indexPath.row]) {
                meals.remove(at: index)
                searchData.remove(at: indexPath.row)
            }
//            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    private func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
}
