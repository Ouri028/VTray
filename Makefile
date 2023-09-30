CC = v
ARGS = -use-os-system-to-run -cg -cc gcc

all:
	$(CC) $(ARGS) run .
