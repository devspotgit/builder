

work_dir=""

site_dir=""

if [ "$1" != "" ]; then
 work_dir=$1
else
 work_dir=`pwd`
fi

if [ "$2" != "" ]; then
 site_dir=$2
else
 site_dir=`pwd`
fi

#load the config file
if [ -f ${work_dir}/config.sh ]; then
 source ${work_dir}/config.sh
else
 echo "can't find config file"
 exit 1
fi

#load templates
for template in ${templates[@]}; do
 if [ -f ${work_dir}/${template}.sh ]; then
  source ${work_dir}/${template}.sh
  else
   echo "can't find ${work_dir}/${template}.sh"
   exit 1
  fi
done

#load global data
for data in ${global_data[@]}; do
 if [ -f ${work_dir}/${data}.sh ]; then
  source ${work_dir}/${data}.sh
 else
   echo "can't find ${work_dir}/${data}.sh"
   exit 1
 fi
done


#load page data
for page in ${pages[@]}; do
 if [ -f ${work_dir}/${page}.sh ]; then
  source ${work_dir}/${page}.sh
 else
   echo "can't find ${work_dir}/${page}.sh"
   exit 1
 fi
done


#load collection data
for collection in ${collections[@]}; do
 declare -n _collection=$collection
 for file in ${_collection[@]}; do
  if [ -f ${work_dir}/${collection}/${file}.sh ]; then
   source ${work_dir}/${collection}/${file}.sh
  else
   echo "can't find ${work_dir}/${collection}/${file}.sh"
   exit 1
  fi
 done
done



#check for the tracker in the site directory
if [ -f ${site_dir}/tracker ]; then
 content=`cat ${site_dir}/tracker`
 ifs=$IFS
 IFS=$'\n\r'
 for line in $content; do
  if [ "$line" != "" ]; then
   IFS="/"
   for item in $line; do
    if [ "$item" != "" ]; then
     IFS=$ifs
     rm -r ${site_dir}/${item}
     break
    fi
   done
   IFS=$'\n\r'
  fi
 done
 IFS=$ifs
 echo "" > ${site_dir}/tracker
else
  echo "" >  ${site_dir}/tracker
fi



#create pages from page data
for page in ${pages[@]}; do
 declare -n _page=$page
 if [ "${_page[template]}" != "" ]; then
  mkdir -p ${site_dir}/${_page[path]}
  echo "`${_page[template]} $page`" > ${site_dir}/${_page[path]}/index.html
  echo ${_page[path]}/index.html >> ${site_dir}/tracker
 fi
done



#create pages from collection data
for collection in ${collections[@]}; do
 declare -n _collection=$collection
 for file in ${_collection[@]}; do
  declare -n _file=$file
  if [ "${_file[template]}" != "" ]; then
   mkdir -p ${site_dir}/${_file[path]}
   echo "`${_file[template]} $file`" > ${site_dir}/${_file[path]}/index.html
   echo ${_file[path]}/index.html >> ${site_dir}/tracker
  fi
 done
done

#copy static file to site folder
for file in ${static[@]}; do
 if [ -f ${work_dir}/${file} ]; then
  cp ${work_dir}/${file} ${site_dir}
  echo $file >> ${work_dir}/tracker
 elif [ -d ${work_dir}/${file} ]; then
  cp -r ${work_dir}/${file} ${site_dir}
  echo $file >> ${work_dir}/tracker
 else
  echo "can't find ${work_dir}/${file}"
  exit 1
 fi
done














































