//
//  ViewController.swift
//  Lake Weather
//
//  Created by Todd Perkins on 4/16/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class DayData2015: Object {
    let date = RealmOptional<Int>()
    @objc dynamic var time: String? = nil
    let AirTemp = RealmOptional<Double>()
    let BarometricPress = RealmOptional<Double>()
    let DewPoint = RealmOptional<Double>()
    let RelativeHumidity = RealmOptional<Double>()
    let WindDir = RealmOptional<Double>()
    let WindGust = RealmOptional<Int>()
    let WindSpeed = RealmOptional<Double>()
}

class ViewController: UIViewController {
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var medianSpeedLabel: UILabel!
    @IBOutlet weak var meanSpeedLabel: UILabel!
    @IBOutlet weak var meanPressureLabel: UILabel!
    @IBOutlet weak var medianPressureLabel: UILabel!
    @IBOutlet weak var meanTempLabel: UILabel!
    @IBOutlet weak var medianTempLabel: UILabel!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!
    
    var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        activityView.isHidden = true
        loadRealm()
    }
    
    
    @IBAction func didPressUpdate(_ sender: Any) {
        activityView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.updateDays()
            self.activityView.isHidden = true
        }
        
    }
    
    @IBAction func startDateDidChange(_ sender: UIDatePicker) {
        // make sure end date is after start date
        if startPicker.date >= endPicker.date {
            //print("start date is after end date")
            endPicker.date = startPicker.date
        }
    }
    @IBAction func endDateDidChange(_ sender: UIDatePicker) {
        // make sure start date is before end date
        if startPicker.date >= endPicker.date {
            //print("start date is after end date")
            startPicker.date = endPicker.date
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Convinienve Methods
    
    // MARK: View loads
    func loadRealm() {
        let fileManger = FileManager.default
        let documentURL = fileManger.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("dayData.realm")
        let baseURL = Bundle.main.url(forResource: "dayData", withExtension: "realm")
        
        do {
        guard let baseURL = baseURL else { fatalError() }
            if !fileManger.fileExists(atPath: documentURL.path) {
                try fileManger.copyItem(at: baseURL, to: documentURL)
            }
        
            var config = Realm.Configuration()
            config.objectTypes = [DayData2015.self]
            config.fileURL = documentURL
                
            realm = try Realm(configuration: config)
        
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Actions
    
    func updateDays() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let startDate = Int(formatter.string(from: startPicker.date))
        let endDate = Int(formatter.string(from: endPicker.date))
        
        let data: Results<DayData2015> = realm.objects(DayData2015.self).filter("date >= \(startDate!) && date <= \(endDate!)")
        
        //// Validate Data
        if data.count < 2 {
            showMessage(message: "Insufficient Data, please choose longer end date")
            return
        }
        
        guard (data[0].date.value! == startDate) else {
            showMessage(message: "No value for start date")
            return
        }
        guard (data.last!.date.value! == endDate) else {
            showMessage(message: "No value for end date")
            return
        }
        ///
            
        updateDataLabel(from: data)
        
    }
    
    func updateDataLabel(from data: Results<DayData2015>) {
        var temps: [Double] = []
        var speeds: [Double] = []
        var pressures: [Double] = []
        
        for day: DayData2015 in data {
            temps.append(day.AirTemp.value!)
            speeds.append(day.WindSpeed.value!)
            pressures.append(day.BarometricPress.value!)
        }
        
        medianSpeedLabel.text = "Median Speed: "+String(format: "%.2f", median(of: speeds))
        meanSpeedLabel.text = "Mean Speed: "+String(format: "%.2f", mean(of: speeds))
        
        medianTempLabel.text = "Median Temperature: "+String(format: "%.2f", median(of: temps))
        meanTempLabel.text = "Mean Temperature: "+String(format: "%.2f", mean(of: temps))
        
        medianPressureLabel.text = "Median Pressure: "+String(format: "%.2f",median(of: pressures))
        meanPressureLabel.text = "Mean Pressure: "+String(format: "%.2f",mean(of: pressures))
        
    }
    
    func showMessage(message:String) {
        let alert = UIAlertController(title: "Missing Data", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Helper Method
    
    func mean(of a:[Double]) -> Double {
        var sum = 0.0
        
        for i in 0...a.count-1 {
            sum += a[i]
        }
        
        return sum/Double(a.count)
    }
    
    func median(of a:[Double]) -> Double {
        var result: Double = 0
        if a.count % 2 != 0 {
            result = a.sorted()[(a.count + 1)/2]
        } else if a.count % 2 == 0 {
            result = (a.sorted()[a.count/2] + a.sorted()[a.count/2 + 1])/2
        }
        
        return result
    }
    
    
}



