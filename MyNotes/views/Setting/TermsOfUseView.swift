//
//  TermsOfUseView.swift
//  MyNotes
//
//  Created by David Noy on 06/06/2025.
//

import SwiftUI

struct TermsOfUseView: View {
    
    let termsOfUseEnglish = """
    Terms of Use

    Welcome to My Note. By using this app, you agree to the following terms:

    1. The app is provided "as is" without warranties of any kind.
    2. You are responsible for backing up your notes; while we offer iCloud backup, we do not guarantee data recovery.
    3. We do not collect or share your personal data.
    4. Use the app at your own risk; we are not liable for any damages or data loss.
    5. The app content is for personal use only and cannot be redistributed or resold.
    6. We reserve the right to update or modify the app and these terms at any time.

    If you do not agree with these terms, please do not use the app.
    """

    let termsOfUseHebrew = """
    תנאי שימוש

    ברוכים הבאים לפתקים שלי. בשימוש באפליקציה זו, אתם מסכימים לתנאים הבאים:

    1. האפליקציה מסופקת "כפי שהיא" ללא התחייבויות מכל סוג.
    2. אתם אחראים לגיבוי הפתקים שלכם; למרות שיש גיבוי ב-iCloud, איננו מבטיחים שחזור נתונים.
    3. אנו לא אוספים או משתפים את הנתונים האישיים שלכם.
    4. השימוש באפליקציה הוא על אחריותכם בלבד; איננו אחראים לנזקים או לאובדן נתונים.
    5. תוכן האפליקציה מיועד לשימוש אישי בלבד ואסור להפצה או מכירה.
    6. אנו שומרים לעצמנו את הזכות לעדכן או לשנות את האפליקציה ואת תנאי השימוש בכל עת.

    אם אינכם מסכימים לתנאים, אנא אל תשתמשו באפליקציה.
    """


    
    var body: some View {
        Text(isAppInHebrew ? termsOfUseHebrew : termsOfUseEnglish)
            .padding()
            .navigationTitle("Terms of Use")
    }
}
