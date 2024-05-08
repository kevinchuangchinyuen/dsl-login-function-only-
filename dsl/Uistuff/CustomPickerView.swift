//
//  CustomPickerView.swift
//  dsl
//
//  Created by chuang chin yuen on 26/3/2024.
//

import SwiftUI
import UIKit

struct DatePickerTextField: UIViewRepresentable {
    
    @EnvironmentObject var localizationManager: LocalizationManager

    private let textField = UITextField()
    private let datePicker = UIDatePicker()

    private let helper = Helper()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    public var placeHolder: String
    @Binding public var date: Date?
    
    func makeUIView(context: Context) -> UITextField {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self.helper, action: #selector(self.helper.dateValueChanged), for: .valueChanged)
        self.datePicker.locale = Locale(identifier: self.localizationManager.language.rawValue)
//        if let userDate = date{
//            print(date)
//            self.datePicker.date = userDate
//        }
        self.textField.placeholder = self.placeHolder.localized(localizationManager.language)
        self.textField.inputView = self.datePicker
        
        // Accessory View
        let toolbar = UIToolbar()
        toolbar.tintColor = .black
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done".localized(localizationManager.language), style: .plain, target: self.helper, action: #selector(self.helper.doneButtonAction))
        let clearButton = UIBarButtonItem(title: "Clear".localized(localizationManager.language), style: .plain, target: self.helper, action: #selector(self.helper.clearButtonAction))
        toolbar.setItems([clearButton, flexibleSpace, doneButton], animated: true)
        self.textField.inputAccessoryView = toolbar
        
        self.helper.dateChanged = {
            self.date = self.datePicker.date
        }
        
        self.helper.doneButtonTapped = {
            if self.date == nil {
                self.date = self.datePicker.date
            }
            self.textField.resignFirstResponder()
        }
        
        self.helper.clearButtonTapped = {
            self.date = nil
            self.textField.text = ""
            self.textField.resignFirstResponder()
        }
        return self.textField
    }
    
    func updatePlaceholder(_ textField: UITextField) {
        textField.placeholder = self.placeHolder.localized(localizationManager.language)
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if let selectedDate = self.date {
            uiView.text = self.dateFormatter.string(from: selectedDate)
        }
        updatePlaceholder(uiView)
    }
    
    func makeCoordinator() -> Coordinator{
        Coordinator()
    }
    
    class Helper {
        public var dateChanged: (() -> Void)?
        public var doneButtonTapped: (() -> Void)?
        public var clearButtonTapped: (() -> Void)?
        
        @objc func dateValueChanged() {
            self.dateChanged?()
        }
        
        @objc func doneButtonAction() {
            self.doneButtonTapped?()
        }
        
        @objc func clearButtonAction() {
            self.clearButtonTapped?()
        }
    }
    
    class Coordinator {
        
    }
    
}

struct NumberPickerTextField: UIViewRepresentable {
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    private let textField = UITextField()
    private let numberPicker = UIPickerView()
    
    public var placeHolder: String
    @Binding public var selectedNumber: Int?
    
//    public var newNumber: Int?
    
//    @Binding public var newNumber: Int?

    private let helper = Helper()
    
    func makeUIView(context: Context) -> UITextField {
        
        self.numberPicker.delegate = context.coordinator
        self.numberPicker.dataSource = context.coordinator
        self.textField.placeholder = self.placeHolder.localized(localizationManager.language)
        self.textField.inputView = self.numberPicker
        
        if let selectedNumber = self.selectedNumber {
            if let selectedIndex = (0..<10).firstIndex(of: selectedNumber) {
                self.numberPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
            }
        }
        // Accessory View
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "PickerStyle.button1".localized(localizationManager.language),
                                         style: .plain,
                                         target: self.helper,
                                         action: #selector(self.helper.doneButtonAction))
        let clearButton = UIBarButtonItem(title: "PickerStyle.button2".localized(localizationManager.language),
                                          style: .plain,
                                          target: self.helper,
                                          action: #selector(self.helper.clearButtonAction))
        toolbar.setItems([clearButton, flexibleSpace, doneButton], animated: true)
        self.textField.inputAccessoryView = toolbar
        
        self.helper.doneButtonTapped = {
            self.textField.resignFirstResponder()
        }

        self.helper.clearButtonTapped = {
            self.selectedNumber = nil
            self.textField.text = ""
            self.textField.resignFirstResponder()
        }

        return self.textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if let selectedNumber = self.selectedNumber {
            uiView.text = "\(selectedNumber)"
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: NumberPickerTextField
        
        init(_ parent: NumberPickerTextField) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return 10
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return "\(row + 1)"
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.parent.selectedNumber = row + 1
        }
    }
        
    class Helper {
        public var doneButtonTapped: (() -> Void)?
        public var clearButtonTapped: (() -> Void)?
        
        @objc func doneButtonAction() {
            self.doneButtonTapped?()
        }
        
        @objc func clearButtonAction() {
            self.clearButtonTapped?()
        }
    }

}

struct CustomPickerTextField: UIViewRepresentable {
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
//    @State private var isEditing = false

