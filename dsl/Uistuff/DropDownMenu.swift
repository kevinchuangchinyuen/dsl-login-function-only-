//
//  DropDownMenu.swift
//  dsl
//
//  Created by chuang chin yuen on 25/1/2024.
//

import SwiftUI

struct DropdownMenu: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var isOptionsPresented: Bool = false
    @Binding var selectedOption: DropDownMenuOption?
    @State var tempOption: Int?
    @State private var currentLanguage: String = ""
    
    let placeholder: String
    let options: [DropDownMenuOption]
    let color: Color
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.isOptionsPresented.toggle()
            }
            self.endTextEditing()
        }) {
            VStack(spacing: 0) {
                HStack {
                    Text(selectedOption == nil ? placeholder.localized(localizationManager.language) : selectedOption!.label.localized(SelectedLanguage(rawValue: currentLanguage) ?? .English))
                        .contentStyle()
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: self.isOptionsPresented ? "chevron.up" : "chevron.down")
                        .foregroundColor(.black)
                }
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                            .background(color)
                            .frame(height: 50)
                    }
                )
                
                if self.isOptionsPresented {
                    DropdownMenuList(options: self.options) { option in
                        self.isOptionsPresented = false
                        self.selectedOption = option
                        self.tempOption = self.selectedOption?.id
                        self.currentLanguage = self.localizationManager.language.rawValue
                    }
                }
            }
        }
//        .onReceive(localizationManager.$language) { newLanguage in
//            if newLanguage.rawValue != currentLanguage {
//                self.currentLanguage = newLanguage.rawValue
//                self.selectedOption = self.options.first(where: { $0.id == self.tempOption })
//            }
//        }
    }
    
    func setIdToZero() {
        self.selectedOption!.id = 0
    }
}


struct DropdownMenu1: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager

    /// Used to show or hide drop-down menu options
    @State private var isOptionsPresented: Bool = false
    
    /// Used to bind user selection
    @Binding var selectedOption: DropDownMenuOption?
    
    @State var tempOption: Int?
    
    /// A placeholder for drop-down menu
    let placeholder: String
    
    /// The drop-down menu options
    let options: [DropDownMenuOption]
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.isOptionsPresented.toggle()
            }
            self.endTextEditing()
        }) {
            VStack(spacing: 0){
                HStack {
                    Text(selectedOption == nil ? placeholder.localized(localizationManager.language) : selectedOption!.label.localized(localizationManager.language))
                    //.fontWeight(.medium)
                        //.foregroundColor(selectedOption == nil ? .gray : .black)
                        .contentStyle()
                    
                    Spacer()
                    
                    Image(systemName: self.isOptionsPresented ? "chevron.up" : "chevron.down")
                    // This modifier available for Image since iOS 16.0
                        .foregroundColor(.black)
                }
                //.onAppear(perform: setIdToZero)
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                            .background(Color.white)
                            .frame(height: 50)
                        // Additional overlay content here
                    }
                )
                
                //Spacer().frame(height: 100)
                
                if self.isOptionsPresented {
                    //Spacer(minLength: 60)
                    DropdownMenuList(options: self.options) { option in
                        self.isOptionsPresented = false
                        self.selectedOption = option
                        self.tempOption = self.selectedOption?.id
                    }
                }
            }
        }
        .onReceive(localizationManager.$language) { newLanguage in
            if let option = options.first(where: { $0.id == tempOption }) {
                selectedOption = option
            }
        }

//        .onChange(of: Locale.preferredLanguages.first) { newValue in
////            localizationManager.language = .RawValue(value: newValue?.value!)
//            self.selectedOption =  self.options.first(where: { $0.id == self.tempOption})
//        }
        //.padding()
//        .overlay {
//            RoundedRectangle(cornerRadius: 5)
//                .stroke(.gray, lineWidth: 2)
//        }
//        .overlay(alignment: .top) {
//            VStack {
//                if self.isOptionsPresented {
//                    Spacer(minLength: 60)
//                    DropdownMenuList(options: self.options) { option in
//                        self.isOptionsPresented = false
//                        self.selectedOption = option
//                    }
//                }
//            }
//        }
//        .background(
//            VStack {
//                if self.isOptionsPresented {
//                    Spacer(minLength: 60)
//                    DropdownMenuList(options: self.options) { option in
//                        self.isOptionsPresented = false
//                        self.selectedOption = option
//                    }
//                }
//            }
//        )
        //.padding(.horizontal)
