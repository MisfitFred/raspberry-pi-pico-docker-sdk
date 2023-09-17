
function stopContainer {
    echo "Cleaning up"

    # Check if container is running, if yes stop it
    if [ "$(docker container ls -a -f "name=$containerName" -f "status=running" | grep -c $containerName)" -gt 0 ]; then
        echo "Container $containerName exists and is exited"
        docker container stop $containerName
    else
        echo "Container $containerName does not exist or is not running"
    fi

    # Check if container exists and is exited, if yes remove it
    if [ "$(docker container ls -a -f "name=$containerName" -f "status=exited" | grep -c $containerName)" -gt 0 ]; then
        echo "Container $containerName exists and is exited"
        docker container rm $containerName -f
    else
        echo "Container $containerName does not exist or is not exited"
    fi
}


if [[ -z $1 ]]; then
    echo "Please provide an SDK image you want to test"
fi

#set -e #exits in case of error

containerName="pico-sdk-container"

#call stopContainer function
stopContainer

echo "start container"
docker run -d -it -u $(id -u):$(id -g) --name $containerName --mount type=bind,source=${PWD}/test_poject,target=/home/dev $1
#docker run -d -it --name $containerName --mount type=bind,source=${PWD}/test_poject,target=/home/dev $1


#docker exec -it $containerName /bin/sh

echo "build test project"
docker exec $containerName /bin/sh -c "cd /home/dev && cmake -S . -B build -G Ninja -DPICO_BOARD=pico_w && cmake --build ./build"

echo "run picotool"
docker exec $containerName /bin/sh -c "picotool"

stopContainer


