#!/usr/bin/env bash
set -euo pipefail

while getopts 'k:' o;
do 
  case $o in
    k) zettel_dir=$OPTARG ;;
  esac
done

if [[ $OPTIND == 1 ]];then 
  zettel_dir="$HOME/zettelkasten" 
fi

mkdir -p $zettel_dir
kasten_file=${zettel_dir}/kasten.rec
if [ ! -f $kasten_file ]; then
  printf "%s\n%s\n%s\n%s\n%s\n%s" \
    "%rec: Zettel" \
    "%sort: id" \
    "%type: id int" \
    "%type: ts date" \
    "%type: reference rec Zettel" \
    "%key: id" >> $kasten_file
fi
printf "\n%s" "tags:" >> ${zettel_dir}/zettel.md
$EDITOR ${zettel_dir}/zettel.md > /dev/tty

zettel_contents=$(head -n -1 ${zettel_dir}/zettel.md)
tagline=$(tail -1 ${zettel_dir}/zettel.md)
tagline=$(printf "%s\n" ${tagline#tags: } | tr -d ",")
zettel_id=$(date +%s)

recins -t Zettel \
  -f id -v ${zettel_id} \
  -f ts -v @${zettel_id} \
  -f contents -v "${zettel_contents}" \
  $kasten_file
q_string="(tag='"
while read tag
  do
    recset -t Zettel \
      -e "id=${zettel_id}" \
      -f tag -a $tag \
      $kasten_file

    q_string+=$tag
    q_string+="' || tag='"
done <<< "${tagline}"
q_string=${q_string%????????}
q_string+=") && id!=${zettel_id}"
recsel -e "${q_string}" -p id,contents,tag $kasten_file >> $zettel_dir/linker.rec
recset -f link -a no $zettel_dir/linker.rec
$EDITOR $zettel_dir/linker.rec > /dev/tty
recsel -C -P id -e 'link="yes"' $zettel_dir/linker.rec | while read link
do
  recset -e "id=${zettel_id}" -f reference -a $link $kasten_file
done

rm ${zettel_dir}/zettel.md
rm ${zettel_dir}/linker.rec
