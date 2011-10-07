NAME = main.exe

SRC  = src/main.opa

all: $(NAME)

$(NAME):
	opa $(SRC)

clean:
	rm -f src/$(NAME)
	rm -rf _build
