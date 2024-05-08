//
//  LinkUpConfirmView.swift
//  dsl
//
//  Created by chuang chin yuen on 4/3/2024.
//

import SwiftUI

struct LinkUpConfirmView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @ObservedObject var linkUpService: LinkUpService
    
    @ObservedObject var service: AuthenticatedViewService
    
    @Binding var currentState: LinkUpState
    
    @State private var email = ""
    @State private var lastName = ""
    @State private var firstName = ""
    @State private var mobileNumber = ""
    @State private var chineseName = ""
    @State private var HKIDNumber = ""
    @State private var HKIDLastNumber = ""
    @State private var identityDocumentID = ""
    @State private var dateOfBirth: Date? = nil
    @State private var dateOfBirthTemp = Date()
    @State private var dateString = ""
    @State private var address = ""
    @State private var company = ""
    @State private var post = ""
    @State private var gender: DropDownMenuOption? = nil
    @State private var areaCode: DropDownMenuOption? = nil
    @State private var passportCountry: DropDownMenuOption? = nil
    @State private var identityDocument: DropDownMenuOption? = nil
    @State private var areaOfResidence: DropDownMenuOption? = nil
    @State private var occupation: DropDownMenuOption? = nil
    
    @State private var isHkMobileNumber: Bool = false
    
    @Binding var username : String

    @Binding var password : String

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var body: some View {
        
        VStack{
            ScrollView(.vertical,showsIndicators: false){
                
                Spacer().frame(height: 20)
                
                VStack(spacing: 20){
                    VStack(alignment: .leading){
                        Text("Register.Label1".localized(localizationManager.language))
                            .foregroundColor(.black)
                            .contentStyle()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(.gray)
                                .background(Color.white)
                            
                            TextField("".localized(localizationManager.language), text: $email)
                            //.customTextField(color: isEmailError ? .red: .gray)
                                .customDisabledTextField()
                                .keyboardType(.emailAddress)
                                .disabled(true)
                        }
                    }
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("Register.Label4".localized(localizationManager.language))
                                .foregroundColor(.black)
                                .contentStyle()
                            
                            Spacer()
                        }
                        
                        TextField("".localized(localizationManager.language), text: $lastName)
                            .customDisabledTextField()
                            .disabled(true)
                    }
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("Register.Label5".localized(localizationManager.language))
                                .foregroundColor(.black)
                                .contentStyle()
                            
                            Spacer()
                        }
                        
                        TextField("".localized(localizationManager.language), text: $firstName)
                            .customDisabledTextField()
                            .disabled(true)
                        
                    }
                    
                    VStack(alignment: .leading){
                        Text("Register.Label6".localized(localizationManager.language))
                            .foregroundColor(.black)
                            .contentStyle()
                        
                        DropdownMenu(
                            selectedOption: self.$areaCode,
                            placeholder: "--- Area Code ---",
                            options: DropDownMenuOption.readAreaCodeFromJSON(localizationManager: self.localizationManager)!,
                            color: Color.customGray
                        )
                        .disabled(true)
                        .onChange(of: areaCode?.id) { newvalue in
                            if(newvalue == 1){              //HK
                                isHkMobileNumber = true
                            }
                            else if(newvalue == 0){
                                isHkMobileNumber = false
                            }
                            else{
                                isHkMobileNumber = false    //others
                            }
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(.gray)
                                .background(Color.white)
                            
                            HStack(spacing: 0){
                                TextField("".localized(localizationManager.language), text: $mobileNumber)
                                    .customDisabledTextField()
                                    .keyboardType(.numberPad)
                                    .disabled(true)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Register.Label7".localized(localizationManager.language))
                            .contentStyle()
                        
                        TextField("".localized(localizationManager.language), text: $chineseName)
                            .customDisabledTextField()
                            .disabled(true)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Register.Label8".localized(localizationManager.language))
                            .contentStyle()
                        
                        DropdownMenu(
                            selectedOption: self.$identityDocument,
                            placeholder: "--- Document Type ---",
                            options: DropDownMenuOption.readDocumentTypesFromJSON(localizationManager: self.localizationManager)!,
                            color: Color.customGray
                        )
                        .disabled(true)
                        
                        Spacer().frame(height: 15)
                        
                        switch identityDocument?.id{
                        case nil:
                            ZStack{
                                
                            }
                        case 0:
                            ZStack{
                                
                            }
                            
                        case 1:
                            VStack(alignment: .leading){
                                Text("Register.Label9b".localized(localizationManager.language))
                                    .foregroundColor(.black)
                                    .contentStyle()
                                
                                HStack{
                                    TextField("e.g. A123456", text: $HKIDNumber)
                                        .customDisabledTextField()
                                        .disabled(true)
                                    
                                    Text("(")
                                        .font(.custom("Arial", size: 40).weight(.ultraLight))
                                        .foregroundColor(.black)
                                    
                                    TextField("7", text: $HKIDLastNumber)
                                        .customDisableWidthTextField(color: nil)
                                        .disabled(true)
                                    
                                    Text(")")
                                        .font(.custom("Arial", size: 40).weight(.ultraLight))
                                        .foregroundColor(.black)
                                }
                            }
                            
                        case 13:
                            VStack(alignment: .leading){
                                Text("Register.Label9a".localized(localizationManager.language))
                                    .foregroundColor(.black)
                                    .contentStyle()
                                
                                DropdownMenu(
                                    selectedOption: self.$passportCountry,
                                    placeholder: "--- Country ---",
                                    options: DropDownMenuOption.readCountriesFromJSON(localizationManager: self.localizationManager)!,
                                    color:  Color.customGray
                                )
                                .onAppear {
//                                    passportCountry = DropDownMenuOption.readCountriesFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.value == self.linkUpService.userModel!.attributes.identityDocumentCountry[0] })
                                }
                                .disabled(true)
                                
                                TextField("".localized(localizationManager.language), text: $identityDocumentID)
                                    .customDisabledTextField()
                                    .disableAutocorrection(true)
                                    .disabled(true)
                            }
                            
                        default:
                            VStack(alignment: .leading){
                                Text("Register.Label9a".localized(localizationManager.language))
                                    .foregroundColor(.black)
                                    .contentStyle()
                                TextField("".localized(localizationManager.language), text: $identityDocumentID)
                                    .customDisabledTextField()
                                    .disableAutocorrection(true)
                                    .disabled(true)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Register.Label10".localized(localizationManager.language))
                            .contentStyle()
                        
                        ZStack(alignment: .trailing){
                            TextField("".localized(localizationManager.language), text: Binding<String>(
                                get: {
                                    if let dateOfBirth = dateOfBirth {
                                        dateString = dateFormatter.string(from: dateOfBirth)
                                        return dateString
                                    }
                                    else {
                                        dateString = ""
                                        return ""
                                    }
                                },
                                set: { DateString in
                                    //                            dateString = DateString
                                    //                            dateString = formatDateString(text: DateString)
                                    //                            if DateString.isEmpty {
                                    //                                dateOfBirth = nil
                                    //                            }
                                    //                            else{
                                    //                                dateString = formatDateString(text: dateString)
                                    //                                if let date = dateFormatter.date(from: DateString) {
                                    //                                    dateOfBirth = date
                                    //                                }
                                    //                            }
                                }
                            ))
                            .customTextField(color: nil)
                            .keyboardType(.numbersAndPunctuation)
                            .disabled(true)
                            
                        }
                        
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Register.Label11".localized(localizationManager.language))
                            .contentStyle()
                        
                        DropdownMenu(
                            selectedOption: self.$gender,
                            placeholder: "--- Gender ---",
                            options: DropDownMenuOption.GenderOption(localizationManager: self.localizationManager),
                            color: Color.customGray
                        )
                        .disabled(true)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Register.Label12".localized(localizationManager.language))
                            .contentStyle()
                        
                        TextField("".localized(localizationManager.language), text: $address)
                            .customDisabledTextField()
                            .disabled(true)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Register.Label13".localized(localizationManager.language))
                            .contentStyle()
                        
                        DropdownMenu(
                            selectedOption: self.$areaOfResidence,
                            placeholder: "--- Area of Residence ---",
                            options: DropDownMenuOption.readAreaOfResidenceFromJSON(localizationManager: self.localizationManager)!,
                            color: Color.customGray
                        )
                        .disabled(true)
                    }
                    
                    
                    VStack(alignment: .leading){
                        Text("Register.Label14".localized(localizationManager.language))
                            .contentStyle()
                        
                        TextField("".localized(localizationManager.language), text: $company)
                            .customDisabledTextField()
                            .disabled(true)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Register.Label15".localized(localizationManager.language))
                            .contentStyle()
                        
                        TextField("".localized(localizationManager.language), text: $post)
                            .customDisabledTextField()
                            .disabled(true)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Register.Label16".localized(localizationManager.language))
                            .contentStyle()
                        
                        DropdownMenu(
                            selectedOption: self.$occupation,
                            placeholder: "--- Occupation ---",
                            options: DropDownMenuOption.readOcuupationsFromJSON(localizationManager: self.localizationManager)!,
                            color: Color.customGray
                        )
                        .disabled(true)
                    }
                }
            }
            Button(action: {
                self.linkUpService.linkUp(username: username, password: password, iamSmartAccountSub: self.service.idTokenClaims!.sub, iamSmartAccountToken: self.service.idToken, isFirstTimeLink: false) { success in
                    if success {
                        currentState = .LinkUpSuccess
                    }
                }
            }){
                ZStack() {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 58)
                        .background(Color.ButtonBlue)
                        .cornerRadius(4)
                    Text("LinkUp.confirm.button".localized(localizationManager.language))
                        .foregroundColor(.white)
                        .titleWithoutBoldStyle()
                }
            }
        }
        .onAppear {
            convertModelToData()
        }
    }
    
