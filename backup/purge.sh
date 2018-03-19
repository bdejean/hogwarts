#/bin/sh

[ -d old ] || mkdir old

ls -1tr *.gz | xargs zcat -l -v | awk 'u[$2, $7]++ { print $9 }'  | while read F; do
	mv -nv $F.gz old/
done

