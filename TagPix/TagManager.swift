//
//  TagManager.swift
//  TagPix
//
//  Created by Matthew Burke on 10/11/24.
//

import CoreNFC
import Foundation

class TagManager: NSObject, NFCNDEFReaderSessionDelegate {
    static let mimeType = "application/octet-stream"

    private var callback: TagCallback?
    private var data: Data?
    private var mode: TagMode = .read
    private var readerSession: NFCNDEFReaderSession?

    // MARK: - Main entry points
    
    func read(callback: TagCallback? = nil) {
        guard NFCReaderSession.readingAvailable else {
            callback?(.failure(TagError.nfcUnsupported))
            return
        }

        self.callback = callback
        mode = .read
        readerSession = NFCNDEFReaderSession(delegate: self,
                                             queue: nil,
                                             invalidateAfterFirstRead: true)
        readerSession?.alertMessage = "Get closer to the tag to read it."
        readerSession?.begin()
    }

    func write(data: Data, callback: TagCallback? = nil) {
        guard NFCNDEFReaderSession.readingAvailable else {
            callback?(.failure(TagError.nfcUnsupported))
            return
        }

        self.data = data
        self.callback = callback
        mode = .write
        readerSession = NFCNDEFReaderSession(delegate: self,
                                             queue: nil,
                                             invalidateAfterFirstRead: true)
        readerSession?.alertMessage = "Get closer to the tag to write to it."
        readerSession?.begin()
    }

    // MARK: - NFCNDEFReaderSessionDelegate methods

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {}
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "Detected more than 1 tag. Please remove all tags and try again."

            // backing off Swift 6/strict concurrency checks due to this ...
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })

            // should we invoke callback?
            return
        }

        guard let tag = tags.first else {
            print("Not able to get first tag.")
            // Should we invalidate session? Run the callback with .failure()?
            session.alertMessage = "Not able to get tag, please try again."

            // should we invoke callback?
            return
        }

        // also blocking strict concurrency checks ...
        // possible solution: https://forums.swift.org/t/how-do-i-solve-task-isolated-value-passed-as-strongly-transferred-parameter-warning/73870/2
        Task {
            let result: Result<SuccessPayload, TagError>
            do {
                try await session.connect(to: tag)
                let (status, capacity) = try await tag.queryNDEFStatus()
                print(status, capacity)

                switch status {
                case .notSupported:
                    session.alertMessage = "The tag is not NDEF compliant."
                    result = .failure(.notSupported)

                case .readOnly:
                    if mode == .read {
                        let message = try await tag.readNDEF()
                        result = processNDEF(message)
                    } else {
                        session.alertMessage = "Cannot write; the tag is read-only."
                        result = .failure(.readOnly)
                    }
                case .readWrite:
                    if mode == .read {
                        let message = try await tag.readNDEF()
                        result = processNDEF(message)
                    } else {
                        if let data {
                            let message = try createNDEFMessage(data: data)
                            try await tag.writeNDEF(message)
                            result = .success(.write)
                        } else {
                            result = .failure(.noData)
                        }
                    }
                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                    result = .failure(.unknownStatus)
                }
            } catch (let error) {
                print("Failed with error: \(error.localizedDescription)")
                session.alertMessage = "Interacting with the tag failed."
                result = .failure(.general)
            }

            callback?(result)
            session.invalidate()
        }
    }

    // MARK: NDEF Message handling methods

    private func processNDEF(_ message: NFCNDEFMessage) -> Result<SuccessPayload, TagError> {
        guard message.records.count > 0 else {
            return .failure(.incorrectRecordCount)
        }

        let record = message.records[0]

        guard record.typeNameFormat == .media else {
            return .failure(.messageFormat)
        }

        guard let mimeType = String(data: record.type, encoding: .utf8),
                mimeType == TagManager.mimeType else {
            return .failure(.messageFormat)
        }

        guard let grid = Grid(from: record.payload) else {
            return .failure(.messageFormat)
        }

        return .success(.read(grid))
    }

    private func createNDEFMessage(data: Data) throws -> NFCNDEFMessage {
        guard let type = TagManager.mimeType.data(using: .utf8) else {
            throw TagError.recordCreation
        }

        let payload = NFCNDEFPayload(format: .media,
                                     type: type,
                                     identifier: Data(),
                                     payload: data,
                                     chunkSize: 0)

        return NFCNDEFMessage(records: [payload])

    }
}

// MARK: - Supporting Type Definitions

enum TagError: Error {
    case general // TODO: replace this with specific values
    case incorrectRecordCount
    case messageFormat
    case nfcUnsupported
    case noData
    case notSupported
    case readOnly
    case recordCreation
    case unknownStatus
}

enum TagMode {
    case read
    case write
}

enum SuccessPayload {
    case read(Grid)
    case write
}

typealias TagCallback = (Result<SuccessPayload, TagError>) -> Void

