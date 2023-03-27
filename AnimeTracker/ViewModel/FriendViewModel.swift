//
//  FriendViewModel.swift
//  AnimeTracker
//
//  Created by Timmy Nguyen on 2/21/23.
//

import Foundation
import CloudKit

@MainActor
class FriendViewModel: ObservableObject {
    @Published var animeRepository: AnimeRepository
    @Published var appState: AppState
    @Published var searchText = ""
    @Published var friends: [User] = []
    @Published var pendingRequest: [(User, Friendship)] = []
    @Published var userSearchResult: [User] = []
    @Published var isShowingAddFriendSheet = false
    
    private lazy var container: CKContainer = CKContainer.default()
    private lazy var database: CKDatabase = container.publicCloudDatabase
    private var TAG = "[FriendViewModel]"
        
    init(animeRepository: AnimeRepository, appState: AppState) {
        self.animeRepository = animeRepository
        self.appState = appState
        Task {
            do {
//                try await fetchAllUsers()
//                pendingRequest = await fetchPendingFriendshipRequests()
//                try await fetchFriendList()
            } catch {
                print("\(TAG) Error getting all users: \(error)")
            }

        }
    }
    
    func getAnimeData(user: User) async -> [AnimeNode] {
        var animes: [AnimeNode] = []
        
        do {
            let predicate = NSPredicate(format: "creatorUserRecordID == %@", user.userID)
            let query = CKQuery(recordType: "Anime", predicate: predicate)
            
            let (results, _) = try await database.records(matching: query)
//            let animeIDs = results.compactMap { try? $0.1.get()[.animeID] as? Int }
            for (recordID, result) in results {
                if let record = try? result.get() {
                    guard let animeID = record[.animeID] as? Int else { continue }
                    var anime = try await animeRepository.fetchAnime(animeID: animeID)
                    anime.record = AnimeRecord(record: record)
                    animes.append(anime)
                }
            }
        } catch {
            print("error: \(error)")
        }
        
        return animes
    }
    
    func followButtonTapped(userToFollow: User) async {
        guard let user = appState.user else { return }
        // Insert FriendshipRequests record
        do {
            let record = CKRecord(recordType: .friendship)
            record[Friendship.RecordKey.senderID] = CKRecord.Reference(recordID: user.recordID, action: .none)
            record[Friendship.RecordKey.recipientID] = CKRecord.Reference(recordID: userToFollow.recordID, action: .none)
            record[Friendship.RecordKey.status] = Friendship.Status.pending.rawValue
            
            try await database.save(record)
            print("\(TAG) Sent follow request sucessfully.")
            
        } catch {
            print("\(TAG) Error sending follow request.")
        }
    }
    
    // Get all users record with firstnames that begins with 'x'
    func fetchUsers(startingWith prefix: String) async throws {
        guard prefix != "" else {
//            try await fetchAllUsers()
            self.userSearchResult = []
            print("No search")
            return
        }
        
        print("Look for users starting with: \(prefix)")
        var users: [User] = []
        let predicate = NSPredicate(format: "firstName BEGINSWITH %@", prefix)
        let query = CKQuery(recordType: .user, predicate: predicate)
        
        do {
            let (matchResults, _) = try await database.records(matching: query)
            
            for (recordID, result) in matchResults {
                let record = try result.get()
                users.append(try User(record: record))
            }
        } catch {
            print("Error fetching user: \(error)")
        }
        self.userSearchResult = users
        print("Count: \(users.count)")
    }
    
    func fetchAllUsers() async throws {
        var users: [User] = []
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: .user, predicate: predicate)
        
        let (matchResults, _) = try await database.records(matching: query) // new async version
        print("Fetched users")
        
        for (recordID, result) in matchResults {
            let record = try result.get()
            let user = try User(record: record)
            users.append(user)
        }
        
