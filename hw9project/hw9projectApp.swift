//
//  hw9projectApp.swift
//
//  Created by Yechan Seo on 4/10/23.
//

import SwiftUI
import Alamofire


@main
struct hw9projectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
