CC = v
ARGS = -use-os-system-to-run -cg -cc gcc

all:
	$(MAKE) fmt
	$(CC) $(ARGS) run .


fmt:
	$(CC) fmt -w .