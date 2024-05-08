//
//  uiStuff.swift
//  dsl
//
//  Created by chuang chin yuen on 16/1/2024.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

struct HeaderView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        
        HStack{
            Image("Header")
            
            Spacer().frame(width: 10)
            
            VStack(alignment: .leading) {
                Text("Header.HKPF".localized(localizationManager.language))
                    .smallTitleStyle()
                
                Spacer().frame(height: 5)

                Text("Header.DigitalServicesLogon".localized(localizationManager.language))
                    .infoStyle()
            }
        }
    }
}

struct SecureInputView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager

    let inputTitleValue: String
//    @Binding var inputTitleValue: String
    @Binding var inputValue: String
    let color: Color
    let onChecking: () -> Void
    let passwordEditChecking: Bool
    @State private var visibleInput: String = ""
    @State private var isSecured = true
    @State private var fontSize: CGFloat = 9
    @State private var editing: Bool = false
    
    var body: some View {
        
        //VStack{
        VStack(alignment: .leading) {
            
            //HStack(spacing: 0)
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color)
                    .background(Color.white)
                
                HStack(spacing: 0){
                    
                    UISecureTextFieldViewRepresentable(text: $visibleInput, onEditingChanged: { isEditing in
                        if !isEditing {
                            onChecking()
                            editing = false
                        }
                        else{
                            editing = true
                        }
                    }, inputTitleValue: inputTitleValue.localized(localizationManager.language))
                    .frame(height: 50)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                    //.keyboardType(.numberPad)
                    .autocapitalization(.none)
                    //            .disableAutocorrection(true)
                    //            .font(.system(size: visibleInput.isEmpty ? 16 : fontSize))
                    //            .background(
                    //                RoundedRectangle(cornerRadius: 4)
                    //                    .stroke(color)
                    //            )
                    //.background(Color.white)
                    .onChange(of: visibleInput) { newValue in
                        guard isSecured else { inputValue = newValue; return }
                        if newValue.count >= inputValue.count {
                            let newItem = newValue.filter { $0 != Character("●") }
                            inputValue.append(newItem)
                        } else {
                            inputValue.removeLast()
                        }
                        visibleInput = String(newValue.map { _ in Character("●") })
                    }
                    //.clipped()
                    //}
                    
                    //            TextField(inputTitleValue, text: $visibleInput, onEditingChanged: { isEditing in
                    //                if !isEditing {
                    //                    onChecking()
                    //                }
                    //            })
                    //            .customTextField(color: color)
                    //            .font(.system(size: visibleInput.isEmpty ? 16 : fontSize))
                    //            .onChange(of: visibleInput) { newValue in
                    //                guard isSecured else { inputValue = newValue; return }
                    //                if newValue.count >= inputValue.count {
                    //                    let newItem = newValue.filter { $0 != Character("●") }
                    //                    inputValue.append(newItem)
                    //                } else {
                    //                    inputValue.removeLast()
                    //                }
                    //                visibleInput = String(newValue.map { _ in Character("●") })
                    //            }
                    //            .disableAutocorrection(true) // Disable autocorrection
                    
                    Button (action: {
                        isSecured.toggle()
                        visibleInput = isSecured ? String(inputValue.map { _ in Character("●") }) : inputValue
                        fontSize = isSecured ? 9 : 16 // Set the font size based on the isSecured state
                    }){
                        //label:{
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 54)
                                .background(Color.ButtonBlue)
                                .cornerRadius(4, corners: [.topRight, .bottomRight])
                            (isSecured ? Image(systemName: "eye.slash")               .foregroundColor(.white) : Image(systemName: "eye")                                                .foregroundColor(.white))
                        }
                        //.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                    }
                }
            }
            
            if(editing && passwordEditChecking){
                Text("Register.password.tips.label".localized(localizationManager.language))
                    .infoStyle()
                
                HStack{
                    inputValue.count < 8 ? Image(systemName: "xmark.circle").foregroundColor(.red) : Image(systemName: "checkmark.circle").foregroundColor(.green)
                    
                    Text("Register.password.pre.error2".localized(localizationManager.language))
                        .infoStyle()
                }
                HStack{
                    !inputValue.contains(where: { $0.isUppercase }) || !inputValue.contains(where: { $0.isLowercase }) ? Image(systemName: "xmark.circle").foregroundColor(.red) : Image(systemName: "checkmark.circle").foregroundColor(.green)
                    
                    Text("Register.password.pre.error3".localized(localizationManager.language))
                        .infoStyle()
                }
                HStack{
                    !inputValue.contains(where: \.isNumber) ? Image(systemName: "xmark.circle").foregroundColor(.red)  : Image(systemName: "checkmark.circle").foregroundColor(.green)
                    
                    Text("Register.password.pre.error4".localized(localizationManager.language))
                        .infoStyle()
                }
                HStack{
                    !inputValue.contains(where: { !"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".contains($0) }) ? Image(systemName: "xmark.circle").foregroundColor(.red) : Image(systemName: "checkmark.circle").foregroundColor(.green)
                    
                    Text("Register.password.pre.error5".localized(localizationManager.language))
                        .infoStyle()
                }
            }
            
            if !editing && passwordEditChecking && color == .red {
                if inputValue.isEmpty {
                    Text("Register.password.pre.error1".localized(localizationManager.language))
                        .errorStyle()
                }
                else if inputValue.count < 8 {
                    Text("Register.password.pre.error2".localized(localizationManager.language))
                        .errorStyle()
                } else if !inputValue.contains(where: { $0.isUppercase }) || !inputValue.contains(where: { $0.isLowercase }) {
                    Text("Register.password.pre.error3".localized(localizationManager.language))
                        .errorStyle()
                } else if !inputValue.contains(where: \.isNumber) {
                    Text("Register.password.pre.error4".localized(localizationManager.language))
                        .errorStyle()
                } else if !inputValue.contains(where: { !"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".contains($0) }) {
                    Text("Register.password.pre.error5".localized(localizationManager.language))
                        .errorStyle()
                }
            }
        }
    }
    //}
}

