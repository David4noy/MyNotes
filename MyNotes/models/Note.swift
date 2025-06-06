//
//  Untitled.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Note: Identifiable, Hashable, Codable {
    var id = UUID().uuidString
    var title: String
    var content: String
    var todos: [TodoItem]
    var isRightToLeft: Bool
    var type: NoteType
    var color: NoteColor
    var creationDate: Date
    var latitude: Double?
    var longitude: Double?

    @Attribute(.externalStorage)
    private var imageData: Data?

    init(
        title: String,
        type: NoteType,
        color: NoteColor,
        content: String = "",
        todos: [TodoItem] = [],
        creationDate: Date = Date(),
        latitude: Double?,
        longitude: Double?
    ) {
        self.title = title
        self.type = type
        self.color = color
        self.content = content
        self.todos = todos
        self.creationDate = creationDate
        self.latitude = latitude
        self.longitude = longitude
        self.isRightToLeft = isAppInHebrew ? false : true
    }

    // MARK: - Codable

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let content = try container.decode(String.self, forKey: .content)
        let todos = try container.decode([TodoItem].self, forKey: .todos)
        let isRightToLeft = try container.decodeIfPresent(Bool.self, forKey: .isRightToLeft) ?? false
        let type = try container.decode(NoteType.self, forKey: .type)
        let color = try container.decode(NoteColor.self, forKey: .color)
        let creationDate = try container.decode(Date.self, forKey: .creationDate)
        let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        let imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)

        self.init(title: title, type: type, color: color, content: content, todos: todos, creationDate: creationDate, latitude: latitude, longitude: longitude)
        self.id = id
        self.imageData = imageData
        self.isRightToLeft = isRightToLeft
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(todos, forKey: .todos)
        try container.encode(isRightToLeft, forKey: .isRightToLeft)
        try container.encode(type, forKey: .type)
        try container.encode(color, forKey: .color)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(imageData, forKey: .imageData)
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, content, todos, isRightToLeft, type, color, creationDate, latitude, longitude, imageData
    }

    // MARK: - Equatable + Hashable

    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Image Helpers

    func setImage(from uiImage: UIImage) {
        self.imageData = uiImage.pngData()
    }

    func setImageData(_ data: Data?) {
        self.imageData = data
    }

    func getImage() -> UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
}

struct TodoItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var item: String
    var isComplete: Bool
}

enum NoteType: String, CaseIterable, Codable {
    case textType
    case todo
}
