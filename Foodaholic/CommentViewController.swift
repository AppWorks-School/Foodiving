//
//  CommentViewController.swift
//  Foodaholic
//
//  Created by onechun🌾 on 2016/9/30.
//  Copyright © 2016年 onechun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import Fusuma
import IQKeyboardManagerSwift

protocol CommentFromRestViewControllerdelegate: class {
    func didget()
}
protocol CommentFromDetailViewControllerDelegate: class {
    func didEdit()
}



class CommentViewController: UIViewController,UITextFieldDelegate,UINavigationControllerDelegate,FusumaDelegate,UITextViewDelegate {
    
    //Mark: Properties
    
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var mealNameTextField: UITextField!
    @IBOutlet weak var priceNameLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var tasteRateLabel: UILabel!
    @IBOutlet weak var tasteRatingControl: RatingControl!
    @IBOutlet weak var serviceRateLabel: UILabel!
    @IBOutlet weak var serviceRatingControl: RatingControlService!
    @IBOutlet weak var revisitRateLabel: UILabel!
    @IBOutlet weak var revisitRatingControl: RatingControlRevisit!
    @IBOutlet weak var environmentRatingControl: RatingControlEnvironment!
    @IBOutlet weak var environmentRateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var PostButton: UIBarButtonItem!
    var meal: Meal?
    var restDictionary: [String: AnyObject] = [:]
    weak var delegate: CommentFromRestViewControllerdelegate?
    var isPost: Bool = true
    //    let constraint: NSLayoutConstraint?
    
    
    //Mark: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Mark: commentTextView
        commentTextView.delegate = self
        commentTextView.editable = true
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1).CGColor
        
        
        
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        // 使圖案透視 可使用照片點選(autolayout完看是否需要）
        // photoImageView.userInteractionEnabled = true
        
        mealNameTextField.delegate = self
        priceTextField.delegate = self
        priceTextField.keyboardType = .NumberPad //只能輸入數字
        self.hideKeyboardWhenTappedAround()
        