struct SecureInputNoEyesView: View {
    
    @EnvironmentObject var localizationManager: LocalizationManager

    let inputTitleValue: String
//    @Binding var inputTitleValue: String
    @Binding var inputValue: String
    let color: Color
    let onChecking: () -> Void
    @State private var visibleInput: String = ""
    @State private var isSecured = true
    @State private var fontSize: CGFloat = 9
    
    var body: some View {
        
        //VStack{
        // VStack(alignment: .leading) {
        
        //HStack(spacing: 0)
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(color)
                .background(Color.white)
            
            HStack(spacing: 0){
                UISecureTextFieldViewRepresentable(text: $visibleInput, onEditingChanged: { isEditing in
                    if !isEditing {
                        onChecking()
                    }
                }, inputTitleValue: inputTitleValue.localized(localizationManager.language))
                .frame(height: 40)
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                //.keyboardType(.numberPad)
                .autocapitalization(.none)
                .onChange(of: visibleInput) { newValue in
                    guard isSecured else { inputValue = newValue; return }
                    if newValue.count >= inputValue.count {
                        let newItem = newValue.filter { $0 != Character("●") }
                        inputValue.append(newItem)
                    } else {
                        inputValue.removeLast()
                    }
                    visibleInput = String(newValue.map { _ in Character("●") })
                }
                .onChange(of: inputValue) { newValue in
                    if newValue.isEmpty{
                        visibleInput = ""
                    }
                }
            }
        }
    }
    //}
}


struct UISecureTextFieldViewRepresentable: UIViewRepresentable {
    
    @EnvironmentObject var localizationManager: LocalizationManager

    @Binding var text: String
    var onEditingChanged: ((Bool) -> Void)?
    let inputTitleValue: String

    typealias UIViewType = ProtectedTextField

    func makeUIView(context: Context) -> ProtectedTextField {
        let textField = ProtectedTextField()
        textField.delegate = context.coordinator
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) //how willing the text field is to be compressed horizontally when there is limited space available
        textField.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged), for: .editingChanged)
        //textField.placeholder = inputTitleValue.localized(localizationManager.language) // Set the inputTitleValue as the placeholder
        updatePlaceholder(textField)
        return textField
    }

    func updatePlaceholder(_ textField: ProtectedTextField) {
        textField.placeholder = inputTitleValue.localized(localizationManager.language)
        textField.keyboardType = .asciiCapable
        textField.autocorrectionType = .no
    }

    // From SwiftUI to UIKit
    func updateUIView(_ uiView: ProtectedTextField, context: Context) {
        uiView.text = text
        updatePlaceholder(uiView)
    }

    // From UIKit to SwiftUI
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, onEditingChanged: onEditingChanged)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var onEditingChanged: ((Bool) -> Void)?

        init(text: Binding<String>, onEditingChanged: ((Bool) -> Void)?) {
            self._text = text
            self.onEditingChanged = onEditingChanged
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        @objc func editingChanged() {
            onEditingChanged?(true)
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            onEditingChanged?(false)
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

// Custom TextField with disabling paste action
class ProtectedTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) || action == #selector(copy(_:)) || action == #selector(cut(_:)){
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

class SuperProtectedTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(select(_:)) || action == #selector(selectAll(_:)) || action == #selector(delete(_:)) || action == #selector(paste(_:)) || action == #selector(copy(_:)) || action == #selector(cut(_:)) || action == #selector(delete(_:)) || action == #selector(replace(_:withText:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    let height: CGFloat
    let width: CGFloat?
    let color: Color
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(width: width, height: height)
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color)
            )
    }
}

