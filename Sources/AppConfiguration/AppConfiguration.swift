//
// Copyright (c) 2020 Rosberry. All rights reserved.
//

import Foundation
import Base

final class AppConfiguration {
    private static let developmentServerURL: URL = URL(string: "https://develop-api.rosberry.com")!
    private static let stagingServerURL: URL = URL(string: "https://staging-api.rosberry.com")!
    private static let productionServerURL: URL = URL(string: "https://api.rosberry.com")!

    static var serverURL: ConditionVariable<URL> = .init {
        DevelopmentServerValue(value: developmentServerURL)
        StagingServerValue(value: stagingServerURL)
        ProductionServerValue(value: productionServerURL)
    }
    static let isRelease: ConditionVariable<Bool> = .init {
        AppStoreValue(value: true)
        ConcreteValue(value: false)
    }
    static let buildConfiguration: ConditionVariable<String> = .init {
        ReleaseValue(value: "production")
        ConcreteValue(value: "development")
    }
}
