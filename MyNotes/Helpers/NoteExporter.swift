//
//  NoteExporter.swift
//  MyNotes
//
//  Created by David Noy on 01/06/2025.
//

import Foundation
import PDFKit
import SwiftUI

struct NoteExporter {
    
    static func export(note: Note, locationName: String?) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "MyNotes",
            kCGPDFContextAuthor: "MyNotes App",
            kCGPDFContextTitle: note.title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 612.0
        let pageHeight = 792.0
        let margin: CGFloat = 40
        let contentWidth = pageWidth - 2 * margin
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pdf")
        
        do {
            try renderer.writePDF(to: fileURL) { context in
                context.beginPage()
                var yOffset: CGFloat = margin

                func checkPageBreak(for height: CGFloat) {
                    if yOffset + height > pageHeight - margin {
                        context.beginPage()
                        yOffset = margin
                    }
                }
                
                func drawText(_ text: String, font: UIFont, color: UIColor = .black) {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineBreakMode = .byWordWrapping
                    paragraphStyle.alignment = .left
                    
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .paragraphStyle: paragraphStyle,
                        .foregroundColor: color
                    ]
                    
                    let attrString = NSAttributedString(string: text, attributes: attributes)
                    let size = attrString.boundingRect(
                        with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                        options: .usesLineFragmentOrigin,
                        context: nil
                    )
                    
                    checkPageBreak(for: size.height + 16)
                    attrString.draw(in: CGRect(x: margin, y: yOffset, width: contentWidth, height: size.height))
                    yOffset += size.height + 16
                }
                
                // Title
                drawText(note.title, font: .boldSystemFont(ofSize: 42))
                yOffset += 16

                // Location
                if let locationName {
                    drawText(locationName, font: .systemFont(ofSize: 18), color: .darkGray)
                    yOffset += 8
                }
                
                yOffset += 16
                
                switch note.type {
                case .textType:
                    if !note.content.isEmpty {
                        drawText(note.content, font: .systemFont(ofSize: 24))
                        yOffset += 16
                    }
                case .todo:
                    for item in note.todos {
                        let prefix = item.isComplete ? "✅ " : ""
                        let color: UIColor = item.isComplete ? .gray : .black
                        let font = item.isComplete ? UIFont.systemFont(ofSize: 18) : UIFont.systemFont(ofSize: 24)
                        drawText(prefix + item.item, font: font, color: color)
                    }
                    yOffset += 16
                }

                // Image
                if let image = note.getImage() {
                    let maxImageWidth = contentWidth
                    let aspectRatio = image.size.height / image.size.width
                    let imageHeight = maxImageWidth * aspectRatio
                    
                    checkPageBreak(for: imageHeight + 16)
                    let rect = CGRect(x: margin, y: yOffset, width: maxImageWidth, height: imageHeight)
                    image.draw(in: rect)
                    yOffset += imageHeight + 16
                }
            }
            return fileURL
        } catch {
            print("Failed to create PDF: \(error.localizedDescription)")
            return nil
        }
    }
}
