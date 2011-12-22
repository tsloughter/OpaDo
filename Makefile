NAME = main.exe

SRC  = src/todo.opa src/user.opa src/admin.opa src/main.opa src/ui.opa

all: $(NAME)

$(NAME): $(SRC)
	opa --parser js-like $(SRC) -o $(NAME)

clean:
	rm -f $(NAME)
	rm -rf _build
