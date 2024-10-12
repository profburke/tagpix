//
//  TagManager.swift
//  TagPix
//
//  Created by Matthew Burke on 10/11/24.
//

import CoreNFC
import Foundation

enum TagError: Error {
    case general
    case incorrectRecordCount
    case messageFormat
    case nfcUnsupported
    case recordCreation
}

enum TagMode {
    case read
    case write
}

class TagManager: NSObject, NFCNDEFReaderSessionDelegate {
    private var readerSession: NFCNDEFReaderSession?
    private var mode: TagMode = .read
    private var data: Data?

    // TODO: fill in the following method
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {}
    // The following method is deliberately empty.
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}

    func read() throws {
        guard NFCReaderSession.readingAvailable else {
            throw TagError.nfcUnsupported
        }

        mode = .read
        readerSession = NFCNDEFReaderSession(delegate: self,
                                             queue: nil,
                                             invalidateAfterFirstRead: true)
        readerSession?.alertMessage = "Get closer to the tag to read it!"
        readerSession?.begin()
    }

    func write(data: Data) throws {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw TagError.nfcUnsupported
        }

        mode = .write
        self.data = data
        readerSession = NFCNDEFReaderSession(delegate: self,
                                             queue: nil,
                                             invalidateAfterFirstRead: true)
        readerSession?.alertMessage = "Get closer to the tag to write to it!"
        readerSession?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "Detected more than 1 tag. Please remove all tags and try again."

            // backing off Swift 6/strict concurrency checks due to this ...
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }

        guard let tag = tags.first else {
            print("Not able to get first tag.")
            session.alertMessage = "Not able to get tag, please try again."
            return
        }

        // also blocking strict concurrency checks ...
        // possible solution: https://forums.swift.org/t/how-do-i-solve-task-isolated-value-passed-as-strongly-transferred-parameter-warning/73870/2
        Task {
            do {
                try await session.connect(to: tag)
                let (status, _) = try await tag.queryNDEFStatus()

                switch status {
                case .notSupported:
                    session.alertMessage = "The tag is not NDEF compliant."
                case .readOnly:
                    if mode == .read {
                        let message = try await tag.readNDEF()
                        try processNDEF(message)
                    } else {
                        session.alertMessage = "Cannot write; the tag is read-only."
                    }
                case .readWrite:
                    if mode == .read {
                        let message = try await tag.readNDEF()
                        try processNDEF(message)
                    } else {
                        guard let data else {
                            print("should there be an error message here and/or a throw")
                            return
                        }

                        let message = try createNDEFMessage(data: data)
                        try await tag.writeNDEF(message)

                        // callback?()
                    }
                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                }

                session.invalidate() // FIXME: defer?
            } catch (let error) {
                // throw ...
                print("Failed with error: \(error.localizedDescription)")
                session.alertMessage = "Interacting with the tag failed."
                session.invalidate()
            }
        }
    }

    private func processNDEF(_ message: NFCNDEFMessage) throws {
        guard message.records.count == 1 else {
            throw TagError.incorrectRecordCount
        }

        let record = message.records[0]

        guard record.typeNameFormat == .media else {
            throw TagError.messageFormat
        }

        guard let mimeType = String(data: record.type, encoding: .utf8), mimeType == "application/octet-stream" else {
            throw TagError.messageFormat
        }

        guard let grid = Grid(from: record.payload[1...]) else {
            throw TagError.messageFormat
        }

        // and then what?
    }

    private func createNDEFMessage(data: Data) throws -> NFCNDEFMessage {
        guard let type = "application/octet-stream".data(using: .utf8) else {
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
