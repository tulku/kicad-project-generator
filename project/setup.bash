alias ${PROJECT_NAME}_docker_build='sudo docker build -t ${PROJECT_NAME} .'
alias ${PROJECT_NAME}_kicad='xhost + && sudo docker run -t -v ${PROJECT_PATH}:/home/kicad/${PROJECT_NAME}/ -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$$DISPLAY -i ${PROJECT_NAME} kicad'