//    func modelConvertToData() {
//        self.linkUpService.getUserProfile { success in
//            if success {
//                // User model retrieved successfully
//                self.convertModelToData()
//            } else {
//                // Failed to retrieve user model
//                // Handle the error condition
//            }
//        }
//    }
    
    func convertModelToData(){
        if let userModel = self.linkUpService.linkUpModel?.user {
            email = userModel.email
//            firstName = userModel.firstName
//            lastName = userModel.lastName
            mobileNumber = userModel.attributes.mobileNumber[0]
            areaCode = DropDownMenuOption.readAreaCodeFromJSON(localizationManager: self.localizationManager)?.first(where: { $0.value == userModel.attributes.mobileCountryCode[0] })
            if areaCode?.value == "852"{
                isHkMobileNumber = true
//                SMSVerifyButtonOpacity = 1
            }
//            gender = DropDownMenuOption.GenderOption(localizationManager: self.localizationManager).first(where: { $0.value == userModel.attributes.gender[0] })
//            chineseName = userModel.attributes.chineseName[0]
//            HKIDNumber = String(userModel.attributes.hkidNumber[0].prefix(7))//first 7 letter
//            HKIDLastNumber = String(userModel.attributes.hkidNumber[0].suffix(1)) //last letter
//            dateString = userModel.attributes.dateOfBirth[0]
//            dateOfBirth = dateFormatter.date(from: dateString)
            company = userModel.attributes.company[0]
            post = userModel.attributes.post[0]
            address = userModel.attributes.mailingAddress[0]
            occupation = DropDownMenuOption.readOcuupationsFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.value == userModel.attributes.occupation[0] })
