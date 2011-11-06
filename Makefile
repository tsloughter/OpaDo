NAME = main.exe

SRC  = src/todo.opa src/user.opa src/admin.opa src/main.opa

all: $(NAME)

$(NAME): $(SRC)
	opa $(SRC) -o $(NAME)

clean:
	rm -f $(NAME)
	rm -rf _build
