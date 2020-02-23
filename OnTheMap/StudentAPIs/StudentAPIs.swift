//
//  StudentAPIs.swift
//  OnTheMap
//
//  Created by Michael Flowers on 2/22/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation

class StudentAPIs {
    
    //MARK: - Endpoints
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/StudentLocation"
        static let limitQuery = "?limit="
        static let uniqueKeyQuery = "?uniqueKey="
        
        case getAllStudents
        case limitStudentSearch(Int)
        case searchWithUniqueKey(String)
        
        var stringValue: String {
            switch self {
            case .getAllStudents: return Endpoints.base
            case .limitStudentSearch(let number): return Endpoints.base + Endpoints.limitQuery + "\(number)"
            case .searchWithUniqueKey(let userId):  return  Endpoints.base + Endpoints.uniqueKeyQuery + "\(userId)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    class func funcForAllGetMethods<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        print("This is the response (GET) url: \(url) for: \(responseType.self).")
        
        //create urlSession
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("Response: \(response.statusCode)")
            }
            if let error = error {
                print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let responseObject =  try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
                
            } catch  {
                print("Error in: \(#function)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func getStudentsWithALimit(studentLimit limit: Int, completion: @escaping ([Student]?, Error?) -> Void){
        funcForAllGetMethods(url: Endpoints.limitStudentSearch(limit).url, responseType: TopLevelDictionary.self) { (response, error) in
            if let error = error {
                print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            if let response = response {
                var studentsWithFullNames = [Student]()
                
                for student in response.results {
                    if student.firstName != "" && student.lastName != "" {
                        print("Student's name: \(student.fullName)")
                        studentsWithFullNames.append(student)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(studentsWithFullNames, nil)
                }
            } else {
                DispatchQueue.main.async {
                    print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                    completion(nil, error)
                }
            }
        }
    }
    
    
    class func getAllStudents(completion: @escaping ([Student]?, Error?) -> Void){
        funcForAllGetMethods(url: Endpoints.getAllStudents.url, responseType: TopLevelDictionary.self) { (response, error) in
            if let error = error {
                print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            if let response = response {
                var studentsWithFullNames = [Student]()
                
                for student in response.results {
                    if student.firstName != "" && student.lastName != "" {
                        print("Student's name: \(student.fullName)")
                        studentsWithFullNames.append(student)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(studentsWithFullNames, nil)
                }
            } else {
                DispatchQueue.main.async {
                    print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                    completion(nil, error)
                }
            }
        }
    }
    
}