//            identityDocument = DropDownMenuOption.readDocumentTypesFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.value == userModel.attributes.identityDocumentType[0] })
//            identityDocumentID = userModel.attributes.identityDocumentValue[0]
//            if(identityDocument?.value == "Passport"){
//                passportCountry = DropDownMenuOption.readCountriesFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.value == userModel.attributes.identityDocumentCountry[0] })
////                print(passportCountry)
//            }
            areaOfResidence = DropDownMenuOption.readAreaOfResidenceFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.value == userModel.attributes.areaOfResidence[0] })
        }
        
        if let oldUserModel = self.service.userModel{
            identityDocument = DropDownMenuOption.readDocumentTypesFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.value == oldUserModel.attributes.identityDocumentType[0] })
            HKIDNumber = String(oldUserModel.attributes.hkidNumber[0].prefix(7))//first 7 letter
            HKIDLastNumber = String(oldUserModel.attributes.hkidNumber[0].suffix(1)) //last letter
            gender = DropDownMenuOption.GenderOption(localizationManager: self.localizationManager).first(where: { $0.value == oldUserModel.attributes.gender[0] })
            firstName = oldUserModel.firstName
            lastName = oldUserModel.lastName
            dateString = oldUserModel.attributes.dateOfBirth[0]
            dateOfBirth = dateFormatter.date(from: dateString)
            chineseName = oldUserModel.attributes.chineseName[0]
        }
    }

}


//#Preview {
//    LinkUpConfirmView()
//}
