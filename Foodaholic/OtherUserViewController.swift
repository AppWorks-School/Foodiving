//
//  OtherUserViewController.swift
//  Foodaholic
//
//  Created by onechun🌾 on 2016/10/18.
//  Copyright © 2016年 onechun. All rights reserved.
//

import UIKit
import Nuke
import Firebase

class OtherUserViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource{

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPhotoImage: UIImageView!
    @IBOutlet weak var otherUserMealView: UICollectionView!
    var meal: Meal?
    var mealPhotoStringArray: [String] = []
    var meals = [Meal]()
    private let reuseIdentifier = "OtherCollectionCell"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otherUserMealView.delegate = self
        otherUserMealView.dataSource = self
        
        userNameLabel.text = meal?.userName
        let userphotoURL = NSURL(string: (meal?.userPhotoString)!)
        let userphotoData = NSData(contentsOfURL: userphotoURL!)
        userPhotoImage.image = UIImage(data: userphotoData!)
        
        retriveData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func retriveData(){
        
        let userID = meal?.userID
        
        meals = []
        let mealInfoReference = FIRDatabase.database().reference()
        
        mealInfoReference.child("RestaurantsComments").queryOrderedByChild("userID").queryEqualToValue(userID).observeEventType(.Value, withBlock:
            { snapshot in
                let snapshots = snapshot.children.allObjects
                print(snapshot.value)
                
                for mealInfo in snapshots {
                    guard
                        let mealName = mealInfo.value["mealName"] as? String,
                        let price = mealInfo.value["price"] as? String,
                        let photoString = mealInfo.value["photoString"] as? String,
                        let tasteRating = mealInfo.value["tasteRating"] as? Int,
                        let serviceRating = mealInfo.value["serviceRating"] as?  Int,
                        let revisitRating = mealInfo.value["revisitRating"] as?  Int,
                        let environmentRating = mealInfo.value["environmentRating"] as?  Int,
                        let comment = mealInfo.value["comment"] as? String,
                        let userID = mealInfo.value["userID"] as? String
                        else { continue }
                    let meal = Meal(mealName: mealName, price: price,tasteRating: tasteRating, serviceRating: serviceRating, revisitRating: revisitRating, environmentRating: environmentRating, comment: comment)
                    
                    meal.photoString = photoString
                    meal.userID = userID
                    self.meals.append(meal)
                    self.mealPhotoStringArray.append(photoString)
                }
                 self.otherUserMealView.reloadData()
        })
        
        
       
    }
    

    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mealPhotoStringArray.count
    }
    

     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellsquare = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! OtherUserCollectionViewCell
        
        let mealPhotoString = mealPhotoStringArray[indexPath.row]
        if let mealPhotoURL = NSURL(string: mealPhotoString){
            
            cellsquare.photoImage.nk_setImageWith(mealPhotoURL)
            
        }
      return cellsquare
    }

    
    
}
