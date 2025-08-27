//
//  FirebaseManager.swift
//  learningSwift
//
//  Creates a small wrapper around Firebase initialization and a Firestore
//  transaction that increments a global downloads counter and returns the
//  new value.
//

import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

final class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}

    /// Call at app launch to configure Firebase once.
    func configureIfNeeded() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        #endif
    }

    /// Increments a counter at `appMeta/downloads.total` using a Firestore transaction
    /// and returns the new total. If Firestore is not available at compile time,
    /// this calls completion with nil so the app can degrade gracefully.
    func fetchAndIncrementDownloadCount(completion: @escaping (Int?) -> Void) {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let docRef = db.collection("appMeta").document("downloads")

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let snapshot = try transaction.getDocument(docRef)
                let current = (snapshot.data()? ["total"] as? Int) ?? 0
                let next = current + 1
                transaction.setData(["total": next, "updatedAt": FieldValue.serverTimestamp()], forDocument: docRef, merge: true)
                return next
            } catch let error {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }, completion: { result, error in
            if let count = result as? Int, error == nil {
                completion(count)
            } else {
                completion(nil)
            }
        })
        #else
        completion(nil)
        #endif
    }
}

