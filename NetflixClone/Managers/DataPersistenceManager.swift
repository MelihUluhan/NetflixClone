//
//  DataPersistenceManager.swift
//  Netflix_Clone
//
//  Created by Melih Bey on 7.08.2025.
//

import Foundation
import UIKit
import CoreData

class DataPersistenceManager {
    
    enum DataBaseError: LocalizedError {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
        case duplicateEntry
        
        var errorDescription: String? {
            switch self {
                case .failedToSaveData:
                    return "Failed to save data. Please try again later."
                case .failedToFetchData:
                    return "Failed to fetch data. Please try again later."
                case .failedToDeleteData:
                    return "Failed to delete data. Please try again later."
                case .duplicateEntry:
                    return "This movie has already been downloaded."
            }
        }
    }
    
    static let shared = DataPersistenceManager()
    
    func downloadMovieWith(model: Movie, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<MovieItem> = MovieItem.fetchRequest()
        
        request.predicate = NSPredicate(format: "id == %d", model.id)
        
        do {
            let existingItems = try context.fetch(request)
            if !existingItems.isEmpty {
                completion(.failure(DataBaseError.duplicateEntry))
                return
            }
        } catch {
            completion(.failure(error))
            return
        }
        
        let item = MovieItem(context: context)
        item.original_title = model.original_title
        item.id = Int64(model.id)
        item.original_name = model.original_name
        item.overview = model.overview
        item.poster_path = model.poster_path
        item.release_date = model.release_date
        item.vote_average = model.vote_average
        item.vote_count = Int64(model.vote_count)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DataBaseError.failedToSaveData))
        }
    }

    
    func fetchMoviesFromDataBase(completion: @escaping (Result<[MovieItem], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<MovieItem> = MovieItem.fetchRequest()
        
        do {
            let movies = try context.fetch(request)
            completion(.success(movies))
        } catch {
            completion(.failure(DataBaseError.failedToFetchData))
        }
    }
    
    func deleteMovieWith(model: MovieItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(model)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DataBaseError.failedToDeleteData))
        }
    }
}
