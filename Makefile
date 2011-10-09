NAME = main.exe

SRC  = src/todo.opa src/user.opa src/main.opa

all: $(NAME)

$(NAME):
	opa $(SRC)

clean:
	rm -f src/$(NAME)
	rm -rf _build
