//
//  NotesListViewModel.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import Foundation

class NotesListViewModel: ObservableObject {
    init() {}
    
    
    
}


func getBackupToDo() -> Note? {
    let json = """
    {
      "todos": [
        {
          "item": "קפיצה לסוף או תחילת הטבלה בהוספת פריט\\n- זה נכנס לראשון הקודם",
          "isComplete": true,
          "id": "3DC8D208-F85F-44EF-8A9B-A9C6223327A6"
        },
        {
          "item": "ביטול צבע כחול או שינוי כפתורים",
          "isComplete": true,
          "id": "97FFDA10-EEBE-49D4-B03E-CD47623E882D"
        },
        {
          "item": "תיקון התא במצב עריכה של פריט ברשימת ביצוע",
          "isComplete": true,
          "id": "4A86DA28-E3F1-4FED-A340-3A634A77665F"
        },
        {
          "item": "לבדוק שגיאות",
          "isComplete": false,
          "id": "D87247AD-8A44-442B-A64A-A6A506E71AD0"
        },
        {
          "item": "ייצוא של פתק מאובטח עם שיתוף",
          "isComplete": false,
          "id": "A9BBABD7-DD4F-40D0-89F0-5CA2578103C0"
        },
        {
          "item": "יצוא של pdf",
          "isComplete": false,
          "id": "173CDDE1-BB99-4535-8138-4C5734195926"
        },
        {
          "item": "נוטיפיקציות מתוזמנות לוקאליות",
          "isComplete": false,
          "id": "AF190297-3758-43DF-B37E-770D70EE4FF2"
        },
        {
          "item": "מסך הגדרות",
          "isComplete": false,
          "id": "7546B288-F576-440F-BAC6-F46ECF4FC0E9"
        },
        {
          "item": "לקיחת תמונה",
          "isComplete": true,
          "id": "19A107BE-A205-45BC-AEEA-F11EBEB938A5"
        },
        {
          "item": "Accessibility ",
          "isComplete": false,
          "id": "F95593DD-E87B-4135-9206-9BDDADF7250A"
        },
        {
          "item": "פוש נוטיפיקיישן עם חיוב עדכון גירסה",
          "isComplete": false,
          "id": "8CD967E8-15CF-4A75-8429-13BF445B2D2F"
        },
        {
          "item": "iCloud ",
          "isComplete": false,
          "id": "33CC4FEB-67DA-438D-AD92-2A0B0FBD25E1"
        },
        {
          "item": "Widget",
          "isComplete": false,
          "id": "56E3F0A3-A072-4D28-B6DE-C3A75DC74B04"
        },
        {
          "item": "תנאי שימוש",
          "isComplete": false,
          "id": "6BFAA6A0-0538-441C-8ACA-F9B4E00C3F68"
        },
        {
          "item": "כפתור תפריט עם:\\nשיתוף\\nייצוא\\nשינוי צבע\\nכתובת\\nצילום תמונה\\nעריכה",
          "isComplete": false,
          "id": "5614018A-3789-4C3D-BD17-D5E92EAAC484"
        }
      ],
      "color": {
        "orange": {}
      },
      "id": "2FF537E3-9014-44FA-AC99-BF7C515DA262",
      "title": "לאפליקציה - מינימום",
      "type": "todo",
      "content": "",
      "creationDate": 770466339.680477
    }
    """

    let data = Data(json.utf8)
    do {
        let note = try JSONDecoder().decode(Note.self, from: data)
        return note
    } catch {
        print("❌ Failed to decode Note: \(error.localizedDescription)")
        return nil
    }
}
