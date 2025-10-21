case "$1" in
e)	vi -p .x
	;;
b)	docker build -t claude .
	;;
bn)	docker build --no-cache -t claude .
	;;
"")	true
	;;
esac
