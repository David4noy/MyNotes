//
//  AboutView.swift
//  MyNotes
//
//  Created by David Noy on 06/06/2025.
//

import SwiftUI

struct AboutView: View {
    
    let aboutEnglish = """
    About My Note

    MyNote is your all-in-one note-taking companion, designed to help you capture every thought, idea, and task with ease and style.

    Features you’ll love:
    - Create free text notes or to-do lists to keep organized.
    - Add photos to enrich your notes.
    - Add a single location to each note to remember where it was created.
    - Customize your notes with beautiful colors to quickly identify and organize.
    - Seamlessly sync and back up all your notes with iCloud, so your data is safe and accessible across all your devices.
    - Share your notes securely or export them as PDF files for easy sharing and backup.
    - Enjoy a clean and intuitive interface that keeps your workflow smooth.

    Your data is stored safely with iCloud sync, but please remember to back up your notes regularly.

    Whether you’re jotting down quick reminders or managing complex projects, My Note is here to empower your productivity with simplicity and power.

    Get started and experience note-taking like never before!
    And thanks for using My Notes 😊
    """

    let aboutHebrew = """
    אודות ״הפתקים שלי״

    הפתקים שלי היא האפליקציה המושלמת לניהול רשימות, שנועדה לעזור לכם לתפוס כל מחשבה, רעיון ומשימה בקלות ובסטייל.

    תכונות שתרצו:
    - יצירת רשימות טקסט חופשי או רשימות מטלות לארגון מושלם.
    - הוספת תמונות להעשיר את הפתקים שלכם.
    - הוספת מיקום לכל פתק כדי לזכור היכן הוא נוצר.
    - התאמה אישית של ההערות עם צבעים יפים לזיהוי מהיר וארגון.
    - סינכרון וגיבוי חלק עם iCloud, כך שהנתונים שלכם בטוחים ונגישים בכל המכשירים.
    - שיתוף הפתקים בצורה מאובטחת או ייצוא כקובצי PDF לשיתוף וגיבוי נוח.
    - ממשק נקי ואינטואיטיבי שמאפשר עבודה חלקה.

    הנתונים שלכם נשמרים בבטחה עם סינכרון iCloud, אך מומלץ לגבות את הפתקים שלכם באופן שוטף.

    בין אם אתם כותבים תזכורות מהירות או מנהלים פרויקטים מורכבים, ״הפתקים שלי״ תומכת בכם עם פשטות וכוח.

    התחילו עכשיו וחוו את ניהול הרשימות בצורה חדשה לחלוטין!
    ותודה שבחרתם בפתקים שלי 😊
    """
    
    var body: some View {
        Text(isAppInHebrew ? aboutHebrew : aboutEnglish)
            .padding()
            .navigationTitle("About")
    }
}
