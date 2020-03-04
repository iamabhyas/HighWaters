//
//  ViewController.swift
//  HighWaters
//
//  Created by Techment DEV on 03/03/20.
//  Copyright © 2020 DP. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var floodButton : UIButton!
    
    private var documentRef:DocumentReference!
    private(set) var floods = [Flood]()
    
    private lazy var db:Firestore = {
        let firestoreDB = Firestore.firestore()
        return firestoreDB
    }()
    
    private lazy var locationManager:CLLocationManager = {
        let manager = CLLocationManager()
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
        }
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true

        if let coordinate = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coordinate, animated: true)
        }
        
        configureObservers()
    }

    private func updateAnnotations(){
        DispatchQueue.main.async {
             self.mapView.removeAnnotations(self.mapView.annotations)
            self.floods.forEach{
                self.addFloodToMap($0)
            }
        }
    }
    
    
    func configureObservers(){
        self.db.collection("flooded-regions").addSnapshotListener { [weak self] snapshot, error in
            guard let snapshot = snapshot,
                error == nil else {
                    print("Error Fetching document")
                    return
            }
            snapshot.documentChanges.forEach { diff in
                if diff.type == .added{
                    if let flood = Flood(diff.document){
                        self?.floods.append(flood)
                        self?.updateAnnotations()
                    }
                }else if diff.type == .removed {
                    if let flood = Flood(diff.document){
                        if let floods = self?.floods {
                            self?.floods = floods.filter { $0.documentID != flood.documentID }
                            self?.updateAnnotations()
                        }
                    }
                }
            }
        }
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation){
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span:self.mapView.region.span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "FloodAnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier:"FloodAnnotationView")
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "flood-annotation")
            annotationView?.rightCalloutAccessoryView = UIButton.buttonForRightAccessoryView()
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let floodAnnotation = view.annotation as? FloodAnnotation{
            let flood = floodAnnotation.flood
            self.db.collection("flooded-regions").document(flood.documentID!).delete() {[weak self] error in
                if let error = error {
                    print("Error removing document \(error)")
                }else{
                    print("Document removed")
                    DispatchQueue.main.async {
                        self?.updateAnnotations()
                    }
                }
            }
        }
    }
     
    @IBAction func addAction(){
        savefloodToFirebase()
    }
    
    private func addFloodToMap(_ flood:Flood){
        
        let annotation = FloodAnnotation(flood)
        annotation.title = "Flood"
        annotation.subtitle = flood.reportedDate.formatAsString()
        annotation.coordinate = CLLocationCoordinate2D(latitude: flood.latitude, longitude: flood.longitude)
        mapView.addAnnotation(annotation)
    }
     
    
    private func savefloodToFirebase(){
        guard let location = self.locationManager.location else {
            return
        }
        
        var flood = Flood(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        self.documentRef = self.db.collection("flooded-regions").addDocument(data: flood.toDictinary()){ [weak self] error in
            
            if let error = error{
                print(error)
            }else{
                flood.documentID = self?.documentRef.documentID
                self!.addFloodToMap(flood)
            }
        }
        
       /* self.db.collection("flooded-regions").addDocument(data: ["latitude": 34.34, "longitude": -95.08]){ error in
            if let error = error{
                print(error)
            }else{
                print("data is saved in Firebase Store")
            }
        }*/
    }
}