struct GrayLineView: View {
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(height: 1)
            .background(Color.gray)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
    }
}

extension View{
    func customVerificationField(color: Color) -> some View {
        self
            .frame(height: 50)
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color)
            )
            .background(Color.white)
    }
    func customPickerField(strokeColor: Color, backgroundColor: Color) -> some View {
        self
            .frame(height: 50)
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(strokeColor)
            )
            .background(backgroundColor)
    }
    func customLeftRightPadding() -> some View {
        self
            .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
    }
    func customLeftRightPadding2() -> some View {
        self
            .padding(EdgeInsets(top: 0, leading: 35, bottom: 0, trailing: 35))
    }
}

extension TextField {
    func customTextField(color: Color?) -> some View {
        self
            .textFieldStyle(CustomTextFieldStyle(height: 50, width: nil, color: color ?? .gray))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(color == .gray || color == .red ? Color.white : Color.customGray)
    }
    
    func customTextWithButtonField() -> some View {
        self
            .textFieldStyle(CustomTextFieldStyle(height: 50, width: nil, color: .clear))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(Color.clear)
    }
    
    func customLoginField(color: Color?) -> some View {
        self
            .textFieldStyle(CustomTextFieldStyle(height: 40, width: nil, color: color ?? .gray))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(color == .gray || color == .red ? Color.white : Color.customGray)
    }
    
    func customDisabledTextField() -> some View {
        self
            .textFieldStyle(CustomTextFieldStyle(height: 50, width: nil, color: .gray))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(Color.customGray)
    }
    
    func customErrorField() -> some View {
        self
            .textFieldStyle(CustomTextFieldStyle(height: 50, width: nil, color: .red))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(Color.white)
    }
    
    func customWidthTextField(color: Color?) -> some View {
        self
            .textFieldStyle(CustomTextFieldStyle(height: 50, width: 15, color: color ?? .gray))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(Color.white)
    }
    
    func customDisableWidthTextField(color: Color?) -> some View {
        self
            .textFieldStyle(CustomTextFieldStyle(height: 50, width: 15, color: color ?? .gray))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(Color.customGray)
    }
}

extension UISecureTextFieldViewRepresentable{
    func customTextField(color: Color?) -> some View {
        self
            .textFieldStyle(CustomTextFieldStyle(height: 50, width: nil, color: color ?? .gray))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .background(Color.white)
    }
}

////struct NoHitTesting: ViewModifier {
////    func body(content: Content) -> some View {
////        SwiftUIWrapper { content }.allowsHitTesting(false)
////    }
//}

extension View {
//    func userInteractionDisabled() -> some View {
//        self.modifier(NoHitTesting())
//    }
}

struct SwiftUIWrapper<T: View>: UIViewControllerRepresentable {
    let content: () -> T
    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: content())
    }
    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {}
}

extension View {
  @ViewBuilder
  func IOSPopover<Content: View>(isPresented: Binding<Bool>, arrowDirection: UIPopoverArrowDirection, @ViewBuilder content: @escaping ()->Content)->some View {
    self
      .background {
        PopOverController(isPresented: isPresented, arrowDirection: arrowDirection, content: content())
      }
  }
}

struct PopOverController<Content: View>: UIViewControllerRepresentable {
  @Binding var isPresented: Bool
  var arrowDirection: UIPopoverArrowDirection
  var content: Content

  @State private var alreadyPresented: Bool = false

  func makeCoordinator() -> Coordinator {
    return Coordinator(parent: self)
  }

