NAME = opado.exe

SRC  = opado.opa

all: $(NAME)

$(NAME):
	opa $(SRC)

clean:
	rm -f $(NAME)
	rm -rf _build
