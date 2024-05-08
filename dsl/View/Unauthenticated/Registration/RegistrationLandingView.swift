//
//  RegisterView.swift
//  dsl
//
//  Created by chuang chin yuen on 18/1/2024.
//

import SwiftUI
import Combine

enum VerifyingState{
   case NotVerify
   case Verifying
   case Verifyied
   case NoNeedVerify
}

struct RegistrationLandingView: View {
    
    @ObservedObject var service: RegistrationViewService

    @Binding var currentState: RegistrationState

    @State internal var emailVerificationState: VerifyingState = .NotVerify
    
    @State internal var SMSVerificationState: VerifyingState = .NotVerify

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
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
    
    @State private var emailVerifyButtonOpacity: Double = 0.7
    @State private var SMSVerifyButtonOpacity: Double = 0.7

    @State private var isHkMobileNumber: Bool = false

    @State private var isDatePickerVisible: Bool = false
    @State private var openDateMenu: Bool = false
    @State private var showPasswordGuide: Bool = false
    @State private var showLastNameGuide: Bool = false
    @State private var showFirstNameGuide: Bool = false
     
    @State private var isEmailError: Bool = false
    @State private var isPasswordError: Bool = false
    @State private var isConfirmPasswordError: Bool = false
    @State private var isLastNameError: Bool = false
    @State private var isFirstNameError: Bool = false
    @State private var isMobileError: Bool = false
    @State private var isIdentityDocumentError: Bool = false
    @State private var isHkIdNumberError: Bool = false
    
    //@State private var isEmailVerifying: Bool = false
    //@State private var isSMSVerifying: Bool = false
    @State private var emailVerifyCode: String = ""
    @State private var smsVerifyCode: String = ""
    @State private var isEmailVerifyError: Bool = false
    @State private var isSMSVerifyError: Bool = false
    
    @State private var emailResendTimer: Timer?
    @State private var smsResendTimer: Timer?
    
    @State private var SMSRemainingTime: Int = 30
    @State private var emailRemainingTime: Int = 30

    @State private var isEmailResendEnabled: Bool = true
    @State private var isSMSResendEnabled: Bool = true
    
    //@State private var EmailVerified: Bool = false
    //@State private var SMSVerified: Bool = false
        
    @State private var EmailErrorMessage: String = ""
    @State private var EmailVerifyErrorMessage: String = ""

    @State private var SMSErrorMessage: String = ""
    @State private var SMSVerifyErrorMessage: String = ""

    @State private var isDropdownMenuOpen: Bool = false
    
    @State private var testNumber: Int? = nil

    //@State private var userModel: UserModel