  func makeUIViewController(context: Context) -> some UIViewController {
    let controller = UIViewController()
    controller.view.backgroundColor = .clear
    return controller
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    if alreadyPresented {
      if !isPresented {
        uiViewController.dismiss(animated: true) {
          alreadyPresented = false
        }
      }
    } else {
      if isPresented {
        let controller = CustomHostingView(rootView: content)
        controller.view.backgroundColor = .systemBackground
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.permittedArrowDirections = arrowDirection
            
        controller.presentationController?.delegate = context.coordinator
            
        controller.popoverPresentationController?.sourceView = uiViewController.view
            
        uiViewController.present(controller, animated: true)
      }
    }
  }

  class Coordinator: NSObject,UIPopoverPresentationControllerDelegate{
    var parent: PopOverController
    init(parent: PopOverController) {
      self.parent = parent
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
      return .none
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
      parent.isPresented = false
    }
    
    func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
      DispatchQueue.main.async {
        self.parent.alreadyPresented = true
      }
    }
  }
}

class CustomHostingView<Content: View>: UIHostingController<Content>{
  override func viewDidLoad() {
    super.viewDidLoad()
    preferredContentSize = view.intrinsicContentSize
  }
}

extension String {   //Pre-Validation
    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=]).{8,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPred.evaluate(with: self)
    }
    
    var isValidEmail: Bool {
        let allowedCharacters = CharacterSet(charactersIn: "@-_.").union(.alphanumerics)
        let isValidLength = count <= 80
        let isValidCharacters = rangeOfCharacter(from: allowedCharacters.inverted) == nil
        let containsAlphanumeric = rangeOfCharacter(from: .alphanumerics) != nil
        
        return !isEmpty && contains("@") && isValidLength && isValidCharacters && containsAlphanumeric
    }
    
    var isValidIamSmartEmail: Bool {
        let allowedCharacters = CharacterSet(charactersIn: "@-_.").union(.alphanumerics)
        let isValidLength = count <= 80
        let isValidCharacters = rangeOfCharacter(from: allowedCharacters.inverted) == nil
        let containsAlphanumeric = rangeOfCharacter(from: .alphanumerics) != nil

        if isEmpty {
            return true // Allow empty email
        }

        return contains("@") && isValidLength && isValidCharacters && containsAlphanumeric
    }
    
    var isValidMobileNumber: Bool {
        let numericCharacterSet = CharacterSet.decimalDigits
        let numericString = self.trimmingCharacters(in: .whitespaces)
        
        // Check if the string contains only numeric characters
        guard numericString.rangeOfCharacter(from: numericCharacterSet.inverted) == nil else {
            return false
        }
        
        // Check if the string length is within the valid range
        let minimumLength = 8
        let maximumLength = 15
        let stringLength = numericString.count
        
        if stringLength < minimumLength || stringLength > maximumLength {
            return false
        }
        
        return true
    }

}

extension String{
    
    var htmlToAttributedString: NSAttributedString?
    {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return nil
            }
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
}

struct AttributedText: UIViewRepresentable {
    private let attributedString: NSAttributedString
    
    init(_ attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
    
    func makeUIView(context: Context) -> UITextView {
        // Called the first time SwiftUI renders this "View".
        
        let uiTextView = UITextView()
        
        // Make it transparent so that background Views can shine through.
        uiTextView.backgroundColor = .clear
        
        // For text visualisation only, no editing.
        uiTextView.isEditable = false
        
        // Make UITextView flex to available width, but require height to fit its content.
        // Also disable scrolling so the UITextView will set its `intrinsicContentSize` to match its text content.
        uiTextView.isScrollEnabled = false
        uiTextView.setContentHuggingPriority(.defaultLow, for: .vertical)
        uiTextView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiTextView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        uiTextView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        DispatchQueue.main.async {
            uiTextView.attributedText = self.attributedString
            uiTextView.sizeToFit()
        }
        
        return uiTextView
    }
    
    func updateUIView(_ uiTextView: UITextView, context: Context) {
        // Called the first time SwiftUI renders this UIViewRepresentable,
        // and whenever SwiftUI is notified about changes to its state. E.g via a @State variable.
        uiTextView.attributedText = attributedString
        self.updateTextViewHeight(uiTextView)
    }
    
    private func updateTextViewHeight(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
    }
}

extension NSAttributedString {
    static func html(withBody body: String) -> NSAttributedString {
        // Match the HTML `lang` attribute to current localisation used by the app (aka Bundle.main).
        let bundle = Bundle.main
        let lang = bundle.preferredLocalizations.first
            ?? bundle.developmentLocalization
            ?? "en"

        return (try? NSAttributedString(
            data: """
            <!doctype html>
            <html lang="\(lang)">
            <head>
                <meta charset="utf-8">
                <style type="text/css">
                    /*
                      Custom CSS styling of HTML formatted text.
                      Note, only a limited number of CSS features are supported by NSAttributedString/UITextView.
                    */

                    body {
                        font: -apple-system-body;
                        color: \(UIColor.secondaryLabel.hex);
                    }

                    h1, h2, h3, h4, h5, h6 {
                        color: \(UIColor.label.hex);
                    }

                    a {
                        color: \(UIColor.systemGreen.hex);
                    }

                    li:last-child {
                        margin-bottom: 1em;
                    }
                </style>
            </head>
            <body>
                \(body)
            </body>
            </html>
            """.data(using: .utf8)!,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: NSUTF8StringEncoding,
            ],
            documentAttributes: nil
        )) ?? NSAttributedString(string: body)
    }
}
// MARK: Converting UIColors into CSS friendly color hex string

