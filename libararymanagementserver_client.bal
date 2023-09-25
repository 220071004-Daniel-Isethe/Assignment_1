
import ballerina/grpc;
import ballerina/io;
import ballerina/protobuf.types.wrappers;

LibararyManagementServerClient ep = check new ("http://localhost:9090");

public type LibaryAuth record {|
    string name = "";
    string id = "";

|};

LibaryAuth libaryAuth =
    {
    id: "12345",

    name: "Alex"
};

User[] users = [
    {
        name: "Alice",
        id: "user1",
        isbn: ["ISBN123", "ISBN456"]
    },
    {
        name: "Bob",
        id: "user2",
        isbn: ["ISBN789"]
    },
    {
        name: "Charlie",
        id: "user3",
        isbn: []
    }
];

string current_user = "";

public function main() {
    Authenticate();
}

function Authenticate() {

    current_user = io:readln("Enter your user id: ");

    if (current_user == libaryAuth.id) {
        io:println(libaryAuth.name + " Welcome back");
        LibararianFunctions();
    }
    foreach var user in users {
        if (current_user == user.id) {
            io:println(user.name + " Welcome back");
            StudentFunctions();
        }

    }
    io:println("Invalid details");
}

function StudentFunctions() {
    io:println("Student Menu:");
    io:println("1. List Available Books");
    io:println("2. Locate a Book");
    io:println("3. Borrow a Book");
    io:println("4. Exit");

    string choice = io:readln("Enter your choice: ");

    if (choice == "1") {
        listAvailableBooks();
    } else if (choice == "2") {
        locateBook();
    } else if (choice == "3") {
        borrowBook(current_user);
    } else if (choice == "4") {
        exit();
    } else {
        io:println("Invalid choice. Please try again.");
    }
}

function LibararianFunctions() {
    io:println("Librarian Menu:");
    io:println("1. Add a Book");
    io:println("2. Update a Book");
    io:println("3. Remove a Book");
    io:println("4. Create a User");
    io:println("5. Exit");

    string choice = io:readln("Enter your choice: ");

    if (choice == "1") {
        addBook();
    } else if (choice == "2") {
        updateBook();
    } else if (choice == "3") {
        removeBook();
    } else if (choice == "4") {
        error? user = createUser();
        if user is error {

        }
    } else if (choice == "5") {
        exit();
    } else {
        io:println("Invalid choice. Please try again.");
    }

}

function parseBoolean(string value) returns boolean {
    if (value == "true" || value == "True" || value == "1") {
        return true;
    } else if (value == "false" || value == "False" || value == "0") {
        return false;
    } else {

        return false;
    }
}

function addBook() {
    io:println("Adding a Book:");

    // Prompt the user to enter book details
    string title = io:readln("Enter Title: ");
    string author1 = io:readln("Enter Author 1: ");
    string author2 = io:readln("Enter Author 2 (optional): ");
    string location = io:readln("Enter Location: ");
    string isbn = io:readln("Enter ISBN: ");
    string statusStr = io:readln("Is the book available? (true/false): ");
    boolean status = parseBoolean(statusStr);

    // Create a book object
    Book book = {
        title: title,
        author_1: author1,
        author_2: author2,
        location: location,
        isbn: isbn,
        status: status
    };

    var result = ep->add_book(book);

    if (result is string) {
        string response = <string>result;
        io:println("Book added successfully. ISBN: " + response);
    } else if (result is error) {
        error grpcError = <error>result;
        io:println("Failed to add the book: " + grpcError.message());
    } else {

    }
    error? optionsWLogin = LibararianFunctions();
}

function updateBook() {
    io:println("Updating a Book:");

    string isbnToUpdate = io:readln("Enter the ISBN of the book to update: ");

    string title = io:readln("Enter updated Title: ");
    string author1 = io:readln("Enter updated Author 1: ");
    string author2 = io:readln("Enter updated Author 2 (optional): ");
    string location = io:readln("Enter updated Location: ");
    string statusStr = io:readln("Is the book available? (true/false): ");
    boolean status = parseBoolean(statusStr);

    Book updatedBook = {
        title: title,
        author_1: author1,
        author_2: author2,
        location: location,
        isbn: isbnToUpdate,
        status: status
    };

    var result = ep->update_book(updatedBook);

    if (result is string) {
        string response = <string>result;
        io:println("Book: " + response);
    } else if (result is error) {
        error grpcError = <error>result;
        io:println("Failed to update the book: " + grpcError.message());
    } else {
    }
    error? optionsWLogin = LibararianFunctions();

}