    //@Environment(\.dismiss) private var dismiss
    
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject var localizationManager: LocalizationManager

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        NavigationView(){
            
            ZStack{
                Color.BackgroundBlue
                    .ignoresSafeArea()

                VStack(){
                    Spacer().frame(height: 10)
                    
                    HStack{
                        //BackButton(dismiss: self.dismiss)
                        BackButton(presentationMode: self.presentationMode)
                        
                        Spacer()
                        
                        Text("Register.Title1".localized(localizationManager.language))
                            .titleStyle()
                        
                        Spacer()
                        
                        UnauthenticatedMenuButton()
                    }
                    .customLeftRightPadding()
                    
                    Spacer().frame(height: 10)
                    
                    ScrollViewReader{ scrollViewProxy in
                        
                        ScrollView(.vertical,showsIndicators: false){
                            
                            Spacer().frame(height: 20)
                            
                            VStack(spacing: 20){
                                
                                HStack(){
                                    Text("Register.Text1".localized(localizationManager.language) + "(")
                                        .contentStyle()
                                    + Text("*")
                                        .foregroundColor(.red)
                                        .contentStyle()
                                    +
                                    Text(")")
                                        .contentStyle()
                                    +
                                    Text("Register.Text2".localized(localizationManager.language))
                                        .contentStyle()
                                    Spacer()
                                }
                                                                
                                VStack(alignment: .leading){
                                    Text("Register.Label1".localized(localizationManager.language))
                                        .foregroundColor(isEmailError ? .red : .black)
                                        .contentStyle()
                                    +
                                    Text("*")
                                        .foregroundColor(.red)
                                        .contentStyle()
                                    
                                    if(emailVerificationState == .NotVerify){
                                        Text("Register.Ver.tips".localized(localizationManager.language))
                                            .foregroundColor(.gray)
                                            .errorStyle()
                                    }
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(isEmailError ? .red: .gray)
                                            .background(emailVerificationState != .Verifyied ? Color.white : Color.customGray)
                                        
                                        HStack(spacing: 0){
                                            TextField("Register.Placeholder1".localized(localizationManager.language), text: $email
                                                      , onEditingChanged: { isEditing in
                                                if !isEditing {
                                                    onEmailChecking()
                                                }
                                            })
                                            //.customTextField(color: isEmailError ? .red: .gray)
                                            .customTextWithButtonField()
                                            .keyboardType(.emailAddress)
                                            .onChange(of: email) { newValue in
                                                onEmailChecking()
                                                emailVerifyButtonOpacity = newValue.isValidEmail ? 1 : 0.7
                                                if(emailVerificationState == .Verifying){
                                                    isEmailVerifyError = false
                                                    stopEmailResendTimer()
                                                    emailVerificationState = .NotVerify
                                                }
                                            }
                                            .disabled(emailVerificationState == .Verifyied)
                                            
                                            if(emailVerificationState == .NotVerify){
                                                Button(action: {
                                                    onEmailChecking()
                                                    if(!isEmailError){
                                                        //                                                    self.service.checkUniqueEmail(email: email){
                                                        //                                                        isUnique in
                                                        //                                                        if isUnique{
                                                        sendEmailOtp()
                                                        //                                                        }
                                                        //                                                        else{
                                                        //                                                            isEmailError = true
                                                        //                                                            EmailErrorMessage = "Register.email.pre.error2".localized(localizationManager.language)
                                                        //                                                        }
                                                        //                                                    }
                                                    }
                                                }){
                                                    ZStack() {
                                                        Rectangle()
                                                            .foregroundColor(.clear)
                                                            .frame(width: 80)
                                                            .background(Color.ButtonBlue)
                                                            .cornerRadius(4, corners: [.topRight, .bottomRight])
                                                        Text("Register.ver.button1".localized(localizationManager.language))
                                                            .foregroundColor(.white)
                                                            .contentStyle()
                                                    }
                                                    .opacity(emailVerifyButtonOpacity)
                                                    //                                            .onChange(of: email) { newValue in
                                                    //                                                emailVerifyButtonOpacity = newValue.isValidEmail ? 1 : 0.7
                                                    //                                             }
                                                }
                                            }
                                            
                                            if(emailVerificationState == .Verifyied){
                                                ZStack() {
                                                    Rectangle()
                                                        .foregroundColor(.clear)
                                                        .frame(width: 54)
                                                        .background(Color.clear)
                                                        .cornerRadius(4, corners: [.topRight, .bottomRight])
                                                    Image(systemName: "checkmark")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.checkMarkGreen)
                                                }
                                            }
                                        }
                                    }
                                    
                                    if(isEmailError){
                                        Text(EmailErrorMessage.localized(localizationManager.language))
                                            .errorStyle()
                                    }
                                                                        
                                    if emailVerificationState == .Verifying{
                                        Text("")
                                        
                                        Text("Register.emailver.text".localized(localizationManager.language))
                                            .foregroundColor(.gray)
                                            .errorStyle()
                                    }
                                                                        
                                }
                                
                                if emailVerificationState == .Verifying {
                                    HStack{
                                        Spacer()
                                        
                                        Button(action: {
                                            emailVerifyCode = ""
                                            sendEmailOtp()
                                            //startEmailResendTimer()
                                        }){
                                            ZStack() {
                                                if !isEmailResendEnabled {
                                                    Text("Register.ver.button3".localized(localizationManager.language) +  " \(emailRemainingTime)" + "Register.ver.button4".localized(localizationManager.language))
                                                        .foregroundColor(.gray)
                                                        .contentStyle()
                                                }
                                                else{
                                                    Text("Register.ver.button3".localized(localizationManager.language))
                                                        .foregroundColor(Color.ButtonBlue)
                                                        .contentStyle()
                                                }
                                            }
                                        }
                                        .disabled(!isEmailResendEnabled)
                                    }
                                    
                                    VStack(alignment: .leading){
                                        Text("Register.emailver.label".localized(localizationManager.language))
                                            .foregroundColor(isEmailVerifyError ? .red : .black)
                                            .contentStyle()
                                        
                                        HStack {
                                            Text(self.service.mailOtpPrefix + "- ")
                                                .contentStyle()
                                            TextField("Register.Placeholder12".localized(localizationManager.language), text: $emailVerifyCode)
                                            //.customTextField(color: isEmailVerifyError ? .red: .gray)
                                                .keyboardType(.numberPad)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                            Button(action: {
                                                self.onEmailVerifyChecking(otp: emailVerifyCode)
                                            }){
                                                ZStack() {
                                                    Rectangle()
                                                        .foregroundColor(.clear)
                                                        .frame(width: 80)
                                                        .background(Color.ButtonBlue)
                                                        .cornerRadius(4, corners: [.topRight, .bottomRight])
                                                    Text("Register.ver.button2".localized(localizationManager.language))
                                                        .foregroundColor(.white)
                                                        .contentStyle()
                                                }
                                            }
                                        }
                                        .customVerificationField(color: isEmailVerifyError ? .red: .gray)
                                        
                                        if isEmailVerifyError {
                                            if emailVerifyCode.isEmpty {
                                                Text("Register.ver.pre.error".localized(localizationManager.language))
                                                    .errorStyle()
                                            }
                                            else {
                                                Text(EmailVerifyErrorMessage.localized(localizationManager.language))
                                                    .errorStyle()
                                            }
                                        }
                                        
                                        // Spacer().frame(height: 10)
                                        
                                        //                                    HStack{
                                        //                                        Button(action: {
                                        //                                            emailVerifyCode = ""
                                        //                                            sendEmailOtp()
                                        //                                            //startEmailResendTimer()
                                        //                                        }){
                                        //                                            ZStack() {
                                        //                                                if !isEmailResendEnabled {
                                        //                                                    Text("Register.ver.button3".localized(localizationManager.language) +  " \(emailRemainingTime)" + "Register.ver.button4".localized(localizationManager.language))
                                        //                                                        .foregroundColor(.gray)
                                        //                                                        .contentStyle()
                                        //                                                }
                                        //                                                else{
                                        //                                                    Text("Register.ver.button3".localized(localizationManager.language))
                                        //                                                        .foregroundColor(Color.ButtonBlue)
                                        //                                                        .contentStyle()
                                        //                                                }
                                        //                                            }
                                        //                                        }
                                        //                                        .disabled(!isEmailResendEnabled)
                                        //
                                        //                                        Spacer()
                                        //
                                        //                                        Button(action: {
                                        //                                            self.onEmailVerifyChecking(otp: emailVerifyCode)
                                        //                                        }){
                                        //                                            ZStack() {
                                        //                                                Rectangle()
                                        //                                                    .foregroundColor(.clear)
                                        //                                                    .frame(width: 80, height: 40)
                                        //                                                    .background(Color.ButtonBlue)
                                        //                                                    .cornerRadius(4)
                                        //                                                Text("Register.ver.button2".localized(localizationManager.language))
                                        //                                                    .foregroundColor(.white)
                                        //                                                    .contentStyle()
                                        //                                            }
                                        //                                        }
                                        //                                    }
                                    }
                                }
                                
                                
                                VStack(alignment: .leading){
                                    HStack{
                                        Text("Register.Label2".localized(localizationManager.language))
                                            .foregroundColor(isPasswordError ? .red : .black)
                                            .contentStyle()
                                        +
                                        Text("*")
                                            .foregroundColor(.red)
                                            .contentStyle()
                                        
                                        Image(systemName: "questionmark.circle")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(.gray)
                                            .onTapGesture {
                                                showPasswordGuide.toggle()
                                            }
                                        
                                        Spacer()
                                    }
                                
                                    if(showPasswordGuide){
                                        Text("Register.password.tips".localized(localizationManager.language))
                                            .foregroundColor(.gray)
                                            .infoStyle()
                                    }
                                    
                                    SecureInputView(inputTitleValue: "Register.Placeholder2".localized(localizationManager.language),inputValue: $password, color: isPasswordError ? .red: .gray, onChecking: onPasswordChecking, passwordEditChecking: true)
                                        .onChange(of: password) { newValue in
                                            onPasswordChecking()
                                        }
                                        
                                    
//                                    if isPasswordError {
//                                        if password.isEmpty {
//                                            Text("Register.password.pre.error1".localized(localizationManager.language))
//                                                .errorStyle()
//                                        }
//                                        //                                    else if password.count < 8 {
//                                        //                                         Text("Register.password.pre.error2".localized(localizationManager.language))
//                                        //                                            .errorStyle()
//                                        //                                    } else if !password.contains(where: { $0.isUppercase }) || !password.contains(where: { $0.isLowercase }) {
//                                        //                                        Text("Register.password.pre.error3".localized(localizationManager.language))
//                                        //                                            .errorStyle()
//                                        //                                    } else if !password.contains(where: \.isNumber) {
//                                        //                                        Text("Register.password.pre.error4".localized(localizationManager.language))
//                                        //                                            .errorStyle()
//                                        //                                    } else if !password.contains(where: { !"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".contains($0) }) {
//                                        //                                        Text("Register.password.pre.error5".localized(localizationManager.language))
//                                        //                                            .errorStyle()
//                                        //                                    }
//                                    }
                                    
//                                    if(!password.isEmpty){
//                                        Text("Register.password.tips.label".localized(localizationManager.language))
//                                            .infoStyle()
//
//                                        HStack{
//                                            password.count < 8 ? Image(systemName: "xmark.circle").foregroundColor(.red) : Image(systemName: "checkmark.circle").foregroundColor(.green)
//
//                                            Text("Register.password.pre.error2".localized(localizationManager.language))
//                                                .infoStyle()
//                                        }
//                                        HStack{
//                                            !password.contains(where: { $0.isUppercase }) || !password.contains(where: { $0.isLowercase }) ? Image(systemName: "xmark.circle").foregroundColor(.red) : Image(systemName: "checkmark.circle").foregroundColor(.green)
//
//                                            Text("Register.password.pre.error3".localized(localizationManager.language))
//                                                .infoStyle()
//                                        }
//                                        HStack{
//                                            !password.contains(where: \.isNumber) ? Image(systemName: "xmark.circle").foregroundColor(.red)  : Image(systemName: "checkmark.circle").foregroundColor(.green)
//
//                                            Text("Register.password.pre.error4".localized(localizationManager.language))
//                                                .infoStyle()
//                                        }
//                                        HStack{
//                                            !password.contains(where: { !"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".contains($0) }) ? Image(systemName: "xmark.circle").foregroundColor(.red) : Image(systemName: "checkmark.circle").foregroundColor(.green)
//
//                                            Text("Register.password.pre.error5".localized(localizationManager.language))
//                                                .infoStyle()
//                                        }
//                                    }
                                    
                                }
                                
                                VStack(alignment: .leading){
                                    Text("Register.Label3".localized(localizationManager.language))
                                        .foregroundColor(isConfirmPasswordError ? .red : .black)
                                        .contentStyle()
                                    +
                                    Text("*")
                                        .foregroundColor(.red)
                                        .contentStyle()
                                    
                                    SecureInputView(inputTitleValue: "Register.Placeholder3".localized(localizationManager.language),inputValue: $confirmPassword, color: isConfirmPasswordError ? .red: .gray, onChecking: onConfirmPasswordChecking, passwordEditChecking: false)
                                    
                                    if isConfirmPasswordError {
                                        Text("Register.confirmpassword.pre.error2".localized(localizationManager.language))
                                            .errorStyle()
                                    }
                                }
                                
                                VStack(alignment: .leading){
                                    HStack{
                                        Text("Register.Label4".localized(localizationManager.language))
                                            .foregroundColor(isLastNameError ? .red : .black)
                                            .contentStyle()
                                        +
                                        Text("*")
                                            .foregroundColor(.red)
                                            .contentStyle()
                                        
                                        Image(systemName: "questionmark.circle")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(.gray)
                                            .onTapGesture {
                                                showLastNameGuide.toggle()
                                            }
                                        
                                        Spacer()
                                    }
                                    if(showLastNameGuide){
                                        Text("Register.lastname.tips".localized(localizationManager.language))
                                            .foregroundColor(.gray)
                                            .infoStyle()
                                    }
                                    
                                    TextField("Register.Placeholder4".localized(localizationManager.language), text: $lastName
                                              , onEditingChanged: { isEditing in
                                        if !isEditing {
                                            onLastNameChecking()
                                        }
                                    })
                                    .customTextField(color: isLastNameError ? .red: .gray)
                                    .onChange(of: lastName) { newValue in
                                        lastName = newValue.uppercased()
                                        onLastNameChecking()
                                    }
                                    
                                    if isLastNameError {
                                        if(lastName.isEmpty){
                                            Text("Register.lastname.pre.error1".localized(localizationManager.language))
                                                .errorStyle()
                                        }
                                        else{
                                            Text("Register.lastname.pre.error2".localized(localizationManager.language))
                                                .errorStyle()
                                        }
                                    }
                                    
                                }
                                
                                VStack(alignment: .leading){
                                    HStack{
                                        Text("Register.Label5".localized(localizationManager.language))
                                            .foregroundColor(isFirstNameError ? .red : .black)
                                            .contentStyle()
                                        +
                                        Text("*")
                                            .foregroundColor(.red)
                                            .contentStyle()
                                        
                                        Image(systemName: "questionmark.circle")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(.gray)
                                            .onTapGesture {
                                                showFirstNameGuide.toggle()
                                            }
                                        Spacer()
                                    }
                                    
                                    if(showFirstNameGuide){
                                        Text("Register.firstname.tips".localized(localizationManager.language))
                                            .foregroundColor(.gray)
                                            .infoStyle()
                                    }
                                    
                                    TextField("Register.Placeholder5".localized(localizationManager.language), text: $firstName
                                              , onEditingChanged: { isEditing in
                                        if !isEditing {
                                            onFirstNameChecking()
                                        }
                                    })
                                    .customTextField(color: isFirstNameError ? .red: .gray)
                                    .onChange(of: firstName) { newValue in
                                        firstName = newValue.uppercased()
                                        onFirstNameChecking()
                                    }
                                    
                                    if isFirstNameError {
                                        if(firstName.isEmpty){
                                            Text("Register.firstname.pre.error1".localized(localizationManager.language))
                                                .errorStyle()
                                        }
                                        else{
                                            Text("Register.firstname.pre.error2".localized(localizationManager.language))
                                                .errorStyle()
                                        }
                                    }
                                    
                                }
                                
                                VStack(alignment: .leading){
                                    Text("Register.Label6".localized(localizationManager.language))
                                        .foregroundColor(isMobileError ? .red : .black)
                                        .contentStyle()
                                    +
                                    Text(isHkMobileNumber ? "*": "")
                                        .foregroundColor(.red)
                                        .contentStyle()
                                    
                                    if(isHkMobileNumber && SMSVerificationState == .NotVerify){
                                        Text("Register.Ver.tips".localized(localizationManager.language))
                                            .foregroundColor(.gray)
                                            .errorStyle()
                                    }
                                    
//                                    DropdownMenu(
//                                        selectedOption: self.$areaCode,
//                                        placeholder: "--- Area Code ---",
//                                        options: DropDownMenuOption.readAreaCodeFromJSON(localizationManager: self.localizationManager)!,
//                                        color: Color.white
//                                    )
                                    
                                    CustomPickerTextField(placeHolder: "", selectedOption: self.$areaCode, options: DropDownMenuOption.readAreaCodeFromJSON(localizationManager: self.localizationManager)!)
                                        .customPickerField(strokeColor: Color.gray, backgroundColor: Color.white)
                                    .disabled(SMSVerificationState == .Verifyied)
                                    .onChange(of: areaCode?.id) { newvalue in
                                        if(newvalue == 1){              //HK
                                            isHkMobileNumber = true
                                        }
                                        else if(newvalue == 0){
                                            mobileNumber = ""           //NoAreaCode
                                            isHkMobileNumber = false
                                            isMobileError = false
                                        }
                                        else{
                                            isHkMobileNumber = false    //others
                                            //isMobileError = false
                                        }
                                        
                                        if(SMSVerificationState == .Verifying){
                                            isSMSVerifyError = false
                                            stopSMSResendTimer()
                                            SMSVerificationState = .NotVerify
                                        }
                                    }
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(isMobileError ? .red: .gray)
                                            .background(SMSVerificationState != .Verifyied ? Color.white : Color.customGray)
                                        
                                        HStack(spacing: 0){
                                            TextField("Register.Placeholder6".localized(localizationManager.language), text: $mobileNumber
                                                      , onEditingChanged: { isEditing in
                                                if !isEditing {
                                                    onMobileChecking()
                                                }
                                            })
                                            .customTextWithButtonField()
                                            .keyboardType(.numberPad)
                                            .disabled((areaCode?.id == 0 || areaCode?.id == nil) ? true : false)
                                            .onChange(of: areaCode?.id) { newValue in
                                                onMobileChecking()
                                            }
                                            .onChange(of: mobileNumber) { newValue in
                                                onMobileChecking()
                                                SMSVerifyButtonOpacity = newValue.isValidMobileNumber ? 1 : 0.7
                                                if(SMSVerificationState == .Verifying){
                                                    isSMSVerifyError = false
                                                    stopSMSResendTimer()
                                                    SMSVerificationState = .NotVerify
                                                }
                                            }
                                            .disabled(SMSVerificationState == .Verifyied)
                                            
                                            if(isHkMobileNumber && SMSVerificationState == .NotVerify){
                                                Button(action: {
                                                    onMobileChecking()
                                                    if(!isMobileError){
                                                        //                                                    self.service.checkUniqueSMS(mobile: mobileNumber){
                                                        //                                                        isUnique in
                                                        //                                                        if isUnique{
                                                        sendSMSOtp()
                                                        //                                                        }
                                                        //                                                        else{
                                                        //                                                            isMobileError = true
                                                        //                                                            SMSErrorMessage = "Register.mobilenumber.pre.error3".localized(localizationManager.language)
                                                        //                                                        }
                                                        //                                                    }
                                                    }
                                                }){
                                                    ZStack() {
                                                        Rectangle()
                                                            .foregroundColor(.clear)
                                                            .frame(width: 80)
                                                            .background(Color.ButtonBlue)
                                                            .cornerRadius(4, corners: [.topRight, .bottomRight])
                                                        Text("Register.ver.button1".localized(localizationManager.language))
                                                            .foregroundColor(.white)
                                                            .contentStyle()
                                                    }
                                                    .opacity(SMSVerifyButtonOpacity)
                                                    //                                            .onChange(of: mobileNumber) { newValue in
                                                    //                                                SMSVerifyButtonOpacity = newValue.isValidMobileNumber ? 1 : 0.7
                                                    //                                            }
                                                }
                                            }
                                            
                                            if SMSVerificationState == .Verifyied {
                                                ZStack() {
                                                    Rectangle()
                                                        .foregroundColor(.clear)
                                                        .frame(width: 54)
                                                        .background(Color.clear)
                                                        .cornerRadius(4, corners: [.topRight, .bottomRight])
                                                    Image(systemName: "checkmark")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.checkMarkGreen)
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                    if isMobileError {
                                        Text(SMSErrorMessage.localized(localizationManager.language))
                                            .errorStyle()
                                    }
                                                                        
                                    if SMSVerificationState == .Verifying {
                                        Text("")
                                        
                                        Text("Register.mobile.ver.text".localized(localizationManager.language))
                                            .foregroundColor(.gray)
                                            .errorStyle()
                                    }
                                    
                                }
                                
                                
                                if(SMSVerificationState == .Verifying){
                                    HStack{
                                        Spacer()
                                        Button(action: {
                                            smsVerifyCode = ""
                                            sendSMSOtp()
                                            //startSMSResendTimer()
                                        }){
                                            ZStack() {
                                                if !isSMSResendEnabled {
                                                    Text("Register.ver.button3".localized(localizationManager.language) + " \(SMSRemainingTime)" + "Register.ver.button4".localized(localizationManager.language))
                                                        .foregroundColor(.gray)
                                                        .contentStyle()
                                                }
                                                else{
                                                    Text("Register.ver.button3".localized(localizationManager.language))
                                                        .foregroundColor(Color.ButtonBlue)
                                                        .contentStyle()
                                                }
                                            }
                                        }
                                        .disabled(!isSMSResendEnabled)
                                    }
                                    
                                    VStack(alignment: .leading){
                                        Text("Register.mobile.ver.label".localized(localizationManager.language))
                                            .foregroundColor(isSMSVerifyError ? .red : .black)
                                            .contentStyle()
                                        
                                        HStack {
                                            Text(self.service.smsOtpPrefix + "- ")
                                            //.fontWeight(.semibold)
                                                .contentStyle()
                                            TextField("Register.Placeholder12".localized(localizationManager.language), text: $smsVerifyCode)
                                            //.customTextField(color: isSMSVerifyError ? .red: .gray)
                                                .keyboardType(.numberPad)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                            Button(action: {
                                                onSMSVerifyChecking(otp: smsVerifyCode)
                                            }){
                                                ZStack() {
                                                    Rectangle()
                                                        .foregroundColor(.clear)
                                                        .frame(width: 80)
                                                        .background(Color.ButtonBlue)
                                                        .cornerRadius(4, corners: [.topRight, .bottomRight])
                                                    Text("Register.ver.button2".localized(localizationManager.language))
                                                        .foregroundColor(.white)
                                                        .contentStyle()
                                                }
                                            }
                                        }
                                        .customVerificationField(color: isSMSVerifyError ? .red: .gray)
                                        
                                        if isSMSVerifyError {
                                            if smsVerifyCode.isEmpty{
                                                Text("Register.ver.pre.error".localized(localizationManager.language))
                                                    .errorStyle()
                                            }
                                            else{
                                                Text("Register.ver.post.error2".localized(localizationManager.language))
                                                    .errorStyle()
                                            }
                                        }
                                        
                                        //                                    Spacer().frame(height: 10)
                                        
                                        //                                    HStack{
                                        //                                        Button(action: {
                                        //                                            smsVerifyCode = ""
                                        //                                            sendSMSOtp()
                                        //                                            //startSMSResendTimer()
                                        //                                        }){
                                        //                                            ZStack() {
                                        //                                                if !isSMSResendEnabled {
                                        //                                                    Text("Register.ver.button3".localized(localizationManager.language) + " \(SMSRemainingTime)" + "Register.ver.button4".localized(localizationManager.language))
                                        //                                                        .foregroundColor(.gray)
                                        //                                                        .contentStyle()
                                        //                                                }
                                        //                                                else{
                                        //                                                    Text("Register.ver.button3".localized(localizationManager.language))
                                        //                                                        .foregroundColor(Color.ButtonBlue)
                                        //                                                        .contentStyle()
                                        //                                                }
                                        //                                            }
                                        //                                        }
                                        //                                        .disabled(!isSMSResendEnabled)
                                        //
                                        //                                        Spacer()
                                        //
                                        //                                        Button(action: {
                                        //                                            onSMSVerifyChecking(otp: smsVerifyCode)
                                        //                                        }){
                                        //                                            ZStack() {
                                        //                                                Rectangle()
                                        //                                                    .foregroundColor(.clear)
                                        //                                                    .frame(width: 80, height: 40)
                                        //                                                    .background(Color.ButtonBlue)
                                        //                                                    .cornerRadius(4)
                                        //                                                Text("Register.ver.button2".localized(localizationManager.language))
                                        //                                                    .foregroundColor(.white)
                                        //                                                    .contentStyle()
                                        //                                            }
                                        //                                        }
                                        //                                    }
                                        //                                    .onAppear {
                                        //                                        startSMSResendTimer()
                                        //                                    }
                                        //                                    .onDisappear {
                                        //                                        stopSMSResendTimer()
                                        //                                    }
                                        
                                    }
                                }
                                
                                VStack(alignment: .leading){
                                    Text("Register.Label7".localized(localizationManager.language))
                                        .contentStyle()
                                    
                                    TextField("Register.Placeholder7".localized(localizationManager.language), text: $chineseName)
                                        .customTextField(color: .gray)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Register.Label8".localized(localizationManager.language))
                                        .contentStyle()
                                    
//                                    DropdownMenu(
//                                        selectedOption: self.$identityDocument,
//                                        placeholder: "--- Document Type ---",
//                                        options: DropDownMenuOption.readDocumentTypesFromJSON(localizationManager: self.localizationManager)!,
//                                        color: Color.white
//                                    )
                                    
                                    CustomPickerTextField(placeHolder: "", selectedOption: self.$identityDocument, options: DropDownMenuOption.readDocumentTypesFromJSON(localizationManager: self.localizationManager)!)
                                        .customPickerField(strokeColor: Color.gray, backgroundColor: Color.white)
                                    .onChange(of: identityDocument?.id) { newvalue in
                                        if(newvalue != 1){
                                            isHkIdNumberError = false   // Not HKID
                                            HKIDNumber = ""
                                            HKIDLastNumber = ""
                                        }
                                        if(newvalue == 0 || newvalue == 1){
                                            isIdentityDocumentError = false   //Nothing selected or HKID
                                            identityDocumentID = ""
                                        }
                                    }
                                    
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
                                                .foregroundColor(isHkIdNumberError ? .red : .black)
                                                .contentStyle()
                                            
                                            HStack{
                                                TextField("e.g. A123456", text: $HKIDNumber, onEditingChanged: { isEditing in
                                                    if !isEditing{
                                                        onIdentityDocumentIDChecking()
                                                    }
                                                })
                                                .customTextField(color: isHkIdNumberError ? .red: .gray)
                                                //.onReceive(Just(HKIDNumber)) { _ in limitText(7) }
                                                
                                                Text("(")
                                                    .font(.custom("Arial", size: 40).weight(.ultraLight))
                                                    .foregroundColor(.black)
                                                
                                                TextField("7", text: $HKIDLastNumber, onEditingChanged: { isEditing in
                                                    if !isEditing{
                                                        onIdentityDocumentIDChecking()
                                                    }
                                                })
                                                .customWidthTextField(color: isHkIdNumberError ? .red: .gray)
                                                .keyboardType(.numberPad)
                                                .disableAutocorrection(true)
                                                .onReceive(Just(HKIDLastNumber)) { _ in limitText(1) }
                                                Text(")")
                                                    .font(.custom("Arial", size: 40).weight(.ultraLight))
                                                    .foregroundColor(.black)
                                            }
                                            
                                            if(isHkIdNumberError){
                                                Text("Register.IDdocumet.pre.error2".localized(localizationManager.language))
                                                    .errorStyle()
                                            }
                                        }
                                        
                                        
                                    case 13:
                                        VStack(alignment: .leading){
                                            Text("Register.Label9a".localized(localizationManager.language))
                                                .foregroundColor(isIdentityDocumentError ? .red : .black)
                                                .contentStyle()
                                            
//                                            DropdownMenu(
//                                                selectedOption: self.$passportCountry,
//                                                placeholder: "--- Country ---",
//                                                options: DropDownMenuOption.readCountriesFromJSON(localizationManager: self.localizationManager)!,
//                                                color: Color.white
//                                            )
                                            
                                            CustomPickerTextField(placeHolder: "", selectedOption: self.$passportCountry, options: DropDownMenuOption.readCountriesFromJSON(localizationManager: self.localizationManager)!)
                                                .customPickerField(strokeColor: Color.gray, backgroundColor: Color.white)
                                            
                                            TextField("Register.Placeholder8".localized(localizationManager.language), text: $identityDocumentID, onEditingChanged: { isEditing in
                                                if !isEditing{
                                                    onIdentityDocumentIDChecking()
                                                }
                                            })
                                            .customTextField(color: isIdentityDocumentError ? .red: .gray)
                                            .disableAutocorrection(true)
                                            
                                            if(isIdentityDocumentError){
                                                Text("Register.IDdocumet.pre.error1".localized(localizationManager.language))
                                                    .errorStyle()
                                            }
                                        }
                                        
                                    default:
                                        VStack(alignment: .leading){
                                            Text("Register.Label9a".localized(localizationManager.language))
                                                .foregroundColor(isIdentityDocumentError ? .red : .black)
                                                .contentStyle()
                                            TextField("Register.Placeholder8".localized(localizationManager.language), text: $identityDocumentID, onEditingChanged: { isEditing in
                                                if !isEditing {
                                                    onIdentityDocumentIDChecking()
                                                }
                                            })
                                            .customTextField(color: isIdentityDocumentError ? .red: .gray)
                                            .disableAutocorrection(true)
                                            
                                            if(isIdentityDocumentError){
                                                Text("Register.IDdocumet.pre.error1".localized(localizationManager.language))
                                                    .errorStyle()
                                            }
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Register.Label10".localized(localizationManager.language))
                                        .contentStyle()
                                    
                                    //                                DatePicker(
                                    //                                    "Date of Birth:",
                                    //                                    selection: $dateOfBirth,
                                    //                                    displayedComponents: [.date]
                                    //                                )
                                    //                                .font(.custom("Arial", size: 16))
                                    //                                .foregroundColor(.black)
                                    //                                .accentColor(Color.ButtonBlue)
                                    //                                .labelsHidden()
                                    //                                .environment(\.locale, Locale(identifier: self.localizationManager.language.rawValue))
                                    //.datePickerStyle(.graphical)
                                    
                                    //                                Image(systemName: "calendar")
                                    //                                  .font(.title3)
                                    //                                  .overlay{ //MARK: Place the DatePicker in the overlay extension
                                    //                                     DatePicker(
                                    //                                         "",
                                    //                                         selection: $dateOfBirth,
                                    //                                         displayedComponents: [.date]
                                    //                                     )
                                    //                                      .blendMode(.destinationOver) //MARK: use this extension to keep the clickable functionality
                                    ////                                      .onChange(of: birthday, perform: { value in
                                    ////                                          isChild = checkAge(date:birthday)
                                    ////                                       })
                                    //                                  }
                                    
//                                    NumberPickerTextField(placeHolder: "", selectedNumber: $testNumber)
//                                        .customPickerField(strokeColor: Color.gray, backgroundColor: Color.white)

                                    DatePickerTextField(placeHolder: "Register.Placeholder13".localized(localizationManager.language), date: $dateOfBirth)
                                        .customPickerField(strokeColor: Color.gray, backgroundColor: Color.white)
                                        .onChange(of: dateOfBirth) { newValue in
                                            if let newDate = newValue {
                                                dateString = dateFormatter.string(from: newDate)
                                            } else {
                                                // Handle the case where dateOfBirth is nil
                                                dateString = ""
                                            }
                                        }

//                                    ZStack(alignment: .trailing){
//                                        TextField("Register.Placeholder13".localized(localizationManager.language), text: Binding<String>(
//                                            get: {
//                                                if let dateOfBirth = dateOfBirth {
//                                                    dateString = dateFormatter.string(from: dateOfBirth)
//                                                    return dateString
//                                                }
//                                                else {
//                                                    dateString = ""
//                                                    return ""
//                                                }
//                                            },
//                                            set: { DateString in
//                                                dateString = DateString
//                                                dateString = formatDateString(text: DateString)
//                                                if DateString.isEmpty {
//                                                    dateOfBirth = nil
//                                                }
//                                                else{
//                                                    dateString = formatDateString(text: dateString)
//                                                    if let date = dateFormatter.date(from: DateString) {
//                                                        dateOfBirth = date
//                                                    }
//                                                }
//                                                //                                            else{
//                                                //                                                dateString = DateString
//                                                //                                            }
//                                            }
//                                        )
//                                                  , onEditingChanged: { isEditing in
//                                            if !isEditing{
//                                                dateString = formatDateString(text: dateString)
//                                            }
//                                        }
//                                        )
//                                        .customTextField(color: .gray)
//                                        .keyboardType(.numbersAndPunctuation)
//                                        .onTapGesture {
//                                            openDateMenu.toggle()
//                                        }
////                                        .IOSPopover(isPresented: $openDateMenu, arrowDirection: .down, content: {
////                                            DatePicker("", selection: $dateOfBirth?, displayedComponents: .date)
////                                                .datePickerStyle(.wheel)
////                                                .accentColor(Color.ButtonBlue)
////                                                .environment(\.locale, Locale(identifier: self.localizationManager.language.rawValue))
////
////                                        })
//
//                                        ZStack {
//                                            DatePicker("", selection: Binding<Date>(
//                                                get: { dateOfBirth ?? Date() },
//                                                set: { dateOfBirth = $0 }
//                                            ), displayedComponents: [.date])
//                                            .environment(\.locale, Locale(identifier: self.localizationManager.language.rawValue))
//                                            .accentColor(Color.ButtonBlue)
//                                            .labelsHidden()
//                                            .frame(width: 0, height: 0)
//                                            .clipped()
//
//                                            //                                    SwiftUIWrapper {
//                                            //                                        Image(systemName: "calendar")
//                                            //                                            .resizable()
//                                            //                                            .frame(width: 20, height: 20, alignment: .center)
//                                            //                                    }
//                                            //                                    .allowsHitTesting(false)
//                                            //                                    .frame(width: 20, height: 20)
//
//                                            Image(systemName: "calendar")
//                                                .resizable()
//                                                .frame(width: 20, height: 20)
//                                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
//                                            //.allowsHitTesting(false)
//
//                                            //.userInteractionDisabled()
//                                        }
//                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
//                                        .frame(width: 20, height: 20)
//
//                                    }
                                    
                                }
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Register.Label11".localized(localizationManager.language))
                                        .contentStyle()
                                    
                                    CustomPickerTextField(placeHolder: "", selectedOption: self.$gender, options: DropDownMenuOption.GenderOption(localizationManager: self.localizationManager))
                                        .customPickerField(strokeColor: Color.gray, backgroundColor: Color.white)
                                    
//                                    DropdownMenu(
//                                        selectedOption: self.$gender,
//                                        placeholder: "--- Gender ---",
//                                        options: DropDownMenuOption.GenderOption(localizationManager: self.localizationManager),
//                                        color: Color.white
//                                    )
                                }
                                
                                VStack(alignment: .leading){
                                    Text("Register.Label12".localized(localizationManager.language))
                                        .contentStyle()
                                    
                                    TextField("Register.Placeholder9".localized(localizationManager.language), text: $address)
                                        .customTextField(color: .gray)
                                }
                                
                                VStack(alignment: .leading){
                                    Text("Register.Label13".localized(localizationManager.language))
                                        .contentStyle()
                                    
                                    CustomPickerTextField(placeHolder: "", selectedOption: self.$areaOfResidence, options: DropDownMenuOption.readAreaOfResidenceFromJSON(localizationManager: self.localizationManager)!)
                                        .customPickerField(strokeColor: Color.gray, backgroundColor: Color.white)
                                    
//                                    DropdownMenu(
//                                        selectedOption: self.$areaOfResidence,
//                                        placeholder: "--- Area of Residence ---",
//                                        options: DropDownMenuOption.readAreaOfResidenceFromJSON(localizationManager: self.localizationManager)!,
//                                        color: Color.white
//                                    )
                                }
                                
                                VStack(alignment: .leading){
                                    Text("Register.Label14".localized(localizationManager.language))
                                        .contentStyle()
                                    
                                    TextField("Register.Placeholder10".localized(localizationManager.language), text: $company)
                                        .customTextField(color: .gray)
                                }
                                
                                VStack(alignment: .leading){
                                    Text("Register.Label15".localized(localizationManager.language))
                                        .contentStyle()
                                    
                                    TextField("Register.Placeholder11".localized(localizationManager.language), text: $post)
                                        .customTextField(color: .gray)
                                }
                                
                                VStack(alignment: .leading){
                                    Text("Register.Label16".localized(localizationManager.language))
                                        .contentStyle()
                                        //.id(1)
                                    
                                    CustomPickerTextField(placeHolder: "", selectedOption: self.$occupation, options: DropDownMenuOption.readOcuupationsFromJSON(localizationManager: self.localizationManager)!)
                                        .customPickerField(strokeColor: Color.gray, backgroundColor: Color.white)
                                    
//                                    DropdownMenu(
//                                        selectedOption: self.$occupation,
//                                        placeholder: "--- Occupation ---",
//                                        options: DropDownMenuOption.readOcuupationsFromJSON(localizationManager: self.localizationManager)!,
//                                        color: Color.white
//                                    )
//                                    .onChange(of: isDropdownMenuOpen) { isOpen in
//                                        if isOpen {
//                                            // Scroll to the bottom of the scroll view
//                                            print("opened")
//                                            scrollViewProxy.scrollTo(1, anchor: .top)
//                                        }
//                                    }
//                                    .onTapGesture {
//                                        print("opened")
//                                        isDropdownMenuOpen.toggle()
//                                    }
                                }
                                
                            }
                            
                        }
                        .customLeftRightPadding()
                    }
                    
                    Spacer().frame(height: 15)
                    
                    Button(action: {
                        self.endTextEditing()
//                        print(areaCode ?? 0)
//                        print(areaOfResidence ?? 0)
//                        print(gender ?? 0)
//                        print(dateString)
                        print(dataConvertToModel())
                        onAllChecking()
                        
                        if(!isPasswordError && !isConfirmPasswordError && !isFirstNameError && !isLastNameError && !isHkIdNumberError && !isIdentityDocumentError && emailVerificationState == .Verifyied && !isMobileError && (SMSVerificationState == .Verifyied || !isHkMobileNumber))
                        {
                            if !isHkMobileNumber{
                                self.service.mobileIdentifier = ""
                            }
//                            self.service.UserRegistration(userModel: dataConvertToModel()){ statusCode in
//                                if(statusCode == 201){
//                                    currentState = .success
//                                }
//                            }
                        }
                        
                    }){
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 58)
                                .background(Color.ButtonBlue)
                                .cornerRadius(4)
                            Text("Register.Button".localized(localizationManager.language))
                                .foregroundColor(.white)
                                .titleWithoutBoldStyle()
                        }
                    }
                    .customLeftRightPadding()
                    
