//
//  ResaturantMealTableViewController.swift
//  Foodaholic
//
//  Created by onechun🌾 on 2016/9/29.
//  Copyright © 2016年 onechun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase



class ResaturantMealTableViewController: UITableViewController {
    var meals = [Meal]()

    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        // Mark: Retrieve data
        let mealInfoDatabase = FIRDatabase.database().reference()
        mealInfoDatabase.child("Restaurants_comment").queryOrderedByKey().observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            print(snapshot)
            
            let mealName = snapshot.value!["mealName"] as! String
            let price = snapshot.value!["price"] as! String
//            let photo = snapshot.value!["photo"] as! UIImage
            let tasteRating = snapshot.value!["tasteRating"] as! Int
            let comment = snapshot.value!["comment"] as! String

            
            self.meals.insert(Meal(mealName: mealName,price: price,tasteRating: tasteRating, comment: comment)!, atIndex:0)
            self.tableView.reloadData()
            
            }
        )
        
        
        
//        let storageRef = FIRStorage.storage().reference
//        let mealPhoto = storageRef().child("mealPhoto/file.jpg")
        //        mealPhoto.downloadURLWithCompletion{(URL, error) -> Void in
//            if (error != nil) {
//                print("error to download")
//            }else{
//                let resaturantMealTableViewCell = ResaturantMealTableViewCell()
//                resaturantMealTableViewCell.photoImageView.image = UIImage(contentsOfFile:"gs://foodaholic-e6dde.appspot.com/mealPhoto")
//            }
//            
//        }

//        mealPhoto.dataWithMaxSize(1*1000*1000){
//            (data,error) in
//            if error == nil{
//                print(data)
//                
//                let myImage = UIImage(data: data!)
////                let resaturantMealTableViewCell = ResaturantMealTableViewCell()
////                resaturantMealTableViewCell.photoImageView.image = UIImage(data: data!)
//
//            }else{
//                print(error?.localizedDescription)
//            }
//        }
//        
//        self.tableView.reloadData()

    }

    //Mark: Retrieve Image from firebase
    
    
    func retrieveImage(){
        let storageRef = FIRStorage.storage().reference
        let mealPhoto = storageRef().child("mealPhoto/file.jpg")
        
        mealPhoto.dataWithMaxSize(1*1000*1000){
            (data,error) in
            if error == nil{
                print(data)
                
                let myImage = UIImage(data: data!)
//                self.meals.insert(Meal(photo:mealPhoto))
                
                //                let resaturantMealTableViewCell = ResaturantMealTableViewCell()
                //                resaturantMealTableViewCell.photoImageView.image = UIImage(data: data!)
                
            }else{
                print(error?.localizedDescription)
            }
        }
        
        self.tableView.reloadData()

    }
    
    
    
    //Mark: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail"{
            
            let mealDetailViewController = segue.destinationViewController as! CommentViewController
            
            if let selectedMealCell = sender as? ResaturantMealTableViewCell{
                let indexPath = tableView.indexPathForCell(selectedMealCell)!
                let selectedMeal = meals[indexPath.row]
                mealDetailViewController.meal = selectedMeal
            }
            
        }else if segue.identifier == "AddItem"{
            
            print("add new meal")
            
        }
    }
    
    
    //Mark: Action
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? CommentViewController, meal = sourceViewController.meal {
            
            
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal
                meals[selectedIndexPath.row] = meal
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            } else {
                
                // Add a new meal
                //let newIndexPath = NSIndexPath(forRow: meals.count, inSection: 0)
                            
                //meals.append(meal)
                //tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
        }
    }
    
    
    
  
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return meals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MealTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,forIndexPath: indexPath) as! ResaturantMealTableViewCell
        
        
        let meal = meals[indexPath.row]
        
        cell.mealNameLabel.text = meal.mealName
        cell.priceLabel.text = String(meal.price)
        cell.ratingControl.rating = Int(meal.tasteRating)
//        cell.photoImageView.image = 
        return cell
        
    }
}
