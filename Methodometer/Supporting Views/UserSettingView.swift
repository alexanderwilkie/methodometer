//
//  UserSettingView.swift
//  Methodometer
//
//  Created by Alex on 2020-03-30.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct UserSettingView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var userPrefs: UserPreferences
    
    func updatePreferences() {
        self.userPrefs.updateUserDefaults()
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preferences")) {
                    Picker(selection: self.$userPrefs.distanceUnit, label: Text("Distance Units")) {
                        Text("Miles").tag(DistanceUnit.miles)
                        Text("Kilometers").tag(DistanceUnit.kilometers)
                    }
                }
                
                Button(action: {
                    self.updatePreferences()
                }) {
                    Text("Update Preferences")
                }
            }
        }
    }
}

struct UserSettingView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingView()
    }
}
