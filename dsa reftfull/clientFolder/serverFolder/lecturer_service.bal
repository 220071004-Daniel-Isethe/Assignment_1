import ballerina/http;

listener http:Listener ep0 = new (8080, config = {host: "localhost"});

public type Lecturer record {
    # the staff number of the lecturer
    string staffnumber?;
    # the office number of the lecturer
    string officenumber?;
    # the name of the lecturer
    string staffname?;
    # the title of the lecturer
    string title?;
    # Array of courses taught by the lecturer
    Course[] courses;
};

public type Course record {
    # the course name
    string coursename?;
    # the course code
    string coursecode?;
    # the NQF level of the course
    int nqflevel?;
};

public Lecturer[] lecturers = [
    {
        "staffnumber": "L1",
        "officenumber": "Office A",
        "staffname": "Dr. John Smith",
        "title": "Professor",
        "courses": [
            {
                "coursename": "Data Structures and Algorithms",
                "coursecode": "DSA",
                "nqflevel": 7
            }
        ]
    }
    //(other lecturer records)
];

// Define your isolated function here
public isolated function myIsolatedMethod() returns string {
    // Method logic here
    return "Hello, from myIsolatedMethod!";
}

service /api/v1 on ep0 {
    resource function get lecturers() returns Lecturer[] {
        return lecturers;
    }
    // ... (other resource functions)

    resource function get courses/[string coursecode]() returns Course[]|http:Response|string {
        Lecturer[] tempCourseArray = [];
        foreach var lecturer in lecturers {
            foreach var course in lecturer.courses {
                if (coursecode == course.coursecode) {
                    tempCourseArray.push(lecturer);
                }
            }
        }
        return tempCourseArray;
    }

    resource function get office/[string officenumber]() returns Lecturer[]|string {
        Lecturer[] tempOfficeArray = [];
        foreach var lecturer in lecturers {
            if (officenumber == lecturer.officenumber) {
                tempOfficeArray.push(lecturer);
            }
        }
        return tempOfficeArray;
    }
}