function removeBook() {
    string delete_isbn = io:readln("Enter ISBN: ");

    var result = ep->remove_book(delete_isbn);

    if (result is ListOfBookResponse) {
        ListOfBookResponse response = result;
        io:println(response);
    } else if (result is error) {
        error grpcError = <error>result;
        io:println("Failed to update the book: " + grpcError.message());
    } else {
    }
    // Implement the logic to remove a book from the server here
    error? optionsWLogin = LibararianFunctions();

}

function listAvailableBooks() {
    // Implement the logic to list available books from the server here

    var result = ep->list_avaialable_books("");

    if (result is string) {
        string response = <string>result;
        io:println("Available Books: " + response);
    } else if (result is error) {
        error grpcError = <error>result;
        io:println("Failed to get the avalable books: " + grpcError.message());
    } else {

    }
    error? optionsWLogin = StudentFunctions();

}

function locateBook() {
    string search_isbn = io:readln("Enter ISBN: ");

    var result = ep->locate_book(search_isbn);

    if (result is string) {
        string response = <string>result;
        io:println("Book: " + response);
    } else if (result is error) {
        error grpcError = <error>result;
        io:println("Failed to get the avalable books: " + grpcError.message());
    } else {

    }
    error? optionsWLogin = StudentFunctions();

}

function borrowBook(string userId) {
    string search_isbn = io:readln("Enter ISBN: ");

    BorrowBook borrow = {
        isbn: search_isbn,
        user_id: userId
    };

    do {

        var result = check ep->borrow_book(borrow);
        io:print(result);
    } on fail var e {
        io:println(e);
    }
    error? optionsWLogin = StudentFunctions();

}

function createUser() returns error? {
    // Prompt the user to enter user details
    string id = io:readln("Enter User ID: ");

    string name = io:readln("Enter User Name: ");

    User[] tempusers = [];

    // Create a User object with the entered details
    User user = {
        name: name,
        id: id,
        isbn: []
    };

    tempusers.push(user);
    users.push(user);

    Create_usersStreamingClient createUsersClient = check ep->create_users();

    foreach User val in users {
        check createUsersClient->sendUser(val);
    }

    check createUsersClient->complete();

    string? response = check createUsersClient->receiveString();

    if (response != null) {
        io:println("Server Response: ", response);
    } else {
        io:println("Failed to create users.");
    }
    error? optionsWLogin = LibararianFunctions();

}

function exit() {
    Authenticate();
    io:println("Exiting the Library Management System.");
    // Implement any necessary cleanup or exit logic here
}

