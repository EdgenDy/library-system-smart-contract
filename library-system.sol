// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
/**
 * @title LibraryInventory
 * @dev A simple contract for managing a library's book inventory.
 */
contract LibraryInventory {

    // 1. DATA STRUCTURES

    // Struct to hold a book's detailed information
    struct Book {
        uint id;
        string title;
        string author;
        uint year;
        uint totalCopies;
        uint availableCopies;
    }

    // Mapping: Book ID (uint) => Book Struct
    mapping(uint => Book) public books;

    // A counter to assign unique IDs to new books
    uint private nextBookId = 1;

    // 2. MODIFIERS

    // Restricts access to functions to only the contract owner
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    // The contract owner is set upon deployment
    constructor() {
        owner = msg.sender;
    }

    // 3. CORE FUNCTIONS

    /**
     * @notice Adds a new book to the inventory.
     * @param _title The title of the book.
     * @param _author The author of the book.
     * @param _year The year the book was published.
     * @param _totalCopies The total number of copies held by the library.
     */
    function addBook(
        string memory _title,
        string memory _author,
        uint _year,
        uint _totalCopies
    ) public onlyOwner returns (uint) {
        // Require at least one copy to be added
        require(_totalCopies > 0, "Must add at least one copy.");

        uint currentId = nextBookId;

        books[currentId] = Book({
            id: currentId,
            title: _title,
            author: _author,
            year: _year,
            totalCopies: _totalCopies,
            availableCopies: _totalCopies // Initially, all copies are available
        });

        nextBookId++; // Increment ID for the next book
        return currentId;
    }

    /**
     * @notice Updates the details of an existing book.
     * @dev Only non-zero/non-empty values will overwrite existing data.
     * @param _id The ID of the book to update.
     * @param _title The new title (pass "" to keep current).
     * @param _author The new author (pass "" to keep current).
     * @param _year The new publication year (pass 0 to keep current).
     */
    function updateBookDetails(
        uint _id,
        string memory _title,
        string memory _author,
        uint _year
    ) public onlyOwner {
        // Check if the book ID exists
        require(books[_id].id != 0, "Book ID does not exist.");

        // Create a storage pointer for gas efficiency
        Book storage bookToUpdate = books[_id];

        // Update fields only if new values are provided
        if (bytes(_title).length > 0) {
            bookToUpdate.title = _title;
        }
        if (bytes(_author).length > 0) {
            bookToUpdate.author = _author;
        }
        if (_year > 0) {
            bookToUpdate.year = _year;
        }
    }

    /**
     * @notice Updates the total number of copies, recalculating the available copies.
     * @dev Use this to purchase more copies or declare copies lost/discarded.
     * @param _id The ID of the book to update.
     * @param _newTotalCopies The new total number of copies held.
     */
    function updateBookCopies(uint _id, uint _newTotalCopies) public onlyOwner {
        // Check if the book ID exists
        require(books[_id].id != 0, "Book ID does not exist.");
        require(_newTotalCopies >= 0, "Total copies cannot be negative.");

        Book storage bookToUpdate = books[_id];
        uint oldTotal = bookToUpdate.totalCopies;

        // The number of unavailable (checked-out) copies is the difference between old total and available
        uint currentlyUnavailable = oldTotal - bookToUpdate.availableCopies;

        // Ensure the new total copies can still cover the currently unavailable copies
        require(_newTotalCopies >= currentlyUnavailable, "New total copies is less than the number of checked out books.");

        // Update the total copies
        bookToUpdate.totalCopies = _newTotalCopies;

        // Recalculate available copies
        bookToUpdate.availableCopies = _newTotalCopies - currentlyUnavailable;
    }

    // 4. VIEW FUNCTION

    function getBook(uint _id)
        public
        view
        returns (uint id, string memory title, string memory author, uint year, uint totalCopies, uint availableCopies)
    {
        // Check if the book ID exists before returning
        require(books[_id].id != 0, "Book ID does not exist.");

        Book storage book = books[_id];
        return (
            book.id,
            book.title,
            book.author,
            book.year,
            book.totalCopies,
            book.availableCopies
        );
    }
}