        self.userSearchResult = users
    }
    
    func fetchFriendList() async {
//        let results = await fetchPendingFriendshipRequests()
//        let friends = fetchFriends()
//        self.friends.append(contentsOf: pendingRequest)
//        self.friends.append(contentsOf: friends)
    }
    
    func fetchPendingFriendshipRequests() async -> [(User, Friendship)] {
        print("fetchPendingFriendshipRequests()")
        guard let user = appState.user else { return [] }
        var result: [(User, Friendship)] = []
        
        do {
            // 1. Get list of pending requests
            // Get all records from FriendshipRequest
            // Where current user's id == FriendshipRequests.friendID and status == 'pending'
            let reference = CKRecord.Reference(recordID: user.recordID, action: .none)
            let predicate = NSPredicate(format: "recipientID == %@ AND status == %@", reference, "pending")
            let query = CKQuery(recordType: .friendship, predicate: predicate)
            let operation = CKQueryOperation(query: query)
            
            let (results, _) = try await database.records(matching: query)
            print(result.count)
            let friendshipRequestRecords = results.compactMap { try? $0.1.get() }
            let requestStatuses = friendshipRequestRecords.compactMap { try? Friendship(record: $0) }
            
            let senderIDs = friendshipRequestRecords
                .compactMap { $0[Friendship.RecordKey.senderID] as? CKRecord.Reference }
                .compactMap { $0.recordID }
            
            
            // 2. Fetch adddtional user info using requestee's id
            // Get all user From User where User.recordName == FriendshipRequests.userID
            let users = await getUsers(recordIDs: senderIDs)
            
            // 3. Join the 2 results
            for user in users {
                if let status = requestStatuses.first(where: { $0.senderID.recordID.recordName == user.recordName }) {
                    result.append((user, status))
                    print((user.recordName, status.status.rawValue))
                }
            }
            
            return result
            
        } catch {
            print("\(TAG) Error fetcing pending friendship requests: \(error)")
        }
        
        return []
    }
    
    func getUsers(recordIDs: [CKRecord.ID]) async -> [User] {
        do {
            let results = try await database.records(for: recordIDs)
            let users = results
                .compactMap { try? $0.value.get() }
                .compactMap { try? User(record: $0) }
            
            return users
        } catch {
            print("\(TAG) Error fetching users: \(error)")
        }

        return []
    }
    
    func acceptButtonTapped(friend: User, friendship: Friendship) async {
        do {
            // 1. Update friendship table
            print(friendship.recordName)
            var friendship = try await database.record(for: friendship.recordID)
            friendship[Friendship.RecordKey.status.rawValue] = Friendship.Status.accepted.rawValue
            try await database.save(friendship)
            print("\(TAG) Added \(friend.firstName) sucessfully")
            pendingRequest = pendingRequest.filter({ $0.0.recordName != friend.recordName })
            friends.append(friend)
        } catch {
            print("\(TAG) Error acceptButtonTapped: \(error)")
        }
        
    }
    
    func fetchFriends() async {
        guard let currentUser = appState.user else { return }
        print("fetchingFriends()")
        // 1. Fetch all users where friendID == user id or friendID == friend id
        // No OR operator, just have to do 2 separte queries, combine result in set to get intersection
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .none)
        let predicate1 = NSPredicate(format: "senderID == %@ AND status == 'accepted'", reference)
        let predicate2 = NSPredicate(format: "recipientID == %@ AND status == 'accepted'", reference)
        let query1 = CKQuery(recordType: .friendship, predicate: predicate1)
        let query2 = CKQuery(recordType: .friendship, predicate: predicate2)

        do {
            let (results1, _) = try await database.records(matching: query1)
            let (results2, _) = try await database.records(matching: query2)
            print(results1.count)
            print(results2.count)
            var result3: [User] = []
            for result in results1 {
                // use friendID to fetch User
                if let userID = try result.1.get()[Friendship.RecordKey.recipientID] as? CKRecord.Reference {
                    let record = try await database.record(for: userID.recordID)
                    result3.append(try User(record: record))
                }
            }
            
            for result in results2 {
                // use userID to fetch User
                if let userID = try result.1.get()[Friendship.RecordKey.senderID] as? CKRecord.Reference {
                    let record = try await database.record(for: userID.recordID)
                    result3.append(try User(record: record))
                }
            }
            
            
            print(result3.map { $0.firstName })
            self.friends = result3
            
        } catch {
            print("\(TAG) Error fetching friend: \(error)")
        }
    }
    
    func removeFriend(_ friend: User) async {
        guard let currentUser = appState.user else { return }

        let userReference = CKRecord.Reference(recordID: currentUser.recordID, action: .none)
        let friendReference = CKRecord.Reference(recordID: friend.recordID, action: .none)
        let predicate1 = NSPredicate(format: "senderID == %@ AND recipientID == %@", userReference, friendReference)
        let predicate2 = NSPredicate(format: "senderID == %@ AND recipientID == %@", friendReference, userReference)
        let query1 = CKQuery(recordType: .friendship, predicate: predicate1)
        let query2 = CKQuery(recordType: .friendship, predicate: predicate2)

        do {
            let (results1, _) = try await database.records(matching: query1, resultsLimit: 1)
            let (results2, _) = try await database.records(matching: query2, resultsLimit: 1)
            
            if let recordID = results1.first?.0 {
                try await database.deleteRecord(withID: recordID)
                
                print("Removed friend \(friend.firstName)")
                friends = friends.filter { $0.recordID != recordID }
            }
            if let recordID = results2.first?.0 {
                try await database.deleteRecord(withID: recordID)
                print("Removed friend \(friend.firstName)")
                friends = friends.filter { $0.recordID != recordID }
            }

        } catch {
            print("Error removing friend: \(error)")
        }
        
    }
}