private extension UIColor {
    var hex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return String(
            format: "#%02lX%02lX%02lX%02lX",
            lroundf(Float(red * 255)),
            lroundf(Float(green * 255)),
            lroundf(Float(blue * 255)),
            lroundf(Float(alpha * 255))
        )
    }
}

extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}

extension Color {
    static var ButtonBlue: Color {
        //return Color(red: 0.08, green: 0.49, blue: 0.72)
        return Color(hex: "0x2F6993")
        //157DB7
    }
    static var BackgroundBlue: Color {
        //return Color(red: 0.86, green: 0.96, blue: 1)
        return Color(hex: "0xDBF5FF")
    }
    static var iamSmartGreen: Color {
        //return Color(red: 0.17, green: 0.45, blue: 0.40)
        return Color(hex: "2B7366")
    }
    static var checkMarkGreen: Color {
        //return Color(red: 0.17, green: 0.45, blue: 0.40)
        return Color(hex: "198754")
    }
    static var customGray: Color {
        //return Color(red: 0.17, green: 0.45, blue: 0.40)
        return Color(hex: "E9ECEF")
        //F4F4F4
    }
}

extension Text {
    func titleStyle() ->  Text {
        self
            .font(.custom("Arial", size: 20).weight(.semibold))
            .foregroundColor(.black)
    }

    func titleWithoutBoldStyle() ->  Text {
        self
            .font(.custom("Arial", size: 20))
            .foregroundColor(.black)
    }

    func smallTitleStyle() ->  Text {
        self
            .font(.custom("Arial", size: 16).weight(.semibold))
            .foregroundColor(.black)
    }

    func contentStyle() ->  Text {
        self
            .font(.custom("Arial", size: 16))
            .foregroundColor(.black)
    }

    func infoStyle() ->  Text {
        self
            .font(.custom("Arial", size: 12))
            .foregroundColor(.black)
    }

    func errorStyle() ->  Text {
        self
            .font(.custom("Arial", size: 12))
            .foregroundColor(.red)
    }
}

