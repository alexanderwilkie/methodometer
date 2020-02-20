//
//  BluetoothRow.swift
//  Methodometer
//
//  Created by Alex on 2020-02-15.
//  Copyright © 2020 Holden Collective. All rights reserved.
//

import SwiftUI

struct BluetoothRow: View {
    var name: String
    var state: String
    var action: () -> Void
    
    var body: some View {
        
    }
}

struct BluetoothRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BluetoothRow(name: "Alexander's Macbook Pro", state: "Bar", action: {print("foo")})
            //BluetoothRow(name: "Bar", state: "Foo", action: {})
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
