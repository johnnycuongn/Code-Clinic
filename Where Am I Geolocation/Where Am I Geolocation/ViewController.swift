//
//  ViewController.swift
//  Where Am I Geolocation
//
//  Created by Todd Perkins on 3/16/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// data from https://ipinfo.io/geo
struct IPData: Codable {
    var ip:String = ""
    var city:String = ""
    var region:String = ""
    var country:String = ""
    var loc:String = ""
}

class ViewController: UIViewController {
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showIPData()
    }
    
    func showIPData() {
        // google ip
//        let url: URL = URL(string: "https://ipinfo.io/8.8.8.8/geo?token=\(token)")!
        
        // my ip
        let url: URL = URL(string: "https://ipinfo.io/geo")!
        
        // Sample Ip
//        let url: URL = Bundle.main.url(forResource: "data", withExtension: "json")!
        
        let decoder = JSONDecoder()
        
        do {
            
            let rawData = try Data(contentsOf: url)
            let data: IPData = try decoder.decode(IPData.self, from: rawData)
            
            ipLabel.text = "ip: \(data.ip)"
            countryLabel.text = "country: \(data.country)"
            stateLabel.text = "state: \(data.region)"
            cityLabel.text = "city: \(data.city)"
            
            let coordinates = data.loc.split(separator: ",")
            
            let lat: CLLocationDegrees = CLLocationDegrees(coordinates[0])!
            let long: CLLocationDegrees = CLLocationDegrees(coordinates[1])!
            
            
            let coordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let region = MKCoordinateRegion(center: coordinate2D, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            map.setRegion(region, animated: true)
            
        }
        catch {
            print(error)
        }
        
        
    }

}