//extension Text {
//    @ViewBuilder
//    func titleStyle() -> Text {
//        self
//            .font(.title2)
//            .fontWeight(.semibold)
//            .foregroundColor(.black)
//    }
//    
//    @ViewBuilder
//    func titleWithoutBoldStyle() -> Text {
//        self
//            .font(.title2)
//            .foregroundColor(.black)
//    }
//    
//    @ViewBuilder
//    func smallTitleStyle() -> Text {
//        self
//            .font(.body)
//            .fontWeight(.semibold)
//            .foregroundColor(.black)
//    }
//    
//    @ViewBuilder
//    func contentStyle() -> Text {
//        self
//            .font(.body)
//            .foregroundColor(.black)
//    }
//    
//    @ViewBuilder
//    func infoStyle() -> Text {
//        self
//            .font(.caption)
//            .foregroundColor(.black)
//    }
//    
//    @ViewBuilder
//    func errorStyle() -> Text {
//        self
//            .font(.footnote)
//            .foregroundColor(.red)
//    }
//}
//extension Text {
//    
//    func titleStyle() -> some View {
//        self
//            .font(.title2)
//            .fontWeight(.semibold)
//            .foregroundColor(.black)
//            .environment(\.sizeCategory, .large)
//            .lineLimit(1)
//            .minimumScaleFactor(0.5)
//            .allowsTightening(true)
//    }
//    
//    func titleWithoutBoldStyle() -> some View {
//        self
//            .font(.title2)
//            .foregroundColor(.black)
//            .environment(\.sizeCategory, .large)
//            .lineLimit(1)
//            .minimumScaleFactor(0.5)
//            .allowsTightening(true)
//    }
//    
//    func smallTitleStyle() -> some View {
//        self
//            .font(.subheadline)
//            .fontWeight(.semibold)
//            .foregroundColor(.black)
//            .environment(\.sizeCategory, .medium)
//            .lineLimit(1)
//            .minimumScaleFactor(0.5)
//            .allowsTightening(true)
//    }
//    
//    @ViewBuilder
//    func contentStyle() -> some View {
//        self
//            .font(.body)
//            .foregroundColor(.black)
//            .environment(\.sizeCategory, .medium)
//            .lineLimit(2)
//            .minimumScaleFactor(0.8)
//            .allowsTightening(true)
//    }
//    
//    func infoStyle() -> some View {
//        self
//            .font(.caption)
//            .foregroundColor(.black)
//            .environment(\.sizeCategory, .small)
//            .lineLimit(1)
//            .minimumScaleFactor(0.8)
//            .allowsTightening(true)
//    }
//    
//    func errorStyle() -> some View {
//        self
//            .font(.footnote)
//            .foregroundColor(.red)
//            .environment(\.sizeCategory, .small)
//            .lineLimit(1)
//            .minimumScaleFactor(0.8)
//            .allowsTightening(true)
//    }
//}

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
}

//class DatePickerTextField: UITextField {
//    
//    private var datePicker: UIDatePicker!
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupDatePicker()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupDatePicker()
//    }
//    
//    private func setupDatePicker() {
//        datePicker = UIDatePicker()
//        datePicker.datePickerMode = .date
//        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
//        inputView = datePicker
//    }
//    
//    @objc private func datePickerValueChanged() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
////        dateFormatter.dateStyle = .medium
////        dateFormatter.timeStyle = .none
//        text = dateFormatter.string(from: datePicker.date)
//    }
//}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension URL {
    var queryDictionary: [String: String]? {
        guard let query = self.query else { return nil}

        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {

            let key = pair.components(separatedBy: "=")[0]

            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""

            queryStrings[key] = value
        }
        return queryStrings
    }
}


extension String {
    func convertToLanguageCodeFormat() -> String {
        let components = self.lowercased().components(separatedBy: "-")
        guard components.count >= 2 else {
            return self
        }
        let languageCode = components[0]
        var regionCode = components[1].lowercased()
        
        if languageCode == "zh" {
            if regionCode == "hant" {
                regionCode = "hk"
            } else if regionCode == "hans" {
                regionCode = "cn"
            }
        }
        
        var convertedCode = "\(languageCode)-\(regionCode)"
        
        if components.count > 2 {
            let additionalComponents = components[2...].map { $0.lowercased() }
            convertedCode += "-" + additionalComponents.joined(separator: "-")
        }
        
        return convertedCode
    }
}

struct CustomNavigationView<Content: View>: View {
    @ViewBuilder var content: Content
    
    @State private var interactivePopGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let gesture = UIScreenEdgePanGestureRecognizer()
        gesture.name = UUID().uuidString
        gesture.edges = UIRectEdge.left
        gesture.isEnabled = true
        return gesture
    }()
    
    var body: some View {
        NavigationView {
            content
                .background {
                    AttachPopGestureView(gesture: $interactivePopGestureRecognizer)
                }
        }
    }
}

struct AttachPopGestureView: UIViewRepresentable {
    @Binding var gesture: UIScreenEdgePanGestureRecognizer
    
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            if let parentVC = uiView.parentViewController {
                if let navigationController = parentVC.navigationController {
                    
                    // To prevent duplication
                    guard !(navigationController.view.gestureRecognizers?
                        .contains(where: {$0.name == gesture.name}) ?? true) else { return }
                
                    navigationController.addInteractivePopGesture(gesture)
                }
            }
        }
    }
}

//MARK: - Helper
fileprivate extension UINavigationController {
    func addInteractivePopGesture(_ gesture: UIPanGestureRecognizer) {
        guard let gestureSelector = interactivePopGestureRecognizer?.value(forKey: "targets") else { return }
        
        gesture.setValue(gestureSelector, forKey: "targets")
        view.addGestureRecognizer(gesture)
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) { $0.next }.first(where: { $0 is UIViewController }) as? UIViewController
    }
}
