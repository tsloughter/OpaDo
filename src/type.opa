type User.password = string
type User.ref = string

type User.t = { 
    User.ref ref,
    string username,
    string fullname,
    User.password password,
    bool is_oauth,   
}

type User.status = {User.ref logged} or {unlogged}

type User.info = UserContext.t(User.status)
type User.map('a) = ordered_map(User.ref, 'a, String.order)

type Todo.id = string

type Todo.t = {
    Todo.id id,
    string useref,
    string value,
    bool done,
    string created_at
}

//database opado { // with Opa 9.0.0
database opado {
    User.t /users[{ref}]
    /users[_]/is_oauth = false
    Todo.t /todos[{id}]
    /todos[_]/done = false
   // Default value for string is "" (empty string)
}