    private let textField = SuperProtectedTextField()
    private let pickerView = UIPickerView()
    
    public var placeHolder: String
    @Binding public var selectedOption: DropDownMenuOption?
    public var options: [DropDownMenuOption]
    
    private let helper = Helper()
    
    func makeUIView(context: Context) -> UITextField {
        self.pickerView.delegate = context.coordinator
        self.pickerView.dataSource = context.coordinator
        self.textField.placeholder = self.placeHolder
        self.textField.inputView = self.pickerView
        self.textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Accessory View
        let toolbar = UIToolbar()
        toolbar.tintColor = .black
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "PickerStyle.button1".localized(localizationManager.language),
                                         style: .plain,
                                         target: self.helper,
                                         action: #selector(self.helper.doneButtonAction))
        let clearButton = UIBarButtonItem(title: "PickerStyle.button2".localized(localizationManager.language),
                                          style: .plain,
                                          target: self.helper,
                                          action: #selector(self.helper.clearButtonAction))
        toolbar.setItems([clearButton, flexibleSpace, doneButton], animated: true)
        self.textField.inputAccessoryView = toolbar
        
        self.helper.doneButtonTapped = {
            self.textField.resignFirstResponder()
        }
        
        self.helper.clearButtonTapped = {
            self.selectedOption = options.first(where: { $0.id == 0 })
            self.textField.resignFirstResponder()
        }
        
        self.textField.font = UIFont(name: "Arial", size: 16)
                
        let chevronImage = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevronImage.tintColor = .black
        self.textField.rightView = chevronImage
        self.textField.rightViewMode = .unlessEditing
        
        return self.textField
    }
    
    func updateLocale(_ textField: UITextField) {
        textField.placeholder = self.placeHolder.localized(localizationManager.language)
//        if let haveoptions = self.selectedOption{
//            textField.text = haveoptions.label.localized(localizationManager.language)
        //        }
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if let selectedOption = self.selectedOption {
            uiView.text = selectedOption.label.localized(localizationManager.language)
        }
        updateLocale(uiView)
//        if uiView.isEditing != isEditing {
//            isEditing = uiView.isEditing
//            let chevronImage = UIImageView(image: UIImage(systemName: isEditing ? "chevron.up" : "chevron.down"))
//            chevronImage.tintColor = .black
//            self.textField.rightView = chevronImage
//        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, localizationManager: localizationManager, initialSelectedOption: selectedOption)
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        
        var parent: CustomPickerTextField
        var localizationManager: LocalizationManager
        var initialSelectedOption: DropDownMenuOption? // New property to store the initial selected option
        
        init(_ parent: CustomPickerTextField, localizationManager: LocalizationManager, initialSelectedOption: DropDownMenuOption?) {
            self.parent = parent
            self.localizationManager = localizationManager
            self.initialSelectedOption = initialSelectedOption // Set the initial selected option
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return parent.options.count
        }
        
//        func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//            let option = parent.options[row]
//            let attributes: [NSAttributedString.Key: Any] = [
//                .font: UIFont(name: "Arial", size: 16)!, // Custom font and size
//                .foregroundColor: UIColor.black // Custom text color
//            ]
//            return NSAttributedString(string: option.label.localized(localizationManager.language), attributes: attributes)
//        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return parent.options[row].label.localized(localizationManager.language)
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.parent.selectedOption = parent.options[row]
        }
        
//        func updateSelectedOption() {
//            if let initialSelectedOption = initialSelectedOption {
//                if let selectedIndex = parent.options.firstIndex(where: { $0.id == initialSelectedOption.id }) {
//                    DispatchQueue.main.async {
//                        pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
//                        self.parent.selectedOption = initialSelectedOption
//                    }
//                }
//            }
//        }
    }
    
    class Helper {
        public var doneButtonTapped: (() -> Void)?
        public var clearButtonTapped: (() -> Void)?
        
        @objc func doneButtonAction() {
            self.doneButtonTapped?()
        }
        
        @objc func clearButtonAction() {
            self.clearButtonTapped?()
        }
    }
}

//extension CustomPickerTextField: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        return false // Disallow any changes to the text
//    }
//}