//        .customLeftRightPadding()
        // We need to push views under drop down menu down, when options list is
        // open
//        .padding(
//            // Check if options list is open or not
//            .bottom, self.isOptionsPresented
//            // If options list is open, then check if options size is greater
//            // than 300 (MAX HEIGHT - CONSTANT), or not
//            ? CGFloat(self.options.count * 32) > 300
//                // IF true, then set padding to max height 300 points
//                ? 300 + 30 // max height + more padding to set space between borders and text
//                // IF false, then calculate options size and set padding
//                : CGFloat(self.options.count * 32) + 30
//            // If option list is closed, then don't set any padding.
//            : 0
//        )
        
    }
    
//    func setIdToZero() {
//        self.selectedOption!.id = 0
//    }

}

struct DropdownMenuList: View {
    
    /// The drop-down menu list options
    let options: [DropDownMenuOption]
    
    /// An action called when user select an action.
    let onSelectedAction: (_ option: DropDownMenuOption) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(options) { option in
                    DropdownMenuListRow(option: option, onSelectedAction: self.onSelectedAction)
                }
            }
        }
        // Check first if number of options * 32 (Option height - CONSTANT - YOU
        // MAY CHANGE IT) is greater than 300 (MAX HEIGHT - ALSO, YOU MAY CHANGE
        // IT), if true, then make it options list scroll, if not set frame only
        // for available options.
        .frame(height: CGFloat(self.options.count * 32) > 300
               ? 300
               : CGFloat(self.options.count * 32)
        )
        .padding(.vertical, 5)
//        .overlay {
//            RoundedRectangle(cornerRadius: 5)
//                .stroke(.gray, lineWidth: 2)
//        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 1)
                    .background(Color.white)
                // Additional overlay content here
            }
        )

    }
}

struct DropdownMenuListRow: View {
    
    let option: DropDownMenuOption
    
    /// An action called when user select an action.
    let onSelectedAction: (_ option: DropDownMenuOption) -> Void
    
    var body: some View {
        Button(action: {
            self.onSelectedAction(option)
        }) {
            Text(option.label)
                .contentStyle()
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .foregroundColor(.black)
        .padding(.vertical, 5)
        .padding(.horizontal)
    }
}

struct DropDownMenuOption: Identifiable, Hashable {
    //let id = UUID().uuidString
    var id: Int
    let value: String
    let label: String
    
}

extension DropDownMenuOption {
    //static let testSingleMonth: DropDownMenuOption = DropDownMenuOption(option: "March")
    
    static func GenderOption(localizationManager: LocalizationManager) -> [DropDownMenuOption] {
        [
            DropDownMenuOption(id: 0, value: "", label: "--- Gender ---".localized(localizationManager.language)),
            DropDownMenuOption(id: 1, value: "M", label: "Male".localized(localizationManager.language)),
            DropDownMenuOption(id: 2, value: "F", label: "Female".localized(localizationManager.language))
        ]
    }
    
        
    struct dataFromJson: Decodable {
        let value: String?
        let label: String
    }
    
