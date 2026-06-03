case "$1" in
e)	vi -p .x
	;;
b)	docker build -t claude .
	;;
s)	docker run --rm -it --name claude -v "$(pwd):/app" -v ~/.claude/:/home/claude/.claude/ -v ~/.claude.json:/home/claude/.claude.json --entrypoint=/bin/bash claude
	;;
"")	docker run --rm -it --name claude -v "$(pwd):/app" -v ~/.claude/:/home/claude/.claude/ -v ~/.claude.json:/home/claude/.claude.json claude
	;;
esac
