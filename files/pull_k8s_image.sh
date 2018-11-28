#!/bin/bash

function pullImage
{
	# 获取镜像名称
	commonName=$(echo $1 | awk -F'[/]' '{print $2}')
	# 墙内镜像地址
	innerImage=anjia0532/google-containers.${commonName}

	#墙外镜像地址
	outerImage=k8s.gcr.io/${commonName}
	docker pull ${innerImage}

	#重命名镜像名称
	docker tag ${innerImage} ${outerImage}
	docker rmi ${innerImage}
}

if [ ! $1 ]; then
	VERSION=1.12.0
else
	VERSION=$1
	echo ${VERSION} >> /root/version.txt
fi

images=$(kubeadm config images list --kubernetes-version v${VERSION})
localimage=$(docker images | sed '1d' | awk '{print $1":"$2}')
for image in ${images}
do
	if [ -n "${localimage[@]}" ]; then # 如果本地有镜像才进行比较
		if ! echo "${localimage[@]}" | grep -w ${image}&>/dev/null; then
			pullImage ${image}
		else
			continue
		fi
	else
		pullImage ${image}
	fi
done
