import ballerina/grpc;

listener grpc:Listener ep = new (9090);

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

Book[] books = [
    {
        title: "The Great Book",
        author_1: "Author One",
        author_2: "Author Two",
        location: "Library A",
        isbn: "ISBN123",
        status: true
    },
    {
        title: "Another Book",
        author_1: "Author Three",
        author_2: "",
        location: "Library B",
        isbn: "ISBN456",
        status: false
    },
    {
        title: "Bestseller",
        author_1: "Author Four",
        author_2: "",
        location: "Library C",
        isbn: "ISBN789",
        status: true
    }
];

@grpc:ServiceDescriptor {descriptor: ROOT_DESCRIPTOR_DSA2, descMap: getDescriptorMapDsa2()}

service "LibararyManagementServer" on ep {

    remote function add_book(Book value) returns string|error {
        books.push(value);
        return value.isbn;
    }
    remote function update_book(Book value) returns string|error {
        foreach var book in books {
            if (value.isbn == book.isbn) {

                book.title = <string>value.title;
                book.author_1 = <string>value.author_1;
                book.author_2 = <string>value.author_2;
                book.location = <string>value.location;
                book.status = <boolean>value.status;

                return "Successfully Updated";
            }
        }
        return "Not Updated";
    }
    remote function remove_book(string value) returns ListOfBookResponse|error|string {

        foreach var i in 0 ... books.length() {
            if (value == books[i].isbn) {

                Book removedBook = books.remove(i);
                ListOfBookResponse responseBooks = {
                    books: books
                };
                // responseBooks.books = books;
                return responseBooks;
            }
        }
        Book[] emptyBook = [
            {
                isbn: "Book has not been found",
                author_1: "Book has not been found",
                author_2: "Book has not been found",
                location: "Book has not been found",
                status: false,
                title: "Book has not been found"
            }
        ];

        ListOfBookResponse responseBooks = {
            books: emptyBook
        };
        // responseBooks.books = books;
        return responseBooks;

    }
    remote function list_avaialable_books(string value) returns string|error {
        Book[] available_books = [];

        foreach var book in books {
            if (book.status == true) {
                available_books.push(book);
            }
        }

        return available_books.toString();
    }
    remote function locate_book(string value) returns string|error {

        foreach var book in books {
            if (book.status == true) {
                if (book.isbn == value) {
                    return book.location;

                }
            }
        }
        return "Book is not available";
    }
    remote function borrow_book(BorrowBook value) returns Book|error {

        foreach var book in books {
            if (book.status == true) {
                foreach var user in users {
                    if (user.id == value.user_id) {
                        user.isbn.push(value.isbn);

                        return book;
                    }
                }

            }
        }
        Book tempBook = {
            title: "Not Found",
            author_1: "Not Found",
            author_2: "Not Found",
            location: "Not Found",
            isbn: "Not Found",
            status: true
        };

        return tempBook;
    }
    remote function create_users(stream<User, grpc:Error?> clientStream) returns string|error {

        check clientStream.forEach(function(User user) {
            foreach var userInArr in users {
                users.push(userInArr);
            }
        });

        return "Users created successfully";
    }
}