    static func readCountriesFromJSON(localizationManager: LocalizationManager) -> [DropDownMenuOption]? {
        if let url = Bundle.main.url(forResource: "countries", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let decodedDatas = try decoder.decode([dataFromJson].self, from: data)
                
                let dropDownMenuOptions = decodedDatas.enumerated().map { (index, decodedData) in
                    let value = (index == 0) ? "" : decodedData.label
                    return DropDownMenuOption(id: index, value: value, label: decodedData.label.localized(localizationManager.language))
                }
                
                return dropDownMenuOptions
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        return nil
    }

    static func readAreaOfResidenceFromJSON(localizationManager: LocalizationManager) -> [DropDownMenuOption]? {
        if let url = Bundle.main.url(forResource: "areaofresidence", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let decodedDatas = try decoder.decode([dataFromJson].self, from: data)
                
                let dropDownMenuOptions = decodedDatas.enumerated().map { (index, decodedData) in
                    let value = (index == 0) ? "" : decodedData.label
                    return DropDownMenuOption(id: index, value: value, label: decodedData.label.localized(localizationManager.language))
                }
                
                return dropDownMenuOptions
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        return nil
    }
    
    static func readAreaCodeFromJSON(localizationManager: LocalizationManager) -> [DropDownMenuOption]? {
        if let url = Bundle.main.url(forResource: "areacode", withExtension: "json"){
            if let url1 = Bundle.main.url(forResource: "countries", withExtension: "json"){
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let decodedDatas = try decoder.decode([dataFromJson].self, from: data)
                    
                    let data1 = try Data(contentsOf: url1)
                    let decodedDatas1 = try decoder.decode([dataFromJson].self, from: data1)

                    
                    var dropDownMenuOptions = decodedDatas.enumerated().map { (index, decodedData) -> DropDownMenuOption in
                        let decodedData1 = decodedDatas1[index]
                        let value = (index == 0) ? "" : decodedData.value!
                        let label = (index == 0) ? "--- Area Code ---".localized(localizationManager.language) : "(+\(decodedData.value!))  \(decodedData1.label.localized(localizationManager.language))"
                        
                        return DropDownMenuOption(id: index, value: value, label: label)
                    }
                    
                    if dropDownMenuOptions.indices.contains(1) && dropDownMenuOptions.indices.contains(2) {
                        let tempOption = dropDownMenuOptions[1]
                        dropDownMenuOptions[1] = dropDownMenuOptions[2]
                        dropDownMenuOptions[2] = tempOption
                        
                        // Swap the id values as well
                        dropDownMenuOptions[1].id = 1
                        dropDownMenuOptions[2].id = 2
                    }
                    return dropDownMenuOptions
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        return nil
    }
    
    static func readDocumentTypesFromJSON(localizationManager: LocalizationManager) -> [DropDownMenuOption]? {
        if let url = Bundle.main.url(forResource: "documenttype", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let decodedDatas = try decoder.decode([dataFromJson].self, from: data)
                
                let dropDownMenuOptions = decodedDatas.enumerated().map { (index, decodedData) in
                    let value = (index == 0) ? "" : decodedData.label
                    return DropDownMenuOption(id: index, value: value, label: decodedData.label.localized(localizationManager.language))
                }
                
                return dropDownMenuOptions
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        return nil
    }

    
    static func readOcuupationsFromJSON(localizationManager: LocalizationManager) -> [DropDownMenuOption]? {
        if let url = Bundle.main.url(forResource: "occupation", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let decodedDatas = try decoder.decode([dataFromJson].self, from: data)
                
                let dropDownMenuOptions = decodedDatas.enumerated().map { (index, decodedData) in
                    let value = (index == 0) ? "" : decodedData.label
                    return DropDownMenuOption(id: index, value: value, label: decodedData.label.localized(localizationManager.language))
                }
                
                return dropDownMenuOptions
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        return nil
    }

    //struct DropdownMenu_Previews: PreviewProvider {
    //    static var previews: some View {
    //        DropdownMenu(
    //            selectedOption: .constant(nil),
    //            placeholder: "Select your birth month",
    //            options: GenderMenuOption.testAllMonths
    //        )
    //    }
    //}
    //
    //struct DropdownMenuList_Previews: PreviewProvider {
    //    static var previews: some View {
    //        DropdownMenuList(options: GenderMenuOption.testAllMonths, onSelectedAction: { _ in })
    //    }
    //}
    //
    //struct DropdownMenuListRow_Previews: PreviewProvider {
    //    static var previews: some View {
    //        DropdownMenuListRow(option: GenderMenuOption.testSingleMonth, onSelectedAction: { _ in })
    //    }
    //}
}

//static func AreaOfResidenceOption(localizationManager: LocalizationManager) -> [DropDownMenuOption] {
//    [
//        DropDownMenuOption(id: 0, value: "", label: "--- Area of Residence ---"),
//        DropDownMenuOption(id: 1, value: "The Mainland of China", label: "The Mainland of China".localized(localizationManager.language)),
//        DropDownMenuOption(id: 2, value: "Hong Kong, China", label: "Hong Kong, China".localized(localizationManager.language)),
//        DropDownMenuOption(id: 3, value: "Macao, China", label: "Macao, China".localized(localizationManager.language)),
//        DropDownMenuOption(id: 4, value: "Taiwan, China", label: "Taiwan, China".localized(localizationManager.language)),
//        DropDownMenuOption(id: 5, value: "Afghanistan", label: "Afghanistan"),
//        DropDownMenuOption(id: 6, value: "Albania", label: "Albania"),
//        DropDownMenuOption(id: 7, value: "Algeria", label: "Algeria"),
//        DropDownMenuOption(id: 8, value: "Andorra", label: "Andorra"),
//        DropDownMenuOption(id: 9, value: "Angola", label: "Angola"),
//        DropDownMenuOption(id: 10, value: "Antarctica", label: "Antarctica"),
//        DropDownMenuOption(id: 11, value: "Argentina", label: "Argentina"),
//        DropDownMenuOption(id: 12, value: "Armenia", label: "Armenia"),
//        DropDownMenuOption(id: 13, value: "Aruba", label: "Aruba"),
//        DropDownMenuOption(id: 14, value: "Australia", label: "Australia"),
//        DropDownMenuOption(id: 15, value: "Austria", label: "Austria"),
//        DropDownMenuOption(id: 16, value: "Azerbaijan", label: "Azerbaijan"),
//        DropDownMenuOption(id: 17, value: "Bahrain", label: "Bahrain"),
//        DropDownMenuOption(id: 18, value: "Bangladesh", label: "Bangladesh"),
//        DropDownMenuOption(id: 19, value: "Belarus", label: "Belarus"),
//        DropDownMenuOption(id: 20, value: "Belgium", label: "Belgium"),
//        DropDownMenuOption(id: 21, value: "Belize", label: "Belize"),
//        DropDownMenuOption(id: 22, value: "Benin", label: "Benin"),
//        DropDownMenuOption(id: 23, value: "Bhutan", label: "Bhutan"),
//        DropDownMenuOption(id: 24, value: "Bolivia", label: "Bolivia"),
//        DropDownMenuOption(id: 25, value: "Bosnia and Herzegovina", label: "Bosnia and Herzegovina"),
//        DropDownMenuOption(id: 26, value: "Botswana", label: "Botswana"),
//        DropDownMenuOption(id: 27, value: "Brazil", label: "Brazil"),
//        DropDownMenuOption(id: 28, value: "British Indian Ocean Territory", label: "British Indian Ocean Territory"),
//        DropDownMenuOption(id: 29, value: "Brunei", label: "Brunei"),
//        DropDownMenuOption(id: 30, value: "Bulgaria", label: "Bulgaria"),
//        DropDownMenuOption(id: 31, value: "Burkina Faso", label: "Burkina Faso"),
//        DropDownMenuOption(id: 32, value: "Burundi", label: "Burundi"),
//        DropDownMenuOption(id: 33, value: "Cambodia", label: "Cambodia"),
//        DropDownMenuOption(id: 34, value: "Cameroon", label: "Cameroon"),
//        DropDownMenuOption(id: 35, value: "Canada", label: "Canada"),
//        DropDownMenuOption(id: 36, value: "Cape Verde", label: "Cape Verde"),
//        DropDownMenuOption(id: 37, value: "Central African Republic", label: "Central African Republic"),
//        DropDownMenuOption(id: 38, value: "Chad", label: "Chad"),
//        DropDownMenuOption(id: 39, value: "Chile", label: "Chile")
//    ]
//}

//static func AreaCodeOption(localizationManager: LocalizationManager) -> [DropDownMenuOption] {
//    [
//        DropDownMenuOption(id: 0, value: "", label: "--- Area Code ---"),
//        DropDownMenuOption(id: 1, value: "852", label: "(+852) Hong Kong, China".localized(localizationManager.language)),
//        DropDownMenuOption(id: 2, value: "86", label: "(+86) The Mainland of China".localized(localizationManager.language)),
//        DropDownMenuOption(id: 3, value: "853", label: "(+853) Macao, China".localized(localizationManager.language)),
//        DropDownMenuOption(id: 4, value: "243", label: "(+243) Democratic Republic of congo".localized(localizationManager.language))
//    ]
//}
