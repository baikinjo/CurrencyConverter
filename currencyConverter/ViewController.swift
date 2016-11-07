//
//  ViewController.swift
//  currencyConverter
//
//  Created by Injo Baik on 2016-11-06.
//  Copyright © 2016 Injo Baik. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var output: UILabel!
    
    var countryCode: [String]   = []
    var ratesValues: [Double]   = []
    var selectedVal: Double     = 0.0
    var selectedCode: String    = ""
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryCode.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return NSString(format: "%@ - %f", countryCode[row], Double(ratesValues[row])) as String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedVal = ratesValues[row]
        selectedCode = countryCode[row]
    }
    
    func getSymbolForCurrencyCode(code: String) -> String?{
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code)
    }
    
    @IBAction func convert(_ sender: AnyObject) {
        if(input.text != ""){
            output.text = "CAD $\(input.text!) to \(selectedCode) is " + getSymbolForCurrencyCode(code: selectedCode)! + String(format: "%.2f", Double(input.text!)! * selectedVal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://api.fixer.io/latest?base=CAD")
        let task = URLSession.shared.dataTask(with: url!){
            (data, response, error) in
            if error != nil{
                print("Error")
            }else{
                if let content = data{
                    do{
                        let json = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        if let rates = json["rates"] as? NSDictionary{
                            for(key, value) in rates{
                                self.countryCode.append((key as? String)!)
                                self.ratesValues.append((value as? Double)!)
                            }
                        }
                    }catch{
                        
                    }
                }
            }
            self.pickerView.reloadAllComponents()
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

