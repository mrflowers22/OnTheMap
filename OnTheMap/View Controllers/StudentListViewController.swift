//
//  StudentListViewController.swift
//  OnTheMap
//
//  Created by Michael Flowers on 2/26/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController {
    
    var students: [Student]? {
        didSet {
            if students != nil {
                self.tableView.reloadData()
            } else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                return
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        orderStudentsArray()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: .postedStudentLocation, object: nil)
    }
    
    @objc func refreshTable(){
        students?.removeAll()
        orderStudentsArray()
    }
    
    func orderStudentsArray(){
        NetworkController.shared.orderStudentsInList { (success, error) in
            if let realError = error as? ErrorStruct {
                DispatchQueue.main.async {
                    self.failureAlert(title: "Network Failure", message: realError.localizedDescription)
                }
            } else if let error = error  {
                DispatchQueue.main.async {
                    self.failureAlert(title: "Network Failure", message: error.localizedDescription)
                }
            }
            
            //if this worked then we should have students in network controller
            self.students = NetworkController.shared.orderedStudents
        }
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        NetworkController.shared.logout(completion: self.handleLogoutResponse(success:error:))
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        //clear student array
        self.students?.removeAll()
        
        //network call to retrieve students
        orderStudentsArray()
    }
}

extension StudentListViewController: UITableViewDelegate,  UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
        
        let student = students?[indexPath.row]
        cell.textLabel?.text = student?.fullName
        cell.detailTextLabel?.text = student?.mediaURL
        
        //to test to see if the tableView is sorted properly
        //        cell.detailTextLabel?.text = student?.createdAt
        
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        return  cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let student = students?[indexPath.row], let url = URL(string: student.mediaURL) {
            let app = UIApplication.shared
            app.open(url, options: [:], completionHandler: nil)
        } else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return
        }
    }
}
