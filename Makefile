NAME = main.exe

SRC  = src/type.opa src/todo.opa src/user.opa src/admin.opa src/main.opa src/ui.opa

all: $(NAME)

$(NAME): $(SRC)
	opa --database mongo $(SRC) -o $(NAME)

clean:
	rm -f $(NAME)
	rm -rf _build
