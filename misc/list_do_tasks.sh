

mkdir -p misc/procedures
rm -f misc/procedures/*.txt

make clean
make --dry-run | python misc/list_do_tasks.py > misc/procedures/all.txt