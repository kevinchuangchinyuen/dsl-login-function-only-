//
//  ValidationVIew.swift
//  dsl
//
//  Created by chuang chin yuen on 28/2/2024.
//

import SwiftUI

enum ValidationState{
    case Landing
    case NetworkError
    case OsError
    case AppVerError
    case JailbreakError
}

struct ValidationView: View {
    
    @ObservedObject private var service: MainViewService
    
    @State private var currentState: ValidationState = .Landing

    init(service: MainViewService){
        self.service = service
    }

    var body: some View {
        ZStack{
            if service.isNetworkAvailable && service.isSupportediOSVersion && service.isSupportedAppVersion && service.isNotJailbroken{
                viewForState(.Landing)
            } else if !service.isNetworkAvailable{
                viewForState(.NetworkError)
            } else if !service.isSupportediOSVersion{
                viewForState(.OsError)
            } else if !service.isSupportedAppVersion{
                viewForState(.AppVerError)
            } else if !service.isNotJailbroken{
                viewForState(.JailbreakError)
            }
        }
        //viewForState(currentState)
        .onAppear {
            service.performValidation()
        }
    }
    
    @ViewBuilder
    private func viewForState(_ state: ValidationState) -> some View {
        switch state {
        case .Landing:
            MainView(service: self.service)
        case .NetworkError:
            NetworkErrorView()
        case .OsError:
            OsErrorView()
        case .AppVerError:
            AppVerErrorView()
        case .JailbreakError:
            JailbreakErrorView()
        }
    }

}

//#Preview {
//    ValidationVIew()
//}
