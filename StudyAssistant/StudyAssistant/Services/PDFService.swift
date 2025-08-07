import Foundation
import PDFKit
import Combine

class PDFService: ObservableObject {
    
    func extractTextFromPDF(at url: URL) -> AnyPublisher<String, Error> {
        return Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let pdfDocument = PDFDocument(url: url) else {
                    promise(.failure(PDFError.failedToLoadDocument))
                    return
                }
                
                var fullText = ""
                let pageCount = pdfDocument.pageCount
                
                for i in 0..<pageCount {
                    guard let page = pdfDocument.page(at: i),
                          let pageText = page.string else {
                        continue
                    }
                    fullText += pageText + "\n"
                }
                
                promise(.success(fullText))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func extractTextFromPDFData(_ data: Data) -> AnyPublisher<String, Error> {
        return Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let pdfDocument = PDFDocument(data: data) else {
                    promise(.failure(PDFError.failedToLoadDocument))
                    return
                }
                
                var fullText = ""
                let pageCount = pdfDocument.pageCount
                
                for i in 0..<pageCount {
                    guard let page = pdfDocument.page(at: i),
                          let pageText = page.string else {
                        continue
                    }
                    fullText += pageText + "\n"
                }
                
                promise(.success(fullText))
            }
        }
        .eraseToAnyPublisher()
    }
    
    enum PDFError: Error {
        case failedToLoadDocument
        case noTextFound
    }
}
