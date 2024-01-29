//
//  EmailForm.swift
//  SubscriberWidget
//
//  Created by Arjun Dureja on 2023-09-17.
//  Copyright © 2023 Arjun Dureja. All rights reserved.
//

import SwiftUI
import MessageUI

class EmailHelper: NSObject {
    static let shared = EmailHelper()
    private override init() {}
}

extension EmailHelper {
    func send(subject: String, to email: String) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene

        guard let viewController = windowScene?.windows.first?.rootViewController else {
            return
        }

        if !MFMailComposeViewController.canSendMail() {
            let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

            if let url = createEmailUrl(to: email, subject: subjectEncoded),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }

            let alert = UIAlertController(
                title: "Cannot open mail",
                message: "Please install a mail app to continue",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
            return
        }

        let mailCompose = MFMailComposeViewController()
        mailCompose.setSubject(subject)
        mailCompose.setToRecipients([email])
        mailCompose.mailComposeDelegate = self

        viewController.present(mailCompose, animated: true, completion: nil)
    }

    private func createEmailUrl(to email: String, subject: String) -> URL? {
        let gmailUrl = URL(string: "googlegmail://co?to=\(email)&subject=\(subject)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(email)&subject=\(subject)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(email)&subject=\(subject)")
        let defaultUrl = URL(string: "mailto:\(email)?subject=\(subject)")

        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        }

        return defaultUrl
    }

}

extension EmailHelper: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
