#/bin/bash


image_list=$(wget -O - 10.84.5.81:5000/v2/_catalog | python -m json.tool |grep contrail |cut -d "\"" -f 2 )

for images in $image_list
do
  docker pull  opencontrailnightly/$images
  id=$( docker images opencontrailnightly/$images --format  "{{.ID}}"  )
  repo=$( docker images opencontrailnightly/$images --format  "{{.Repository}}"  )
  docker images opencontrailnightly/$images --format  "{{.ID}} {{.Tag}}"  > id_tag.txt
  count=1

  for i in $id
  do
    current_id=$(awk "NR==$count"  id_tag.txt | cut -d " " -f 1)
    current_tag=$(awk "NR==$count"  id_tag.txt | cut -d " " -f 2)
    echo " $current_id nad $current_tag "
    docker tag $current_id localhost:5000/$images:$current_tag
    docker push localhost:5000/$images:$current_tag
    count=$count+1
  done

  #starting of cleanup of tagged localhost images
  count_cleanup=1

  docker images localhost:5000/$images --format  "{{.ID}} {{.Tag}}"  > local_id_tag.txt
  local_repo=$(docker images localhost:5000/$images --format  "{{.Repository}}" )
  for i in $local_repo
  do
    local_id=$(awk "NR==$count_cleanup"  local_id_tag.txt | cut -d " " -f 1)
    local_tag=$(awk "NR==$count_cleanup"  local_id_tag.txt | cut -d " " -f 2)
    echo " $local_id  ffff  $local_tag and $i"
    count=$count_cleanup+1
    docker rmi  $i:$local_tag
  done

done

docker rmi -f  $(docker images -f dangling=true -q)
