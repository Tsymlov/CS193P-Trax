//
//  WaypointImageViewController.swift
//  Trax
//
//  Created by Alexey Tsymlov on 10/28/15.
//  Copyright © 2015 Alexey Tsymlov. All rights reserved.
//

import UIKit

class WaypointImageViewController: ImageViewController {

    var waypoint: GPX.Waypoint? {
        didSet{
            imageURL = waypoint?.imageURL
            title = waypoint?.name
            updateEmbeddedMap()
        }
    }
    
    var smvc: SimpleMapViewController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Embed Segue" {
            smvc = segue.destinationViewController as? SimpleMapViewController
            updateEmbeddedMap()
        }
    }
    
    func updateEmbeddedMap(){
        if let mapView = smvc?.mapView {
            mapView.mapType = .Hybrid
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(waypoint!)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }

}
