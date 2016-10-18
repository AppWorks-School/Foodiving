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
import FirebaseStorage
import Nuke

class ResaturantMealTableViewController: UITableViewController {
    
    //Mark: Properties
    
    var meals = [Meal]()
    var restDic: [String: AnyObject] = [:]
    
    
    //Mark: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(restDic)
        retreiveData()
//        let menuImage = UIImage(named: "menuImage")
//        let menuImageView = UIImageView(image: menuImage)
        self.navigationItem.title = restDic["name"] as? String ?? ""
//        self.navigationItem.titleView = menuImageView

//        var nameString: String = restDic["name"] as? String ?? ""
//        if let nameStringSplitArray = (nameString.characters.split{$0 == "(" || $0 == ")"}.map(String.init)){
//        print(nameStringSplitArray[1])
//        }else {
//            print(nameStringSplitArray[0])
//        }
        
            
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    
    // Mark: Retrieve data
    
    func retreiveData() {
        
        meals = []
        let restaurantId = restDic["id"] as? String ?? ""
        //print(restaurantId)
        let mealInfoDatabase = FIRDatabase.database().reference()
        
        mealInfoDatabase.child("RestaurantsComments").queryOrderedByChild("restaurantId").queryEqualToValue("\(restaurantId)").observeEventType(.Value, withBlock: {
  
            snapshot in
            print(snapshot.value)
            let snapshots = snapshot.children.allObjects
            for commentSnap in snapshots{
                
                let mealName = commentSnap.value["mealName"] as? String ?? ""
                let price = commentSnap.value["price"] as? String ?? ""
                let photoString = commentSnap.value["photoString"] as? String ?? ""
                let tasteRating = commentSnap.value["tasteRating"] as?  Int ?? 0
                let serviceRating = commentSnap.value["serviceRating"] as?  Int ?? 0
                let revisitRating = commentSnap.value["revisitRating"] as?  Int ?? 0
                let environmentRating = commentSnap.value["environmentRating"] as?  Int ?? 0
                let comment = commentSnap.value["comment"] as? String ?? ""
                let userID = commentSnap.value["userID"] as? String ?? ""
                
                let meal = Meal(mealName: mealName, price: price,tasteRating: tasteRating, serviceRating: serviceRating, revisitRating: revisitRating, environmentRating: environmentRating, comment: comment)
                
                meal.photoString = photoString
                meal.userID = userID
                
                self.retreiveUserData(meal)
                
            }
            
            
            
        })
       
    }
    
    
    func retreiveUserData(meal: Meal){
        
        let userInfoDatabase = FIRDatabase.database().reference()
        userInfoDatabase.child("Users").queryOrderedByKey().queryEqualToValue(meal.userID).observeEventType(.Value, withBlock: {
            snapshot in
            print (snapshot.value)
            let snapshots = snapshot.children.allObjects
            for commentsnap in snapshots{
            meal.userName = commentsnap.value?["userName"] as? String ?? ""
            meal.userPhotoString = commentsnap.value?["photoString"] as? String ?? ""
            self.meals.append(meal)
            
            self.tableView.reloadData()
            }
        })

    }
    
    
    // Mark: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail"{
            
            let mealDetailViewController = segue.destinationViewController as! DetailViewController
            
            if let selectedMealCell = sender as? ResaturantMealTableViewCell{
                let indexPath = tableView.indexPathForCell(selectedMealCell)!
                let selectedMeal = meals[indexPath.row]
                mealDetailViewController.meal = selectedMeal
            }
        }else if segue.identifier == "AddItem"{
            let destinationController = segue.destinationViewController as! CommentViewController
            print(restDic)
            destinationController.restDictionary = self.restDic
            print("add new meal")
            
        }
    }
    
    
    
    
    
    // Mark: Action
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        meals = []
        
        
        self.tableView.reloadData()
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
        let photoString = meal.photoString ?? ""
        
        cell.mealNameLabel.text = meal.mealName
        cell.priceLabel.text = String(meal.price)
        cell.ratingControl.rating = Int(meal.tasteRating)
        
        if let photoUrl = NSURL(string: photoString) {

            cell.photoImageView.nk_setImageWith(photoUrl)
            
        }
        
        return cell
        
    }
}
