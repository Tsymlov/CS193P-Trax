//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Alexey Tsymlov on 10/13/15.
//  Copyright © 2015 Alexey Tsymlov. All rights reserved.
//

import UIKit
import MobileCoreServices

class EditWaypointViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var waypointToEdit: EditableWaypoint?{
        didSet{
            updateUI()
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField!{ didSet{ nameTextField.delegate = self } }
    @IBOutlet weak var infoTextField: UITextField!{ didSet{ infoTextField.delegate = self } }
    
    func updateUI(){
        nameTextField?.text = waypointToEdit?.name
        infoTextField?.text = waypointToEdit?.info
        updateImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        nameTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeTextFields()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = ntfObserver{
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let observer = itfObserver{
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    @IBAction func done(sender: AnyObject) {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var ntfObserver: NSObjectProtocol?
    var itfObserver: NSObjectProtocol?
    
    func observeTextFields(){
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        ntfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: nameTextField, queue: queue){ notification in
            if let waypoint = self.waypointToEdit {
                waypoint.name = self.nameTextField.text
            }
        }
        itfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification, object: infoTextField, queue: queue){ notification in
            if let waypoint = self.waypointToEdit {
                waypoint.info = self.infoTextField.text
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Image
    
    var imageView = UIImageView()
    @IBOutlet weak var imageViewContainer: UIView! {
        didSet{
            imageViewContainer.addSubview(imageView)
        }
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera){
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            picker.allowsEditing = true
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        imageView.image = image
        makeRoomForImage()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension EditWaypointViewController
{
    func updateImage() {
        if let url = waypointToEdit?.imageURL {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                if let imageData = NSData(contentsOfURL: url) {
                    if url == self?.waypointToEdit?.imageURL {
                        if let image = UIImage(data: imageData) {
                            dispatch_async(dispatch_get_main_queue()) {
                                self?.imageView.image = image
                                self?.makeRoomForImage()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func makeRoomForImage() {
        var extraHeight: CGFloat = 0
        if imageView.image?.aspectRatio > 0 {
            if let width = imageView.superview?.frame.size.width {
                let height = width / imageView.image!.aspectRatio
                extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        } else {
            extraHeight = -imageView.frame.height
            imageView.frame = CGRectZero
        }
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}