                    Spacer()
                }
                
            }
            .navigationBarHidden(true)
            .onChange(of: Locale.preferredLanguages.first, perform: { newValue in
                isEmailError = false
                isPasswordError = false
                isConfirmPasswordError = false
                isLastNameError = false
                isFirstNameError = false
                isMobileError = false
                isIdentityDocumentError = false
                isHkIdNumberError = false
                isEmailVerifyError = false
                isSMSVerifyError = false
            })
            .onTapGesture {
                //UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                self.endTextEditing()
            }
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
        .onAppear {
            gender = DropDownMenuOption.GenderOption(localizationManager: self.localizationManager).first(where: { $0.id == 0 })
            identityDocument = DropDownMenuOption.readDocumentTypesFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.id == 0 })
            areaCode = DropDownMenuOption.readAreaCodeFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.id == 0 })
            areaOfResidence =  DropDownMenuOption.readAreaOfResidenceFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.id == 0 })
            occupation = DropDownMenuOption.readOcuupationsFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.id == 0 })
            passportCountry = DropDownMenuOption.readCountriesFromJSON(localizationManager: self.localizationManager)!.first(where: { $0.id == 0 })
        }
    }
    
    func limitText(_ upper: Int) {
        if HKIDLastNumber.count > upper {
            HKIDLastNumber = String(HKIDLastNumber.prefix(upper))
        }
    }
    
    func getFocus(focused:Bool) {
        print("get focus:\(focused ? "true" : "false")")
    }
    
    func onEmailChecking() {
        if(!email.isValidEmail)
        {
            isEmailError = true
            if email.isEmpty{
                EmailErrorMessage = "Register.email.pre.error3".localized(localizationManager.language)
            }
            else {
                EmailErrorMessage = "Register.email.pre.error1".localized(localizationManager.language)
            }
        }
        else{
            isEmailError = false
            EmailErrorMessage = ""
        }
    }
    
    func onPasswordChecking(){
        if(!password.isValidPassword())
        {
            isPasswordError = true
        }
        else{
            isPasswordError = false
        }
    }
    
    func onConfirmPasswordChecking(){
        if(password==confirmPassword || password.isEmpty)
        {
            isConfirmPasswordError = false
        }
        else{
            isConfirmPasswordError = true
        }
    }
    
    func onFirstNameChecking(){
        let alphabeticRegex = "^[A-Z ]+$"
        let alphabeticPredicate = NSPredicate(format: "SELF MATCHES %@", alphabeticRegex)

        if firstName.isEmpty || firstName.count > 80 || !alphabeticPredicate.evaluate(with: firstName)
        {
            isFirstNameError = true
        }
        else{
            isFirstNameError = false
        }
    }
    
    func onLastNameChecking(){
        let alphabeticRegex = "^[A-Z ]+$"
        let alphabeticPredicate = NSPredicate(format: "SELF MATCHES %@", alphabeticRegex)

        if lastName.isEmpty || lastName.count > 80 || !alphabeticPredicate.evaluate(with: lastName)
        {
            isLastNameError = true
        }
        else{
            isLastNameError = false
        }
    }
    
    func onMobileChecking(){
        let alphabeticRegex = "^[0-9]+$"
        let alphabeticPredicate = NSPredicate(format: "SELF MATCHES %@", alphabeticRegex)

        let TotalLength = (areaCode?.value.count ?? 0) + mobileNumber.count
        
        if (mobileNumber.isEmpty && isHkMobileNumber)  || (!mobileNumber.isEmpty && mobileNumber.count < 8) || (TotalLength > 15) || (!alphabeticPredicate.evaluate(with: mobileNumber) && !mobileNumber.isEmpty)
        {
            isMobileError = true
            if mobileNumber.isEmpty{
                SMSErrorMessage = "Register.mobilenumber.pre.error1".localized(localizationManager.language)
            }
            else{
                SMSErrorMessage = "Register.mobilenumber.pre.error2".localized(localizationManager.language)
            }
        }
        else{
            isMobileError = false
            SMSErrorMessage = ""
        }
    }
    
    
    func onIdentityDocumentIDChecking(){
        let alphabeticRegex = "^[a-zA-Z0-9]+$"
        let alphabeticPredicate = NSPredicate(format: "SELF MATCHES %@", alphabeticRegex)

        if !identityDocumentID.isEmpty && (!alphabeticPredicate.evaluate(with: identityDocumentID) || identityDocumentID.count > 80) {
            isIdentityDocumentError = true
        }
        else{
            isIdentityDocumentError = false
        }
        
        if !HKIDNumber.isEmpty || !HKIDLastNumber.isEmpty{
            if(!isHKID(HKIDNumber + HKIDLastNumber)){
                isHkIdNumberError = true
            }
            else{
                isHkIdNumberError = false
            }
        }
        else{
            isHkIdNumberError = false
        }
    }
    
    func sendEmailOtp(){
        self.service.sendEmailOtp(email: email){ statuscode in
            if(statuscode == 200){
                isEmailError = false
                EmailErrorMessage = ""
                emailVerificationState = .Verifying
                startEmailResendTimer()
            }
            else{
                isEmailError = true
                EmailErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
            }
        }
    }
    
    func onEmailVerifyChecking(otp: String){
        self.service.verifyOtp(type: 1, userInfo: email, enterOtp: otp) { statuscode in
            if statuscode == 200{
                isEmailError = false
                isEmailVerifyError = false
                EmailVerifyErrorMessage = ""
                emailVerificationState = .Verifyied
                stopEmailResendTimer()
            }
            else if statuscode == 400{
                isEmailVerifyError = true
                EmailVerifyErrorMessage = "Register.ver.post.error2".localized(localizationManager.language)
            }
            else if statuscode == 401{
                isEmailVerifyError = true
                EmailVerifyErrorMessage = "Register.ver.post.error3".localized(localizationManager.language)
            }
            else if statuscode == 409{
                isEmailVerifyError = false
                emailVerifyCode = ""
                emailVerificationState = .NotVerify
                isEmailError = true
                EmailErrorMessage = "Register.email.pre.error2".localized(localizationManager.language)
            }
            else{
                isEmailVerifyError = true
                EmailVerifyErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
            }
        }
    }
    
    func sendSMSOtp(){
        self.service.sendSMSOtp(mobileNumber: mobileNumber){ statuscode in
            if(statuscode == 200){
                isMobileError = false
                SMSErrorMessage = ""
                SMSVerificationState = .Verifying
                startSMSResendTimer()
            }
            else{
                isMobileError = true
                SMSErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
            }
        }
    }

    func onSMSVerifyChecking(otp: String){
        
        self.service.verifyOtp(type: 2, userInfo: mobileNumber, enterOtp: otp) { statuscode in
            if statuscode == 200 {
                isMobileError = false
                isSMSVerifyError = false
                SMSVerifyErrorMessage = ""
                SMSVerificationState = .Verifyied
                stopSMSResendTimer()
            }
            else if statuscode == 400 {
                isSMSVerifyError = true
                SMSVerifyErrorMessage = "Register.ver.post.error2".localized(localizationManager.language)
            }
            else if statuscode == 401 {
                isSMSVerifyError = true
                SMSVerifyErrorMessage = "Register.ver.post.error3".localized(localizationManager.language)
            }
            else if statuscode == 409 {
                isSMSVerifyError = false
                smsVerifyCode = ""
                SMSVerificationState = .NotVerify
                isMobileError = true
                SMSErrorMessage = "Register.mobilenumber.pre.error3".localized(localizationManager.language)
            }
            else {
                isSMSVerifyError = true
                SMSVerifyErrorMessage = "ServerErrorMessage".localized(localizationManager.language)
            }
        }

//        if smsVerifyCode != "123456"
//        {
//            isSMSVerifyError = true
//        }
//        else{
//            isMobileError = false
//            isSMSVerifyError = false
//            SMSVerificationState = .Verifyied
//        }
    }
        
    func startEmailResendTimer() {
        isEmailResendEnabled = false
        emailRemainingTime = 30
        
        emailResendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if emailRemainingTime > 0 {
                emailRemainingTime -= 1
            } else {
                stopEmailResendTimer()
            }
        }
        RunLoop.current.add(emailResendTimer!, forMode: .common)
    }
        
    func stopEmailResendTimer() {
        emailResendTimer?.invalidate()
        emailResendTimer = nil
        isEmailResendEnabled = true
    }
    
    func startSMSResendTimer() {
        isSMSResendEnabled = false
        SMSRemainingTime = 30
        
        smsResendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if SMSRemainingTime > 0 {
                SMSRemainingTime -= 1
            } else {
                stopSMSResendTimer()
            }
        }
        RunLoop.current.add(smsResendTimer!, forMode: .common)
    }
    
    func stopSMSResendTimer() {
        smsResendTimer?.invalidate()
        smsResendTimer = nil
        isSMSResendEnabled = true
    }
    
    func isHKID(_ HKIDNumber: String) -> Bool {
        let strValidChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        if HKIDNumber.count < 8 {
            return false
        }
        
        let str = HKIDNumber.uppercased()
        let hkidPat = "^([A-Z]{1,2})([0-9]{6})([A0-9])$"
        let hkidRegex = try! NSRegularExpression(pattern: hkidPat)
        let matchArray = hkidRegex.matches(in: str, range: NSRange(str.startIndex..., in: str))
        
        if matchArray.isEmpty {
            return false
        }
        
        let charPartRange = matchArray[0].range(at: 1)
        let numPartRange = matchArray[0].range(at: 2)
        let checkDigitRange = matchArray[0].range(at: 3)
        
        let charPart = String(str[Range(charPartRange, in: str)!])
        let numPart = String(str[Range(numPartRange, in: str)!])
        let checkDigit = String(str[Range(checkDigitRange, in: str)!])
        
        var checkSum = 0
        
        if charPart.count == 2 {
            checkSum += 9 * (10 + strValidChars.distance(from: strValidChars.startIndex, to: strValidChars.firstIndex(of: charPart[charPart.startIndex])!))
            checkSum += 8 * (10 + strValidChars.distance(from: strValidChars.startIndex, to: strValidChars.firstIndex(of: charPart[charPart.index(after: charPart.startIndex)])!))
        } else {
            checkSum += 9 * 36
            checkSum += 8 * (10 + strValidChars.distance(from: strValidChars.startIndex, to: strValidChars.firstIndex(of: charPart[charPart.startIndex])!))
        }
        
        for (index, digit) in numPart.enumerated() {
            let j = 7 - index
            if let num = Int(String(digit)) {
                checkSum += j * num
            } else {
                return false
            }
        }
        
        let remaining = checkSum % 11
        let verify = remaining == 0 ? 0 : 11 - remaining
        
        return verify == Int(checkDigit) || (verify == 10 && checkDigit == "A")
    }
    
    func formatDateString(text: String) -> String {
        var formattedText = ""
        
        // Remove any non-digit characters
        let digitsOnly = text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Insert the dashes in the desired positions
        let digitCount = digitsOnly.count
        if digitCount > 0 {
            var formattedDigits = ""
            
            for (index, digit) in digitsOnly.enumerated() {
                formattedDigits.append(digit)
                
                if index == 3 || index == 5 {
                    formattedDigits.append("-")
                }
                
                if index == 7 {
                    break
                }
            }
            
            formattedText = formattedDigits
        }
        
        return formattedText
    }

    
    func onAllChecking(){
        onEmailChecking()
        onPasswordChecking()
        onConfirmPasswordChecking()
        onLastNameChecking()
        onFirstNameChecking()
        onIdentityDocumentIDChecking()
        onMobileChecking()
                
        if(!isEmailError && emailVerificationState != .Verifyied){
            isEmailError = true
            EmailErrorMessage = "Register.email.pre.error4".localized(localizationManager.language)
        }
                    
        if(isHkMobileNumber && !isMobileError && SMSVerificationState != .Verifyied){
            isMobileError = true
            SMSErrorMessage = "Register.mobilenumber.pre.error4".localized(localizationManager.language)
        }
    }
    
    func dataConvertToModel() -> UserModel{
        let userModel: UserModel = UserModel(
            username: email,
            enabled: true,
            emailVerified: true,
            firstName: firstName,
            lastName: lastName,
            email: email,
            credentials: [
                UserCredentialModel(
                    type: "password",
                    value: password,
                    temporary: false
                )
            ],
            attributes: UserAttributesModel(
                oldSub: [""],
                mobileCountryCode: [mobileNumber.isEmpty ?  "" : areaCode?.value ?? ""],
                mobileNumber: [mobileNumber],
                chineseName: [chineseName],
                mailingAddress: [address],
                hkidNumber: [HKIDNumber+HKIDLastNumber],
                dateOfBirth: [dateString],
                gender: [gender?.value ?? ""],
                areaOfResidence: [areaOfResidence?.value ?? ""],
                company: [company],
                post: [post],
                occupation: [occupation?.value ?? ""],
                identityDocumentCountry: [(identityDocumentID.isEmpty || identityDocument?.value != "Passport") ? "" : passportCountry?.value ?? ""],
                identityDocumentType: [((identityDocumentID.isEmpty && !isHKID(HKIDNumber + HKIDLastNumber)) || (identityDocument?.value == "Passport" && passportCountry?.value == "")) ? "" : identityDocument?.value ?? ""],
                identityDocumentValue: [identityDocumentID],
                iAMSmartTokenisedId: [""],
                authLevel: [isHkMobileNumber ? "2" : "1"],
                maxAuthLevel: [isHkMobileNumber ? "2" : "1"],
                lastLogin: [""],
                latestLogin: [""],
                locale: [Locale.preferredLanguages.first?.convertToLanguageCodeFormat() ?? ""]
            )
        )
        return userModel
    }
}

