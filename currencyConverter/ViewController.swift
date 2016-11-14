//
//  ViewController.swift
//  currencyConverter
//
//  Created by Injo Baik on 2016-11-06.
//  Copyright © 2016 Injo Baik. All rights reserved.
//

import UIKit
import SystemConfiguration

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    
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
    
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.input.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.input.resignFirstResponder()
    }
    
    
    
    @IBAction func convert(_ sender: AnyObject) {
        if(input.text != ""){
            var initial: Double = Double(input.text!)!
            var result: Double = initial * selectedVal
            initial = initial.roundTo(places: 2)
            result = result.roundTo(places: 2)
            let numFormat = NumberFormatter()
            numFormat.numberStyle = NumberFormatter.Style.decimal
            
            output.text = "CAD $" + numFormat.string(from: NSNumber(value: initial))! + " to \(selectedCode) is " + getSymbolForCurrencyCode(code: selectedCode)! + numFormat.string(from: NSNumber(value: result))!
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        input.delegate = self
        self.hideKeyboardWhenTappedAround()
        self.addDoneButtonOnKeyboard()
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
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let tempRange = textField.text?.range(of: ".", options: NSString.CompareOptions.literal, range: nil, locale: nil)
        if tempRange?.isEmpty == false && string == "." {
            return false
        }
        
        return true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        if Reachability.isConnectedToNetwork() == true
        {
            print("Connected")
        }
        else
        {
            let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            controller.addAction(ok)
            
            present(controller, animated: true, completion: nil)
        }
        
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


