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

    /// Increments a counter at `appopened/counts/total` every time the app opens
    /// and returns the new total.
    func incrementAppOpenCount(completion: @escaping (Int?) -> Void) {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let docRef = db.collection("appopened").document("counts")

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let snapshot = try transaction.getDocument(docRef)
                let current = (snapshot.data()?["total"] as? Int) ?? 0
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
                print("Firebase error incrementing app open count: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        })
        #else
        completion(nil)
        #endif
    }

    /// Ensures the user document exists in the users collection every time the app opens.
    /// Creates it if it doesn't exist, updates it if it does.
    /// Returns the user count if a new document was created, nil otherwise.
    func ensureUserDocumentExists(completion: @escaping (Int?) -> Void) {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let uuid = installationUUID()
        let userDoc = db.collection("users").document(uuid)
        
        // Check if document exists
        userDoc.getDocument { (document, error) in
            if let error = error {
                print("Firebase error checking user document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let document = document, document.exists {
                // Document exists, update the lastOpened timestamp
                userDoc.updateData([
                    "lastOpened": FieldValue.serverTimestamp(),
                    "updatedAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("Firebase error updating user document: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        print("User document updated successfully for UUID: \(uuid)")
                        completion(nil) // No new user, so no count to return
                    }
                }
            } else {
                // Document doesn't exist, create it and increment user count
                print("Creating new user document for UUID: \(uuid)")
                
                // First create the user document
                userDoc.setData([
                    "id": uuid,
                    "createdAt": FieldValue.serverTimestamp(),
                    "firstOpened": FieldValue.serverTimestamp(),
                    "lastOpened": FieldValue.serverTimestamp(),
                    "updatedAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("Firebase error creating user document: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }
                    
                    print("User document created successfully for UUID: \(uuid)")
                    
                    // Now increment the user count and return the new total
                    let countDoc = db.collection("usercount").document("count")
                    db.runTransaction({ (transaction, errorPointer) -> Any? in
                        do {
                            let snap = try transaction.getDocument(countDoc)
                            let data = snap.data() ?? [:]
                            let current = (data["current"] as? Int) ?? 0
                            let next = current + 1
                            transaction.setData([
                                "current": next, 
                                "updatedAt": FieldValue.serverTimestamp()
                            ], forDocument: countDoc, merge: true)
                            return next
                        } catch let error {
                            errorPointer?.pointee = error as NSError
                            return nil
                        }
                    }, completion: { result, error in
                        if let newCount = result as? Int, error == nil {
                            print("Successfully incremented user count to: \(newCount)")
                            completion(newCount)
                        } else {
                            print("Firebase error incrementing user count: \(error?.localizedDescription ?? "Unknown error")")
                            completion(nil)
                        }
                    })
                }
            }
        }
        #else
        completion(nil)
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

    /// Returns a stable per-install UUID stored in UserDefaults.
    private func installationUUID() -> String {
        let key = "appDeviceUUID"
        if let cached = UserDefaults.standard.string(forKey: key) {
            return cached
        }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: key)
        return new
    }

    /// Register first launch: stores the install UUID under `userids/{uuid}` and
    /// increments `usercount/count.value` in a transaction. Returns the new total.
    func registerFirstLaunchUserAndIncrementTotal(completion: @escaping (Int?) -> Void) {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let uuid = installationUUID()

        // 1) Write the UUID document (id as document ID for quick existence checks)
        let userDoc = db.collection("userids").document(uuid)
        userDoc.setData([
            "id": uuid,
            "createdAt": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                print("Firebase error writing user document: \(error.localizedDescription)")
            } else {
                print("Successfully registered user with UUID: \(uuid)")
            }
        }

        // 2) Increment total count atomically at usercount/count
        let countDoc = db.collection("usercount").document("count")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let snap = try transaction.getDocument(countDoc)
                let data = snap.data() ?? [:]
                let current = (data["value"] as? Int) ?? (data["current"] as? Int) ?? 0
                let next = current + 1
                transaction.setData(["value": next, "current": next, "updatedAt": FieldValue.serverTimestamp()], forDocument: countDoc, merge: true)
                return next
            } catch let error {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }, completion: { result, error in
            if let n = result as? Int, error == nil { 
                print("Successfully incremented user count to: \(n)")
                completion(n) 
            } else { 
                print("Firebase error incrementing user count: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil) 
            }
        })
        #else
        completion(nil)
        #endif
    }
}

