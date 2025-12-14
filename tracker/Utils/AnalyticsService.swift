//
//  AnalyticsService.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 13.12.2025.
//

import AppMetricaCore

final class AnalyticsService {
    static func activate() {
        guard
            let configuration = AppMetricaConfiguration(apiKey: "df921291-e648-4d41-b9ab-2fed5d4005dd")
        else { return }
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
