//
//  ViewController.swift
//  parky
//
//  Created by Alexis Suard on 28/02/2016.
//  Copyright © 2016 Alexis Suard. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
//import ModelRocket
import SwiftyJSON

class ViewController: UIViewController, MKMapViewDelegate {

    
    
    @IBOutlet weak var destination: UITextField!
    @IBOutlet weak var bottomView: UIVisualEffectView!
    
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var placeFound: UIButton!
    @IBOutlet weak var destiView: UIView!

    
    
    func findBePark() {
        Alamofire.request(Router.BePark(48.8239601,2.2287879))
            .responseJSON { response in
                switch response.result {
                case .Success:
                    var json = JSON(data: response.data!)
                    
                    let jsonParsed = self.convertStringToDictionary(json["serviceResponse"].string!)
                    let parking = jsonParsed!["result"] as! [String:AnyObject]
                    let resParking = parking["parkings"] as! [[String:AnyObject]]
                    for res in resParking {
                        let coordLatitude = res["coordinate"]!["latitude"] as! CLLocationDegrees
                        let coordLongitude = res["coordinate"]!["longitude"] as! CLLocationDegrees
                        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: coordLatitude, longitude: coordLongitude)
                        
                        let pinAnnotation = PinAnnotation()
                        pinAnnotation.setCoordinate(location)
                        pinAnnotation.title = res["name"] as? String
                        pinAnnotation.imageName = "picto_parking"

                        let addressNumber = res["address"]!["number"]! as? String
                        
                        let addressStreet = res["address"]!["street"]! as? String
                        if addressStreet != nil && addressNumber != nil {
                            pinAnnotation.subtitle = addressNumber! + " " + addressStreet!
                        }
                        
                        
                        self.mapView.addAnnotation(pinAnnotation)
                    }
                case .Failure(let error):
                    print(error)
                }
        }
        

    }
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is PinAnnotation) {
            return nil
        }
        
        let reuseId = "myPin"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
            let btn = UIButton(type: .DetailDisclosure)
            anView!.rightCalloutAccessoryView = btn
        }
        else {
            anView!.annotation = annotation
        }

        let cpa = annotation as! PinAnnotation
        anView!.image = UIImage(named:cpa.imageName)
        
        return anView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let ac = UIAlertController(title: "coucou", message: "allo", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
  
    @IBOutlet weak var findPlace: UITextField!
    @IBOutlet weak var signalPlace: UIButton!
    @IBOutlet weak var findPlaceLabel: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mapView.delegate = self
        customizeDesign()
        let initialLocation = CLLocation(latitude: 48.8245306, longitude: 2.27434189)
        centerMapOnLocation(initialLocation)
        self.mapView.showsPointsOfInterest = false
       
          NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
          NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
          let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
          view.addGestureRecognizer(tap)
        
        
        findBePark()
    }
    
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    @IBAction func searchAddress(sender: AnyObject) {
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = findPlace.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = localSearchResponse?.mapItems[0].name
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
        

    }

    func customizeDesign() {
        signalPlace.addBorder(UIButtonBorderSide.Left, color: UIColor.whiteColor(), width: 1)
        placeFound.addBorder(UIButtonBorderSide.Top, color: UIColor.whiteColor(), width: 1)
        signalPlace.addBorder(UIButtonBorderSide.Top, color: UIColor.whiteColor(), width: 1)
        findPlace.layer.borderColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.49).CGColor
        findPlace.layer.borderWidth = 0.5
        findPlace.attributedPlaceholder = NSAttributedString(string:"Où va-t-on ?",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 25/255.0, green: 181/255.0, blue: 254/255, alpha: 1.0 )])
    }
    
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.bottomViewBottomConstraint.constant = keyboardFrame.size.height - 46
        
        UIView.animateWithDuration(0.2, animations:  {
            self.view.layoutIfNeeded()

        })
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
       self.bottomViewBottomConstraint.constant = 0
        UIView.animateWithDuration(0) {
            self.view.layoutIfNeeded()
        }}
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