public isolated client class LibararyManagementServerClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, ROOT_DESCRIPTOR_DSA2, getDescriptorMapDsa2());
    }

    isolated remote function add_book(Book|ContextBook req) returns string|grpc:Error {
        map<string|string[]> headers = {};
        Book message;
        if req is ContextBook {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/add_book", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return result.toString();
    }

    isolated remote function add_bookContext(Book|ContextBook req) returns wrappers:ContextString|grpc:Error {
        map<string|string[]> headers = {};
        Book message;
        if req is ContextBook {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/add_book", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: result.toString(), headers: respHeaders};
    }

    isolated remote function update_book(Book|ContextBook req) returns string|grpc:Error {
        map<string|string[]> headers = {};
        Book message;
        if req is ContextBook {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/update_book", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return result.toString();
    }

    isolated remote function update_bookContext(Book|ContextBook req) returns wrappers:ContextString|grpc:Error {
        map<string|string[]> headers = {};
        Book message;
        if req is ContextBook {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/update_book", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: result.toString(), headers: respHeaders};
    }

    isolated remote function remove_book(string|wrappers:ContextString req) returns ListOfBookResponse|grpc:Error {
        map<string|string[]> headers = {};
        string message;
        if req is wrappers:ContextString {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/remove_book", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ListOfBookResponse>result;
    }

    isolated remote function remove_bookContext(string|wrappers:ContextString req) returns ContextListOfBookResponse|grpc:Error {
        map<string|string[]> headers = {};
        string message;
        if req is wrappers:ContextString {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/remove_book", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ListOfBookResponse>result, headers: respHeaders};
    }

    isolated remote function list_avaialable_books(string|wrappers:ContextString req) returns string|grpc:Error {
        map<string|string[]> headers = {};
        string message;
        if req is wrappers:ContextString {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/list_avaialable_books", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return result.toString();
    }

    isolated remote function list_avaialable_booksContext(string|wrappers:ContextString req) returns wrappers:ContextString|grpc:Error {
        map<string|string[]> headers = {};
        string message;
        if req is wrappers:ContextString {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/list_avaialable_books", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: result.toString(), headers: respHeaders};
    }

    isolated remote function locate_book(string|wrappers:ContextString req) returns string|grpc:Error {
        map<string|string[]> headers = {};
        string message;
        if req is wrappers:ContextString {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/locate_book", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return result.toString();
    }

    isolated remote function locate_bookContext(string|wrappers:ContextString req) returns wrappers:ContextString|grpc:Error {
        map<string|string[]> headers = {};
        string message;
        if req is wrappers:ContextString {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/locate_book", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: result.toString(), headers: respHeaders};
    }

    isolated remote function borrow_book(BorrowBook|ContextBorrowBook req) returns Book|grpc:Error {
        map<string|string[]> headers = {};
        BorrowBook message;
        if req is ContextBorrowBook {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/borrow_book", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <Book>result;
    }

    isolated remote function borrow_bookContext(BorrowBook|ContextBorrowBook req) returns ContextBook|grpc:Error {
        map<string|string[]> headers = {};
        BorrowBook message;
        if req is ContextBorrowBook {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("LibararyManagementServer/borrow_book", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <Book>result, headers: respHeaders};
    }

    isolated remote function create_users() returns Create_usersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("LibararyManagementServer/create_users");
        return new Create_usersStreamingClient(sClient);
    }
}

public client class Create_usersStreamingClient {
    private grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUser(User message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUser(ContextUser message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveString() returns string|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return payload.toString();
        }
    }

    isolated remote function receiveContextString() returns wrappers:ContextString|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: payload.toString(), headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public client class LibararyManagementServerStringCaller {
    private grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendString(string response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextString(wrappers:ContextString response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public client class LibararyManagementServerBookCaller {
    private grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendBook(Book response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextBook(ContextBook response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public client class LibararyManagementServerListOfBookResponseCaller {
    private grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendListOfBookResponse(ListOfBookResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextListOfBookResponse(ContextListOfBookResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextUserStream record {|
    stream<User, error?> content;
    map<string|string[]> headers;
|};

public type ContextBorrowBook record {|
    BorrowBook content;
    map<string|string[]> headers;
|};

public type ContextListOfBookResponse record {|
    ListOfBookResponse content;
    map<string|string[]> headers;
|};

public type ContextUser record {|
    User content;
    map<string|string[]> headers;
|};

public type ContextBook record {|
    Book content;
    map<string|string[]> headers;
|};

public type BookResponse record {|
    string isbn = "";
|};

public type BorrowBook record {|
    string user_id = "";
    string isbn = "";
|};

public type ListOfBookResponse record {|
    Book[] books = [];
|};

public type User record {|
    string name = "";
    string id = "";
    string[] isbn = [];
|};

public type Book record {|
    string title = "";
    string author_1 = "";
    string author_2 = "";
    string location = "";
    string isbn = "";
    boolean status = false;
|};

const string ROOT_DESCRIPTOR_DSA2 = "0A0A647361322E70726F746F1A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F229A010A04426F6F6B12140A057469746C6518012001280952057469746C6512190A08617574686F725F311802200128095207617574686F723112190A08617574686F725F321803200128095207617574686F7232121A0A086C6F636174696F6E18042001280952086C6F636174696F6E12120A046973626E18052001280952046973626E12160A06737461747573180620012808520673746174757322220A0C426F6F6B526573706F6E736512120A046973626E18012001280952046973626E223E0A045573657212120A046E616D6518012001280952046E616D65120E0A0269641802200128095202696412120A046973626E18032003280952046973626E22390A0A426F72726F77426F6F6B12170A07757365725F6964180120012809520675736572496412120A046973626E18022001280952046973626E22310A124C6973744F66426F6F6B526573706F6E7365121B0A05626F6F6B7318012003280B32052E426F6F6B5205626F6F6B7332BB030A184C696261726172794D616E6167656D656E74536572766572122F0A086164645F626F6F6B12052E426F6F6B1A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C756512350A0C6372656174655F757365727312052E557365721A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C7565280112320A0B7570646174655F626F6F6B12052E426F6F6B1A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C756512400A0B72656D6F76655F626F6F6B121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A132E4C6973744F66426F6F6B526573706F6E736512530A156C6973745F61766169616C61626C655F626F6F6B73121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C756512490A0B6C6F636174655F626F6F6B121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C756512210A0B626F72726F775F626F6F6B120B2E426F72726F77426F6F6B1A052E426F6F6B620670726F746F33";

public isolated function getDescriptorMapDsa2() returns map<string> {
    return {"dsa2.proto": "0A0A647361322E70726F746F1A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F229A010A04426F6F6B12140A057469746C6518012001280952057469746C6512190A08617574686F725F311802200128095207617574686F723112190A08617574686F725F321803200128095207617574686F7232121A0A086C6F636174696F6E18042001280952086C6F636174696F6E12120A046973626E18052001280952046973626E12160A06737461747573180620012808520673746174757322220A0C426F6F6B526573706F6E736512120A046973626E18012001280952046973626E223E0A045573657212120A046E616D6518012001280952046E616D65120E0A0269641802200128095202696412120A046973626E18032003280952046973626E22390A0A426F72726F77426F6F6B12170A07757365725F6964180120012809520675736572496412120A046973626E18022001280952046973626E22310A124C6973744F66426F6F6B526573706F6E7365121B0A05626F6F6B7318012003280B32052E426F6F6B5205626F6F6B7332BB030A184C696261726172794D616E6167656D656E74536572766572122F0A086164645F626F6F6B12052E426F6F6B1A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C756512350A0C6372656174655F757365727312052E557365721A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C7565280112320A0B7570646174655F626F6F6B12052E426F6F6B1A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C756512400A0B72656D6F76655F626F6F6B121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A132E4C6973744F66426F6F6B526573706F6E736512530A156C6973745F61766169616C61626C655F626F6F6B73121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C756512490A0B6C6F636174655F626F6F6B121C2E676F6F676C652E70726F746F6275662E537472696E6756616C75651A1C2E676F6F676C652E70726F746F6275662E537472696E6756616C756512210A0B626F72726F775F626F6F6B120B2E426F72726F77426F6F6B1A052E426F6F6B620670726F746F33", "google/protobuf/wrappers.proto": "0A1E676F6F676C652F70726F746F6275662F77726170706572732E70726F746F120F676F6F676C652E70726F746F62756622230A0B446F75626C6556616C756512140A0576616C7565180120012801520576616C756522220A0A466C6F617456616C756512140A0576616C7565180120012802520576616C756522220A0A496E74363456616C756512140A0576616C7565180120012803520576616C756522230A0B55496E74363456616C756512140A0576616C7565180120012804520576616C756522220A0A496E74333256616C756512140A0576616C7565180120012805520576616C756522230A0B55496E74333256616C756512140A0576616C756518012001280D520576616C756522210A09426F6F6C56616C756512140A0576616C7565180120012808520576616C756522230A0B537472696E6756616C756512140A0576616C7565180120012809520576616C756522220A0A427974657356616C756512140A0576616C756518012001280C520576616C756542570A13636F6D2E676F6F676C652E70726F746F627566420D577261707065727350726F746F50015A057479706573F80101A20203475042AA021E476F6F676C652E50726F746F6275662E57656C6C4B6E6F776E5479706573620670726F746F33"};
}

