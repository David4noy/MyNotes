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
    var id: String = UUID().uuidString
    var title: String = ""
    var content: String = ""
    var todos: [TodoItem] = []
    var isRightToLeft: Bool = isAppInHebrew
    var type: NoteType = NoteType.textType
    var color: NoteColor = NoteColor.yellow
    var creationDate: Date = Date()
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
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.title = title
        self.type = type
        self.color = color
        self.content = content
        self.todos = todos
        self.creationDate = creationDate
        self.latitude = latitude
        self.longitude = longitude
        self.isRightToLeft = isAppInHebrew
    }

    // MARK: - Codable

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        let title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        let content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        let todos = try container.decodeIfPresent([TodoItem].self, forKey: .todos) ?? []
        let isRightToLeft = try container.decodeIfPresent(Bool.self, forKey: .isRightToLeft) ?? false
        let type = try container.decodeIfPresent(NoteType.self, forKey: .type) ?? .textType
        let color = try container.decodeIfPresent(NoteColor.self, forKey: .color) ?? .yellow
        let creationDate = try container.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date()
        let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        let imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)

        self.init(title: title,
                  type: type,
                  color: color,
                  content: content,
                  todos: todos,
                  creationDate: creationDate,
                  latitude: latitude,
                  longitude: longitude)
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

    static func == (lhs: Note, rhs: Note) -> Bool { lhs.id == rhs.id }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Image Helpers

    func setImage(from uiImage: UIImage) { self.imageData = uiImage.pngData() }
    func setImageData(_ data: Data?) { self.imageData = data }
    func getImage() -> UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
    func deleteImage() { self.imageData = nil }
}

struct TodoItem: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var item: String = ""
    var isComplete: Bool = false
}

enum NoteType: String, CaseIterable, Codable {
    case textType
    case todo
}
