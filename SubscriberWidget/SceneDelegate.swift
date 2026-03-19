//
//  SceneDelegate.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2020-09-24.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit
import SwiftUI
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        UNUserNotificationCenter.current().delegate = self

        let contentView = MainView()

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }

        if let url = connectionOptions.urlContexts.first?.url {
            handleDeepLink(url)
        }

        if let notificationResponse = connectionOptions.notificationResponse {
            handleNotificationTap(notificationResponse)
        }
    }

    private func handleDeepLink(_ url: URL) {
        if url.host() == "paywall" {
            UserDefaults.shared?.set(true, forKey: "pendingPaywallFromWidget")
            NotificationCenter.default.post(name: .paywallRequested, object: nil)
            return
        }

        if let channelId = url.host() {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let widgetType = components?.queryItems?.first(where: { $0.name == "widgetType" })?.value ?? "unknown"
            openYoutubeChannel(channelId, widgetType: widgetType)
        }
    }

    private func handleNotificationTap(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo

        guard let type = userInfo["type"] as? String,
              type == "milestone_notification",
              let channelId = userInfo["channelId"] as? String else {
            return
        }

        AnalyticsService.shared.logMilestoneNotificationTapped(channelId: channelId)
        openYoutubeChannel(channelId, widgetType: "milestone_notification")
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            handleDeepLink(url)
        }
    }

    func openYoutubeChannel(_ channelId: String, widgetType: String) {
        let channelUrl = StringUtils.getChannelUrlFromId(channelId)
        AnalyticsService.shared.logChannelDeepLinkOpened(channelUrl, widgetType: widgetType)
        UIApplication.shared.open(URL(string: channelUrl)!, options: [:], completionHandler: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        ReviewPromptService.shared.registerAppOpen()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

extension SceneDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotificationTap(response)
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}
