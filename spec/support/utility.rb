def test_schema
  "tables:\n" + 
  "  - CREATE TABLE users (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "username TEXT UNIQUE," +
        "email TEXT UNIQUE," +
        "name TEXT," +
        "balance INTEGER" +
      ")\n" +
  "  - CREATE TABLE transactions (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "user_from INTEGER," +
        "user_to INTEGER," +
        "type TEXT," +
        "amount REAL," +
        "FOREIGN KEY(user_from) REFERENCES users(id)," +
        "FOREIGN KEY(user_to) REFERENCES users(id)" +
        ")\n"
end