//#Preview {
//    RegistrationFormView()
//}

//struct SecureInputView: View {
//    @Binding var inputTitleValue: String
//    @Binding var inputValue: String
//    @State private var visibleInput: String = ""
//    @State private var isSecured = true    
//    @State private var fontSize = 16
//
//    //private var title: String
//
//    var body: some View {
//        ZStack(alignment: .trailing) {
//            TextField(inputTitleValue, text: $visibleInput)
//                .textFieldStyle(.roundedBorder)
//                .autocapitalization(.none)
//                .disableAutocorrection(true)
//                .font(.system(size: CGFloat(fontSize)))
//                .onChange(of: visibleInput) { newValue in
//                    guard isSecured else { inputValue = newValue; return }
//                    if newValue.count >= inputValue.count {
//                        let newItem = newValue.filter { $0 != Character("●") }
//                        inputValue.append(newItem)
//                    } else {
//                        inputValue.removeLast()
//                    }
//                    visibleInput = String(newValue.map { _ in Character("●") })
//                }
//            Button {
//                isSecured.toggle()
//                visibleInput = isSecured ? String(inputValue.map { _ in Character("●") }) :  inputValue
//            } label: {
//                (isSecured ? Image(systemName: "eye.slash") : Image(systemName: "eye"))
//            }
//        }
//    }
//}