//        checkValidMealName()
        
        guard
            let meal = meal else {return}
        mealNameTextField.text = meal.mealName
        priceTextField.text = meal.price
        commentTextView.text = meal.comment
        environmentRatingControl.rating = meal.environmentRating
        revisitRatingControl.rating = meal.revisitRating
        tasteRatingControl.rating = meal.tasteRating
        serviceRatingControl.rating = meal.serviceRating
        
        
        
        guard isPost == true else {
            PostButton.title = "Save"
            return}
        
    }
    
    
    func textViewDidBeginEditing(textView: UITextView){
        print("textViewDidBeginEditing")}
    
    func textViewDidEndEditing(textView: UITextView){
        print(textViewDidEndEditing)}
    
    
    
    
    //Mark: Navigation
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if PostButton === sender{
            //Mark: save image in storage
            
            
            let storageRef = FIRStorage.storage().reference
            let maelPhotoFileName = NSUUID().UUIDString
            let mealPhoto = storageRef().child("mealPhoto/\(maelPhotoFileName).jpg")
            
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "Image/jpeg"
            mealPhoto.putData(UIImageJPEGRepresentation(photoImageView.image!, 0.2)!,metadata: metadata){(data,error) in
                if error == nil {
                    print("upload successful")
                    guard let photoString = data?.downloadURL()?.absoluteString else{
                        print("fail to download photoURL")
                        return
                    }
                    
                    self.saveToFirebase(photoString)
                    let destVC = segue.destinationViewController as! ResaturantMealTableViewController
                    destVC.tableView.reloadData()
                    FIRAnalytics.logEventWithName("post_comment", parameters: nil)
                    
                }else{
                    print(error?.localizedDescription)
                }
                
                
            }
        }
        
        
        
    }
    
    //Mark: save To Firebase
    func saveToFirebase(photoString: String){
        
        let mealName = mealNameTextField.text ?? ""
        let price = priceTextField.text ?? "0"
        let tasteRating = Int(tasteRatingControl.rating)
        let serviceRating = Int(serviceRatingControl.rating)
        let revisitRating = Int(revisitRatingControl.rating)
        let environmentRating = Int(environmentRatingControl.rating)
        let comment = commentTextView.text ?? ""
        
        
        //save data in firebase
        
        let mealReference = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let timestamp = FIRServerValue.timestamp()
        
        if isPost == true{
            
            let restaurantID = restDictionary["id"] as? String ?? ""
            
            let mealInfoDatabase: [String: AnyObject] = ["userID": uid!, "mealName": mealName ,"price": price, "tasteRating": tasteRating,"serviceRating": serviceRating, "revisitRating": revisitRating, "environmentRating": environmentRating,"comment": comment,"photoString": photoString,"restaurantId": restaurantID,"timestamp": timestamp]
            
            mealReference.child("RestaurantsComments").childByAutoId().setValue(
                mealInfoDatabase,
                withCompletionBlock:
                {(error, ref) in
                    
                    self.delegate?.didget()
            })
            
        }else{
            
            let restCommentID = meal?.restCommentID ?? ""
            let restaurantID = meal?.restaurantID ?? ""
            let mealInfoDatabase: [String: AnyObject] = ["userID": uid!, "mealName": mealName ,"price": price, "tasteRating": tasteRating,"serviceRating": serviceRating, "revisitRating": revisitRating, "environmentRating": environmentRating,"comment": comment,"photoString": photoString,"restaurantId": restaurantID,"timestamp": timestamp]
            
            
            mealReference.child("RestaurantsComments").child(restCommentID).updateChildValues(mealInfoDatabase, withCompletionBlock: {(error,ref) in
                self.delegate?.didget()
            })
            
        }
    }
    
    
    
    
    
    //Mark: UITextFieldDelegate
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard
        //        textField.resignFirstResponder()
        self.view.endEditing(true)
        return false
    }
    
    
    func priceTextField(priceTextField: UITextField,shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        let invalidCharcters = NSCharacterSet(charactersInString: "0123456789").invertedSet
        return string.rangeOfCharacterFromSet(invalidCharcters,options: [],range: string.startIndex ..< string.endIndex) == nil
        
    }
    
    
    
    
//        func textFieldDidBeginEditing(textField: UITextField) {
//            //打字的時候不能按post button
//            PostButton.enabled = false
//        }
    
    
    
        func checkValidMealName(){
            let mealNametext = mealNameTextField.text ?? ""
            let priceNametext = priceTextField.text ?? ""
//            guard let mealImage = photoImageView.image?.images else{return}
            PostButton.enabled = !mealNametext.isEmpty
            PostButton.enabled = !priceNametext.isEmpty
//            PostButton.enabled = !mealImage.isEmpty
            
        }
    
//        func textFieldDidEndEditing(textField: UITextField) {
//        }
    
    
    
    
    
    
    //Mark: Action
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        //當點擊時 keyboard會關閉
        fusumaLibrary()
        //        mealNameTextField.resignFirstResponder()
        //        priceTextField.resignFirstResponder()
        //        commentTextField.resignFirstResponder()
        
        
        //Mark: create a image picker controller
        let imagePickerController = UIImagePickerController()
        
        
        presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    //Mark: delegate camera withFusuma
    func fusumaLibrary(){
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = false
        self.presentViewController(fusuma, animated: true, completion: nil)
        fusumaBackgroundColor =  UIColor.blackColor()
        fusumaTintColor = UIColor.whiteColor()
        fusumaCropImage = true
    }
    
    func fusumaImageSelected(image: UIImage){
        
        photoImageView.image = image
        
    }
    func fusumaDismissedWithImage(image: UIImage) {
        print("Called just fusumaViewController is dismissed.")
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        print("Called just after a video has been selected")
    }
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
    }
    
    
}



//Mark: 點選任意處可隱藏keyboard
extension UIViewController{
    func hideKeyboardWhenTappedAround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)"
    }
}

